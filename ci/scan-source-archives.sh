#!/usr/bin/env bash
# 对 Git 全历史中每一个不同版本的源码归档解包后执行 Gitleaks，避免压缩包绕过秘密扫描。
set -Eeuo pipefail
IMAGE="${GITLEAKS_IMAGE:-ghcr.io/gitleaks/gitleaks:v8.30.1}"
ROOT="$(git rev-parse --show-toplevel)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

declare -A SEEN_BLOBS=()
COUNT=0
while IFS= read -r COMMIT; do
  while IFS= read -r ARCHIVE_PATH; do
    [[ -n "$ARCHIVE_PATH" ]] || continue
    BLOB="$(git rev-parse "$COMMIT:$ARCHIVE_PATH")"
    if [[ -n "${SEEN_BLOBS[$BLOB]:-}" ]]; then continue; fi
    SEEN_BLOBS[$BLOB]=1
    COUNT=$((COUNT + 1))
    git show "$COMMIT:$ARCHIVE_PATH" > "$TMP/source.tar.gz"
    tar -tzf "$TMP/source.tar.gz" > "$TMP/members.txt"
    if grep -Eq '(^/|(^|/)\.\.(/|$))' "$TMP/members.txt"; then
      echo "拒绝包含路径穿越的源码归档：$COMMIT:$ARCHIVE_PATH" >&2
      exit 1
    fi
    if ! tar -tvzf "$TMP/source.tar.gz" | awk 'substr($1,1,1)!="-" && substr($1,1,1)!="d" {bad=1} END {exit bad}'; then
      echo "拒绝包含符号链接或特殊文件的源码归档：$COMMIT:$ARCHIVE_PATH" >&2
      exit 1
    fi
    rm -rf "$TMP/extracted"
    mkdir -p "$TMP/extracted"
    tar -xzf "$TMP/source.tar.gz" --no-same-owner --no-same-permissions --no-overwrite-dir -C "$TMP/extracted"
    docker run --rm -v "$TMP/extracted:/scan:ro" "$IMAGE" dir --redact --exit-code=2 /scan
    echo "已扫描归档：$COMMIT:$ARCHIVE_PATH"
  done < <(git ls-tree -r --name-only "$COMMIT" | grep -E '^probe-server/.*\.tar\.gz$' || true)
done < <(git rev-list --all)
printf '已扫描 %s 个不同源码归档版本。\n' "$COUNT"
