#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
# shellcheck disable=SC1091
source "$ROOT_DIR/lib/os-detect.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
printf 'touch %s/EXECUTED\n' "$TMP_DIR" >"$TMP_DIR/fake-os-release"
detect_os
if [[ -e "$TMP_DIR/EXECUTED" ]]; then
  echo '[失败] 发行版识别执行了测试命令。'
  exit 1
fi
if grep -R --include='*.sh' -nE 'source[[:space:]]+.*OS_RELEASE_FILE|\. ["\x27]?\$OS_RELEASE_FILE' "$ROOT_DIR"; then
  echo '[失败] 发现从外部路径 source os-release 的代码。'
  exit 1
fi
echo '[通过] 发行版识别不执行外部文件'
