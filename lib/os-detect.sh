#!/usr/bin/env bash
detect_os() {
  OS_ID=unknown OS_VERSION_ID=unknown OS_PRETTY_NAME=unknown OS_CODENAME=unknown
  [[ -r ${OS_RELEASE_FILE:-/etc/os-release} ]] && { . "${OS_RELEASE_FILE:-/etc/os-release}"; OS_ID=${ID:-unknown}; OS_VERSION_ID=${VERSION_ID:-unknown}; OS_PRETTY_NAME=${PRETTY_NAME:-unknown}; OS_CODENAME=${VERSION_CODENAME:-${UBUNTU_CODENAME:-unknown}}; }
  case "$OS_ID:$OS_VERSION_ID" in debian:11|debian:12|ubuntu:20.04|ubuntu:22.04) OS_SUPPORTED=yes;; *) OS_SUPPORTED=no;; esac
  INIT_SYSTEM=unknown
  command -v systemctl >/dev/null 2>&1 && [[ -d /run/systemd/system ]] && INIT_SYSTEM=systemd
}
detect_arch() { case "$(uname -m)" in x86_64|amd64) ARCH=amd64;; aarch64|arm64) ARCH=arm64;; *) ARCH=unsupported;; esac; }
require_supported_platform() { detect_os; detect_arch; [[ $OS_SUPPORTED == yes && $ARCH != unsupported && $INIT_SYSTEM == systemd ]] || { log_error "不支持的平台或缺少 systemd: $OS_ID $OS_VERSION_ID $ARCH"; return 1; }; }
