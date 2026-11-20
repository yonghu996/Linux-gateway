#!/usr/bin/env bash
# Linux-gateway 唯一交互式入口。
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib/common.sh
source "$ROOT_DIR/lib/common.sh"
# shellcheck source=lib/os-detect.sh
source "$ROOT_DIR/lib/os-detect.sh"
# shellcheck source=lib/capabilities.sh
source "$ROOT_DIR/lib/capabilities.sh"
# shellcheck source=lib/checks.sh
source "$ROOT_DIR/lib/checks.sh"

显示菜单() {
  clear 2>/dev/null || true
  printf '\n==============================================\n'
  printf '       Linux 多出口网关管理中心\n'
  printf '       版本：%s\n' "$(获取版本)"
  printf '       系统：%s | 架构：%s\n' "$OS_NAME" "$CPU_ARCH"
  printf '==============================================\n'
  cat <<'菜单'
  1. 系统环境检测（只读）
  2. 环境修复计划（暂不自动修改）
  3. 安装主核心网关（尚未发布）
  4. 安装 Probe Client（尚未发布）
  5. 查看服务状态
  6. 故障诊断与日志
  7. 从 GitHub 检查更新
  8. 回滚（尚未安装生产版本）
  9. 卸载（尚未安装生产版本）
  0. 退出
菜单
}
主程序() {
  识别系统
  识别架构
  if [[ "${1:-}" == --check ]]; then 环境检测报告; return; fi
  if [[ "${1:-}" == --diagnose ]]; then bash "$ROOT_DIR/scripts/diagnose.sh"; return; fi
  检查平台支持 || return 1
  需要_root || return 1
  获取锁 || return 1
  while true; do
    显示菜单
    read -r -p '请选择功能 [0-9]：' CHOICE || CHOICE=0
    case "$CHOICE" in
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
      *) 日志警告 '无效选项。' ;;
    esac
    read -r -p '按回车返回菜单...' _ || true
  done
}
主程序 "$@"
