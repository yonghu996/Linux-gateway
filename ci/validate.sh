#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
bash "$ROOT_DIR/tests/shell-smoke.sh"
bash "$ROOT_DIR/tests/os-matrix.sh"
bash "$ROOT_DIR/tests/security-regression.sh"
if command -v shellcheck >/dev/null 2>&1; then
  find "$ROOT_DIR" -type f -name '*.sh' -print0 | while IFS= read -r -d '' SCRIPT_FILE; do
    shellcheck "$SCRIPT_FILE"
  done
else
  printf '[提示] 本地未安装 ShellCheck；CI 专用任务会执行 ShellCheck。\n'
fi
