#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
# shellcheck source=../lib/os-detect.sh
source "$ROOT_DIR/lib/os-detect.sh"
PASSED=0
for ITEM in 'debian 11 yes' 'debian 12 yes' 'ubuntu 20.04 yes' 'ubuntu 22.04 yes' 'ubuntu 24.04 no' 'rocky 9 no'; do
  read -r TEST_ID TEST_VERSION EXPECTED <<<"$ITEM"
  TMP_FILE="$(mktemp)"
  printf 'ID=%s\nVERSION_ID="%s"\n' "$TEST_ID" "$TEST_VERSION" > "$TMP_FILE"
  OS_RELEASE_FILE="$TMP_FILE" 识别系统
  rm -f "$TMP_FILE"
  if [[ "$OS_SUPPORTED" != "$EXPECTED" ]]; then
    printf '[失败] %s，期望 %s，实际 %s\n' "$ITEM" "$EXPECTED" "$OS_SUPPORTED"
    exit 1
  fi
  printf '[通过] %s %s => %s\n' "$TEST_ID" "$TEST_VERSION" "$OS_SUPPORTED"
  ((PASSED+=1))
done
printf 'OS 矩阵用例：%s\n' "$PASSED"
