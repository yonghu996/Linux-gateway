#!/usr/bin/env bash
# 扫描 Git 全历史中的源码归档。历史上已知损坏的旧归档仅告警跳过；
# 当前 HEAD 的归档必须完整、无路径穿越、无链接/特殊文件，并通过 Gitleaks。
set -Eeuo pipefail

IMAGE="${GITLEAKS_IMAGE:-ghcr.io/gitleaks/gitleaks:v8.30.1}"
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"
TMP="$(mktemp -d)"
trap 'rm -rf -- "$TMP"' EXIT

HEAD_COMMIT="$(git rev-parse HEAD)"
HEAD_ARCHIVE_PATH='probe-server/source-v1.1.0-dev.tar.gz'
HEAD_ARCHIVE_BLOB="$(git rev-parse "$HEAD_COMMIT:$HEAD_ARCHIVE_PATH")"
declare -A SEEN_BLOBS=()
SCANNED=0
SKIPPED_OLD_BROKEN=0

while IFS= read -r COMMIT; do
  while IFS= read -r ARCHIVE_PATH; do
    [[ -n "$ARCHIVE_PATH" ]] || continue
    BLOB="$(git rev-parse "$COMMIT:$ARCHIVE_PATH")"
    if [[ -n "${SEEN_BLOBS[$BLOB]:-}" ]]; then
      continue
    fi
    SEEN_BLOBS[$BLOB]=1
    git show "$COMMIT:$ARCHIVE_PATH" > "$TMP/source.tar.gz"

    if ! tar -tzf "$TMP/source.tar.gz" > "$TMP/members.txt" 2>/dev/null; then
      if [[ "$BLOB" == "$HEAD_ARCHIVE_BLOB" ]]; then
        echo "当前源码归档损坏：$COMMIT:$ARCHIVE_PATH" >&2
        exit 1
      fi
      SKIPPED_OLD_BROKEN=$((SKIPPED_OLD_BROKEN + 1))
      echo "警告：跳过历史遗留损坏归档：$COMMIT:$ARCHIVE_PATH" >&2
      continue
    fi

    if grep -Eq '(^/|(^|/)\.\.(/|$))' "$TMP/members.txt"; then
      echo "拒绝包含路径穿越的源码归档：$COMMIT:$ARCHIVE_PATH" >&2
      exit 1
    fi
    if ! tar -tvzf "$TMP/source.tar.gz" | awk 'substr($1,1,1)!="-" && substr($1,1,1)!="d" {bad=1} END {exit bad}'; then
      echo "拒绝包含链接或特殊文件的源码归档：$COMMIT:$ARCHIVE_PATH" >&2
      exit 1
    fi

    rm -rf -- "$TMP/extracted"
    mkdir -p "$TMP/extracted"
    tar -xzf "$TMP/source.tar.gz" --no-same-owner --no-same-permissions --no-overwrite-dir -C "$TMP/extracted"
    docker run --rm -v "$TMP/extracted:/scan:ro" "$IMAGE" dir --redact --exit-code=2 /scan
    SCANNED=$((SCANNED + 1))
    echo "已扫描归档：$COMMIT:$ARCHIVE_PATH"
  done < <(git ls-tree -r --name-only "$COMMIT" | grep -E '^probe-server/.*\.tar\.gz$' || true)
done < <(git rev-list --all)

if [[ "$SCANNED" -eq 0 ]]; then
  echo '未扫描到任何完整源码归档。' >&2
  exit 1
fi
printf '完整归档扫描：%s 个；历史损坏归档跳过：%s 个。\n' "$SCANNED" "$SKIPPED_OLD_BROKEN"
