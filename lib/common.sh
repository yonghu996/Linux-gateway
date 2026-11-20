#!/usr/bin/env bash
PROJECT_NAME=linux-gateway
PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
STATE_DIR=/var/lib/linux-gateway
LOG_DIR=/var/log/linux-gateway
LOCK_FILE=/run/lock/linux-gateway-installer.lock
project_version() { cat "$PROJECT_ROOT/VERSION" 2>/dev/null || echo 0.1.0-dev; }
log_info() { printf '[INFO] %s\n' "$*"; }
log_warn() { printf '[WARN] %s\n' "$*" >&2; }
log_error() { printf '[ERROR] %s\n' "$*" >&2; }
require_root() { [[ $EUID -eq 0 ]] || { log_error '请使用 root 运行'; exit 1; }; }
confirm() { local a; read -r -p "${1:-继续?} [y/N]: " a || true; [[ "$a" =~ ^([Yy]|[Yy][Ee][Ss])$ ]]; }
acquire_lock() { command -v flock >/dev/null || { log_error '缺少 flock'; exit 1; }; mkdir -p /run/lock; exec 9>"$LOCK_FILE"; flock -n 9 || { log_error '另一个操作正在运行'; exit 1; }; }
