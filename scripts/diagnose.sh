#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "$ROOT/lib/common.sh"; source "$ROOT/lib/checks.sh"
require_root
mkdir -p "$LOG_DIR"
out="$LOG_DIR/diagnose-$(date +%Y%m%d-%H%M%S).txt"
{ check_env_report; ip -brief address; ip route show table all; ss -s; ss -lntup; nft list ruleset 2>&1 || true; systemctl --failed --no-pager || true; } | tee "$out"
echo "报告: $out"
