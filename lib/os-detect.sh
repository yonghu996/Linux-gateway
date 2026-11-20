#!/usr/bin/env bash
# 发行版与 CPU 架构识别。能力探测与发行版名称分开处理。
# shellcheck disable=SC2034

识别系统() {
  OS_ID=unknown OS_VERSION=unknown OS_NAME=unknown OS_CODENAME=unknown
  local OS_FILE="${OS_RELEASE_FILE:-/etc/os-release}"
  if [[ -r "$OS_FILE" ]]; then
    # shellcheck disable=SC1090
    . "$OS_FILE"
    OS_ID="${ID:-unknown}"
    OS_VERSION="${VERSION_ID:-unknown}"
    OS_NAME="${PRETTY_NAME:-unknown}"
    OS_CODENAME="${VERSION_CODENAME:-${UBUNTU_CODENAME:-unknown}}"
  fi
  case "$OS_ID:$OS_VERSION" in
    debian:11|debian:12|ubuntu:20.04|ubuntu:22.04) OS_SUPPORTED=yes ;;
    *) OS_SUPPORTED=no ;;
  esac
  INIT_SYSTEM=unknown
  if command -v systemctl >/dev/null 2>&1 && [[ -d /run/systemd/system ]]; then
    INIT_SYSTEM=systemd
  fi
}
识别架构() {
  case "$(uname -m 2>/dev/null || printf unknown)" in
    x86_64|amd64) CPU_ARCH=amd64 ;;
    aarch64|arm64) CPU_ARCH=arm64 ;;
    *) CPU_ARCH=unsupported ;;
  esac
}
检查平台支持() {
  识别系统
  识别架构
  if [[ "$OS_SUPPORTED" != yes || "$CPU_ARCH" == unsupported || "$INIT_SYSTEM" != systemd ]]; then
    日志错误 "暂不支持：${OS_ID:-unknown} ${OS_VERSION:-unknown} / ${CPU_ARCH:-unknown} / ${INIT_SYSTEM:-unknown}"
    return 1
  fi
}
