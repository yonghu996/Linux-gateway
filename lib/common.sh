#!/usr/bin/env bash
# 通用日志、权限、锁和交互函数。
# shellcheck disable=SC2034
PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
LOG_DIR="/var/log/linux-gateway"
LOCK_FILE="/run/lock/linux-gateway-installer.lock"
log_info() { printf '[信息] %s\n' "$*"; }
log_warn() { printf '[警告] %s\n' "$*" >&2; }
log_error() { printf '[错误] %s\n' "$*" >&2; }
require_root() {
  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then log_error '请使用 root 或 sudo 运行。'; return 1; fi
}
confirm_action() {
  local ANSWER
  read -r -p "${1:-确认继续？} [y/N]: " ANSWER || true
  [[ "$ANSWER" =~ ^([Yy]|[Yy][Ee][Ss])$ ]]
}
get_version() { cat "$PROJECT_ROOT/VERSION" 2>/dev/null || printf '开发版\n'; }
acquire_lock() {
  command -v flock >/dev/null 2>&1 || { log_error '缺少 flock（通常由 util-linux 提供）。'; return 1; }
  mkdir -p /run/lock
  exec 9>"$LOCK_FILE"
  flock -n 9 || { log_error '另一个 Linux-gateway 操作正在运行。'; return 1; }
}
