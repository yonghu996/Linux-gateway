#!/usr/bin/env bash
# 探测系统实际能力；不因缺少可选模块而直接判定发行版不兼容。

探测能力() {
  CAP_IPROUTE2=no CAP_NFT=no CAP_CONNTRACK=no CAP_PPP_DEVICE=no CAP_PPP_MODULE=no CAP_L2TP_MODULE=no CAP_SYSTEMD=no CAP_IPV6=no
  command -v ip >/dev/null 2>&1 && CAP_IPROUTE2=yes
  command -v nft >/dev/null 2>&1 && CAP_NFT=yes
  [[ -r /proc/net/nf_conntrack || -r /proc/net/ip_conntrack ]] && CAP_CONNTRACK=yes
  [[ -c /dev/ppp ]] && CAP_PPP_DEVICE=yes
  if command -v modinfo >/dev/null 2>&1 && modinfo ppp_generic >/dev/null 2>&1; then CAP_PPP_MODULE=yes; fi
  if command -v modinfo >/dev/null 2>&1 && modinfo l2tp_ppp >/dev/null 2>&1; then CAP_L2TP_MODULE=yes; fi
  [[ -d /run/systemd/system ]] && CAP_SYSTEMD=yes
  [[ -e /proc/net/if_inet6 ]] && CAP_IPV6=yes
  return 0
}
打印能力() {
  探测能力
  printf '%-20s %s\n' \
    iproute2 "$CAP_IPROUTE2" nftables "$CAP_NFT" conntrack_proc "$CAP_CONNTRACK" \
    ppp_device "$CAP_PPP_DEVICE" ppp_module "$CAP_PPP_MODULE" l2tp_module "$CAP_L2TP_MODULE" \
    systemd "$CAP_SYSTEMD" ipv6 "$CAP_IPV6"
}
