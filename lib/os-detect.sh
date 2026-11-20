#!/usr/bin/env bash
# 发行版识别只读取固定的 /etc/os-release，绝不 source 外部指定文件。
# shellcheck disable=SC2034
read_os_release_value() {
  local KEY="$1" LINE VALUE
  LINE="$(grep -m1 "^${KEY}=" /etc/os-release 2>/dev/null || true)"
  VALUE="${LINE#*=}"
  if [[ ${#VALUE} -ge 2 && ${VALUE:0:1} == '"' && ${VALUE: -1} == '"' ]]; then
    VALUE="${VALUE:1:${#VALUE}-2}"
  elif [[ ${#VALUE} -ge 2 && ${VALUE:0:1} == "'" && ${VALUE: -1} == "'" ]]; then
    VALUE="${VALUE:1:${#VALUE}-2}"
  fi
  printf '%s' "$VALUE"
}
classify_os_support() {
  case "$1:$2" in
    debian:11|debian:12|ubuntu:20.04|ubuntu:22.04) OS_SUPPORTED=yes ;;
    *) OS_SUPPORTED=no ;;
  esac
}
detect_os() {
  OS_ID="$(read_os_release_value ID)"
  OS_VERSION="$(read_os_release_value VERSION_ID)"
  OS_NAME="$(read_os_release_value PRETTY_NAME)"
  OS_CODENAME="$(read_os_release_value VERSION_CODENAME)"
  if [[ -z "$OS_CODENAME" ]]; then OS_CODENAME="$(read_os_release_value UBUNTU_CODENAME)"; fi
  [[ -n "$OS_ID" ]] || OS_ID=unknown
  [[ -n "$OS_VERSION" ]] || OS_VERSION=unknown
  [[ -n "$OS_NAME" ]] || OS_NAME=unknown
  [[ -n "$OS_CODENAME" ]] || OS_CODENAME=unknown
  classify_os_support "$OS_ID" "$OS_VERSION"
  INIT_SYSTEM=unknown
  if command -v systemctl >/dev/null 2>&1 && [[ -d /run/systemd/system ]]; then INIT_SYSTEM=systemd; fi
}
detect_arch() {
  case "$(uname -m 2>/dev/null || printf unknown)" in
    x86_64|amd64) CPU_ARCH=amd64 ;;
    aarch64|arm64) CPU_ARCH=arm64 ;;
    *) CPU_ARCH=unsupported ;;
  esac
}
require_supported_platform() {
  detect_os
  detect_arch
  if [[ "$OS_SUPPORTED" != yes || "$CPU_ARCH" == unsupported || "$INIT_SYSTEM" != systemd ]]; then
    log_error "暂不支持：${OS_ID:-unknown} ${OS_VERSION:-unknown} / ${CPU_ARCH:-unknown} / ${INIT_SYSTEM:-unknown}"
    return 1
  fi
}
