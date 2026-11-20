#!/usr/bin/env bash
check_env_report() {
 detect_os; detect_arch
 printf 'OS: %s (%s %s)\nKernel: %s\nArch: %s\nInit: %s\n' "$OS_PRETTY_NAME" "$OS_ID" "$OS_VERSION_ID" "$(uname -r)" "$ARCH" "$INIT_SYSTEM"
 printf 'CPU: %s\n' "$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo unknown)"
 awk '/MemTotal/ {printf "Memory: %.2f GiB\n",$2/1048576}' /proc/meminfo
 df -hP /
 for c in ip ss nft conntrack modprobe systemctl; do command -v "$c" >/dev/null && echo "[OK] $c" || echo "[INFO] $c unavailable"; done
 [[ -e /dev/ppp ]] && echo '[OK] /dev/ppp' || echo '[INFO] /dev/ppp unavailable'
 echo "OS_SUPPORTED=$OS_SUPPORTED"
}
