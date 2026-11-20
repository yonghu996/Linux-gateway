#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
# shellcheck source=../lib/common.sh
source "$ROOT_DIR/lib/common.sh"
# shellcheck source=../lib/os-detect.sh
source "$ROOT_DIR/lib/os-detect.sh"
# shellcheck source=../lib/capabilities.sh
source "$ROOT_DIR/lib/capabilities.sh"
# shellcheck source=../lib/checks.sh
source "$ROOT_DIR/lib/checks.sh"
需要_root
环境检测报告
