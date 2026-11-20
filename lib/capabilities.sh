#!/usr/bin/env bash
# 探测系统实际能力；可选能力缺失不等于发行版不兼容。
# shellcheck disable=SC2034
detect_capabilities() {
  CAP_IPROUTE2=no CAP_NFT=no CAP_CONNTRACK=no CAP_PPP_DEVICE=no CAP_PPP_MODULE=no CAP_L2TP_MODULE=no CAP_SYSTEMD=no CAP_IPV6=no
  command -v ip >/dev/null 2>&1 && CAP_IPROUTE2=yes
  command -v nft >/dev/null 2>&1 && CAP_NFT=yes
  if [[ -e /sys/module/nf_conntrack ]] || { command -v modinfo >/dev/null 2>&1 && modinfo nf_conntrack >/dev/null 2>&1; } || command -v conntrack >/dev/null 2>&1; then CAP_CONNTRACK=yes; fi
  [[ -c /dev/ppp ]] && CAP_PPP_DEVICE=yes
  if command -v modinfo >/dev/null 2>&1 && modinfo ppp_generic >/dev/null 2>&1; then CAP_PPP_MODULE=yes; fi
  if command -v modinfo >/dev/null 2>&1 && modinfo l2tp_ppp >/dev/null 2>&1; then CAP_L2TP_MODULE=yes; fi
  [[ -d /run/systemd/system ]] && CAP_SYSTEMD=yes
  [[ -e /proc/net/if_inet6 ]] && CAP_IPV6=yes
}
print_capabilities() {
  detect_capabilities
  printf '%-20s %s\n' \
    iproute2 "$CAP_IPROUTE2" nftables "$CAP_NFT" conntrack "$CAP_CONNTRACK" \
    ppp_device "$CAP_PPP_DEVICE" ppp_module "$CAP_PPP_MODULE" l2tp_module "$CAP_L2TP_MODULE" \
    systemd "$CAP_SYSTEMD" ipv6 "$CAP_IPV6"
}
