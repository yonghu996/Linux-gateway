#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
FAILURES=0
while IFS= read -r -d '' SCRIPT_FILE; do
  if ! bash -n "$SCRIPT_FILE"; then printf '[失败] %s\n' "$SCRIPT_FILE"; FAILURES=1; fi
done < <(find "$ROOT_DIR" -type f -name '*.sh' -print0)
[[ $FAILURES -eq 0 ]] || exit 1
printf '[通过] 全部 Shell 脚本语法检查\n'
