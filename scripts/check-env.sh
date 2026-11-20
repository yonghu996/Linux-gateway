#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
# shellcheck disable=SC1091
source "$ROOT_DIR/lib/common.sh"
# shellcheck disable=SC1091
source "$ROOT_DIR/lib/os-detect.sh"
# shellcheck disable=SC1091
source "$ROOT_DIR/lib/capabilities.sh"
# shellcheck disable=SC1091
source "$ROOT_DIR/lib/checks.sh"
require_root
print_environment_report
