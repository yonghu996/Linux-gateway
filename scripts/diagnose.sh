#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
# shellcheck disable=SC1091
source "$ROOT_DIR/lib/common.sh"
# shellcheck disable=SC1091
source "$ROOT_DIR/lib/os-detect.sh"
# shellcheck disable=SC1091
source "$ROOT_DIR/lib/capabilities.sh"
# shellcheck disable=SC1091
source "$ROOT_DIR/lib/checks.sh"
require_root
mkdir -p "$LOG_DIR"
chmod 0700 "$LOG_DIR"
REPORT_FILE="$LOG_DIR/诊断-$(date +%Y%m%d-%H%M%S).txt"
{ printf '诊断时间：%s\n' "$(date -Is)"; print_environment_report; printf '\n========== 服务状态 ==========\n'; systemctl --failed --no-pager 2>&1 || true; } >"$REPORT_FILE"
chmod 0600 "$REPORT_FILE"
cat "$REPORT_FILE"
printf '\n报告已保存：%s（权限 0600）\n' "$REPORT_FILE"
