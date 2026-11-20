#!/usr/bin/env bash
set -Eeuo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)/lib/os-detect.sh"
for spec in 'debian 11 yes' 'debian 12 yes' 'ubuntu 20.04 yes' 'ubuntu 22.04 yes' 'ubuntu 24.04 no'; do
 read -r id version expected <<<"$spec"
 tmp="$(mktemp)"; printf 'ID=%s\nVERSION_ID="%s"\n' "$id" "$version" >"$tmp"
 OS_RELEASE_FILE="$tmp" detect_os; rm -f "$tmp"
 [[ $OS_SUPPORTED == "$expected" ]] || { echo "FAIL $spec"; exit 1; }
done
echo '[PASS] OS matrix'
