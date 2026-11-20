#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
find "$ROOT" -type f -name '*.sh' -print0 | while IFS= read -r -d '' f; do bash -n "$f"; done
echo '[PASS] Shell syntax'
