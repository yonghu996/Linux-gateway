#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
source "$ROOT_DIR/lib/common.sh"
source "$ROOT_DIR/lib/os-detect.sh"
source "$ROOT_DIR/lib/checks.sh"
require_root
detect_os
detect_arch
show_banner() {
  printf '\nLinux Gateway | Shell-first framework | v%s\n' "$(project_version)"
  printf 'OS: %s | Arch: %s\n\n' "$OS_PRETTY_NAME" "$ARCH"
}
menu() {
  cat <<'EOF'
1) 系统环境检测
2) 环境修复计划
3) 安装 Gateway Core
4) 安装 Probe Client
5) 服务状态与日志
6) 故障诊断
7) GitHub 更新
8) 回滚
9) 卸载
0) 退出
EOF
}
main() {
  require_supported_platform || exit 1
  show_banner
  [[ "${1:-}" == "--check" ]] && { check_env_report; return; }
  acquire_lock
  while true; do
    menu
    read -r -p "请选择: " choice || choice=0
    case "$choice" in
      1) bash "$ROOT_DIR/scripts/check-env.sh" ;;
      2) bash "$ROOT_DIR/scripts/repair-env.sh" --plan ;;
      3) bash "$ROOT_DIR/scripts/install-core.sh" ;;
      4) bash "$ROOT_DIR/scripts/install-probe.sh" ;;
      5) bash "$ROOT_DIR/scripts/service.sh" ;;
      6) bash "$ROOT_DIR/scripts/diagnose.sh" ;;
      7) bash "$ROOT_DIR/scripts/update.sh" ;;
      8) bash "$ROOT_DIR/scripts/rollback.sh" ;;
      9) bash "$ROOT_DIR/scripts/uninstall.sh" ;;
      0) break ;;
      *) log_warn "无效选项" ;;
    esac
    read -r -p "按回车继续..." _ || true
  done
}
show_banner
main "$@"
