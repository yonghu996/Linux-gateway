#!/usr/bin/env bash
# 只读环境检测报告。

环境检测报告() {
  识别系统
  识别架构
  探测能力
  printf '\n========== 系统信息 ==========\n'
  printf '系统：%s\nID/版本：%s %s\n代号：%s\n内核：%s\n架构：%s\n初始化：%s\n' \
    "$OS_NAME" "$OS_ID" "$OS_VERSION" "$OS_CODENAME" "$(uname -r)" "$CPU_ARCH" "$INIT_SYSTEM"
  printf '\n========== 资源信息 ==========\n'
  printf 'CPU：%s vCPU\n' "$(getconf _NPROCESSORS_ONLN 2>/dev/null || printf unknown)"
  awk '/MemTotal/ {printf "内存：%.2f GiB\n", $2/1048576}' /proc/meminfo 2>/dev/null || true
  df -hT / 2>/dev/null || true
  printf '\n========== 网络能力 ==========\n'
  打印能力
  printf '\n========== 网络接口与路由 ==========\n'
  command -v ip >/dev/null 2>&1 && { ip -brief address; ip -4 route show table all; ip -6 route show table all; ip rule show; } || 日志警告 '未发现 iproute2。'
  printf '\n========== 防火墙（只读） ==========\n'
  command -v nft >/dev/null 2>&1 && nft list ruleset 2>&1 || true
  printf '\n========== 监听端口 ==========\n'
  command -v ss >/dev/null 2>&1 && ss -lntup || true
  printf '\n========== 平台判断 ==========\n'
  printf '目标发行版：%s\n' "$OS_SUPPORTED"
  printf '目标架构：%s\n' "$([[ "$CPU_ARCH" != unsupported ]] && printf yes || printf no)"
  printf '说明：以上为能力探测，不代表已完成该组合的真实生产认证。\n'
}
