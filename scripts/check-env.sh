#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "$ROOT/lib/common.sh"; source "$ROOT/lib/os-detect.sh"; source "$ROOT/lib/checks.sh"
require_root
check_env_report
