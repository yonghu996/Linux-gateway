#!/usr/bin/env bash
set -Eeuo pipefail
for UNIT in linux-gateway.service linux-gateway-probe.service; do
  printf '\n===== %s =====\n' "$UNIT"
  systemctl --no-pager status "$UNIT" 2>&1 || true
done
