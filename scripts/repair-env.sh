#!/usr/bin/env bash
set -Eeuo pipefail
printf '环境修复计划（当前版本只生成计划，不自动安装或修改系统）\n'
printf '%s\n' '可能的后续依赖：iproute2、nftables、conntrack-tools、ppp、ca-certificates。'
printf '%s\n' '内核模块、转发、路由、防火墙和 SSH 策略必须独立评估。'
printf '%s\n' '本次未执行 apt、sysctl、ip、nft 或 systemctl 修改命令。'
