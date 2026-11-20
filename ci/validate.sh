#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
bash "$ROOT/tests/shell-smoke.sh"
bash "$ROOT/tests/os-matrix.sh"
