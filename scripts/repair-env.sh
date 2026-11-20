#!/usr/bin/env bash
set -Eeuo pipefail
echo '环境修复目前仅提供审查计划；不会自动安装包或修改路由、防火墙、sysctl。'
[[ "${1:-}" == --plan ]] && exit 0
echo '实际修复功能将在逐项备份与回滚实现后启用。'
