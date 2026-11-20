#!/usr/bin/env bash
set -Eeuo pipefail
for unit in linux-gateway.service linux-gateway-probe.service; do systemctl --no-pager status "$unit" || true; done
