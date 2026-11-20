#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
bash "$ROOT_DIR/tests/shell-smoke.sh"
bash "$ROOT_DIR/tests/os-matrix.sh"
if command -v shellcheck >/dev/null 2>&1; then
  find "$ROOT_DIR" -type f -name '*.sh' -print0 | xargs -0 -r shellcheck
else
  echo '[提示] 未安装 ShellCheck；本地跳过。CI 环境会安装并执行。'
fi
