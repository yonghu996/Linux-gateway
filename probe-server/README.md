# Probe Server v1.1.0-dev（LGP1）

本目录发布全新重写的探测服务器源码归档。由于旧 Probe Server v1.0.1 源码已丢失，本版本不承诺与旧版协议兼容；新 Probe Client 必须按归档中的 `docs/LGP1-协议规范.md` 实现。

- 源码归档：`source-v1.1.0-dev.tar.gz`
- 校验文件：`source-v1.1.0-dev.tar.gz.sha256`
- Go 工具链：1.27.4（正式 CI 和目标机安装构建）
- 支持目标：Debian 11/12、Ubuntu 20.04/22.04；AMD64/ARM64
- 部署入口：归档内 `install.sh`，独立部署在腾讯云 Debian B
- 默认 HTTP 仅监听本机；TCP/UDP 来源受 CIDR 白名单控制

## 解包与验证

```bash
sha256sum -c source-v1.1.0-dev.tar.gz.sha256
tar -xzf source-v1.1.0-dev.tar.gz
cd probe-server-v1.1.0
bash ci/validate.sh
```

该版本是开发候选，不是生产发布。Go 1.27.4、govulncheck、gosec 和 CI 全部通过，并完成腾讯云公网验收及第三方审核前，不得部署到公网生产环境。
