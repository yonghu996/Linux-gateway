# Probe Server v1.1.0-dev 开发与安全自审报告

日期：2026-11-20。对象：`probe-server/source-v1.1.0-dev.tar.gz`，LGP1 新协议。旧 v1.0.1 源码已删除，本版本为重新实现，不承诺旧协议兼容。

## 结论

本地 Go 1.23.2 隔离环境中的功能测试、竞态检测、vet、checkptr、Fuzz、AMD64/ARM64 交叉编译和 systemd 离线模板检查通过。Go 1.23.2 已停止安全支持，所有本地二进制均不得发布；正式 CI 和目标机安装构建使用 Go 1.27.4。Go 1.27.4 CI、govulncheck、gosec、腾讯云公网实测和第三方审计尚未完成，因此这是开发候选，不批准公网生产部署。

## 功能和安全控制

- HTTPS/HTTP：`GET /v1/health`，HMAC 请求与响应签名；拒绝 query、body、非 GET、重复认证头、转义路径和 chunked body。未配置 TLS 时仅允许 loopback。
- TCP：固定 78 字节 LGP1 帧；客户端发送后必须 half-close 写方向；服务端读取第 79 字节拒绝尾随数据；每连接一个请求、8 秒 deadline、默认 512 并发；SIGTERM 时关闭 listener 并等待处理 goroutine。
- UDP：固定 78 字节数据报；默认 2000 PPS、burst 500；响应不大于请求；白名单和 HMAC 校验。
- 身份：每客户端独立 16 字节 Client ID 和至少 32 字节随机密钥；Unix 时间戳容差 120 秒；Nonce 重放缓存默认 100000 条，满时 fail-closed。
- HTTP：默认并发 128、全局 100 RPS/burst 50、请求头 8 KiB、读写超时和 listener 连接数上限。
- 配置：最大 1 MiB，拒绝符号链接、非普通文件、未知 JSON 字段、尾随 JSON 文档；仅接受 0600 或 root:服务组 0640，不允许组写或 other 权限；默认 CIDR 白名单只允许 loopback。
- TLS 文件：必须 root 所有普通文件，拒绝符号链接；私钥不允许组写和 other 访问。
- systemd：专用非 root 用户、空 capabilities、NoNewPrivileges、ProtectSystem=strict、PrivateDevices、PrivateTmp、内存/任务/FD 限制。
- 安装：检查 Debian 11/12、Ubuntu 20.04/22.04 和 AMD64/ARM64；Go 1.27.4 官方 SHA256 校验；构建前测试；配置检查通过后再替换二进制；失败时恢复程序、unit 和原启用状态；不修改防火墙、默认路由、SSH 或内核。

## 本地测试结果

- `go test ./...`：PASS
- `go test -race ./...`：PASS
- `go vet ./...`：PASS
- `GODEBUG=checkptr=2 go test ./...`：PASS
- `go test -cover ./...`：PASS；config 83.9%、protocol 88.0%、server 55.1%；命令入口包未覆盖
- `FuzzParseFrame` 每轮 5 秒：约 25 万次执行，无崩溃
- TCP/UDP 真实回环认证 Echo：PASS
- TCP 并发上限和第 79 字节尾随拒绝：PASS
- HTTP 请求/响应 HMAC、重放拒绝、路径和 body 形状拒绝：PASS
- 配置权限、符号链接、未知字段、超 1 MiB 拒绝：PASS
- TLS 私钥符号链接和组写权限拒绝：PASS
- AMD64/ARM64 静态交叉编译：PASS（Go 1.23.2，仅架构检查，不是发布构建）
- `systemd-analyze verify`：PASS；`systemd-analyze security --offline`：3.0（OK），离线模板检查
- ShellCheck：本地未安装，待 GitHub CI
- Go 1.27.4、govulncheck、gosec：待 GitHub CI
- ARM64 实机、腾讯云公网渗透、真实 SK5/SS/L2TP 节点联调：未执行

## 部署约束

1. 默认只允许 127.0.0.1；远程接入必须配置 TLS 和真实出口 IP 白名单。
2. TCP 与 UDP 出口 IP 可能不同，必须分别采集并纳入 allow_cidrs。
3. 腾讯云安全组只放行实际节点出口到 HTTPS 8443/TCP、9001/TCP、9002/UDP；不要公开明文 8080。
4. 节点轮换需要更新 allow_cidrs 并重启服务；当前无动态热加载。
5. 应用层限速不替代云侧 DDoS 防护。
6. 客户端必须验证 TLS 证书和响应 HMAC，不能只看 HTTP 200。

**发布判定：开发候选；CI 与第三方审核通过、腾讯云公网验收前不批准生产部署。**
