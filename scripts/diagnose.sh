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
mkdir -p "$LOG_DIR"
chmod 0750 "$LOG_DIR"
REPORT_FILE="$LOG_DIR/诊断-$(date +%Y%m%d-%H%M%S).txt"
{ printf '诊断时间：%s\n' "$(date -Is)"; 环境检测报告; printf '\n========== 服务状态 ==========\n'; systemctl --failed --no-pager 2>&1 || true; } | tee "$REPORT_FILE"
printf '\n报告已保存：%s\n' "$REPORT_FILE"
