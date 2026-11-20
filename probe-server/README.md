# Probe Server v1.1.0-dev（LGP1）

本目录保存重新开发的 Probe Server 源码归档。旧版 v1.0.1 源码已丢失，本版本不承诺旧协议兼容；Probe Client 必须使用归档内的 `docs/LGP1-协议规范.md`。

- 源码归档：`source-v1.1.0-dev.tar.gz`
- SHA256：`source-v1.1.0-dev.tar.gz.sha256`
- Go 工具链：1.27.4
- 目标系统：Debian 11/12、Ubuntu 20.04/22.04
- 目标架构：Linux AMD64（明确不提供 ARM64 适配）
- 部署入口：归档内 `install.sh`，独立部署于腾讯云 Debian B
- 默认 HTTP 仅监听本机；TCP/UDP 来源受 CIDR 白名单控制

## 解包与验证

```bash
sha256sum -c source-v1.1.0-dev.tar.gz.sha256
mkdir -p src
tar -xzf source-v1.1.0-dev.tar.gz --strip-components=1 -C src
cd src
sha256sum -c SOURCE-MANIFEST.sha256
bash ci/validate.sh
```

该版本是开发候选，不是生产发布。Go 1.27.4、govulncheck、gosec 和 GitHub CI 全部通过，并完成腾讯云公网验收及第三方审核前，不得部署到公网生产环境。
