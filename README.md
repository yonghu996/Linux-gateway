# Linux-gateway（Linux 多出口网关）

面向 Debian / Ubuntu 的通用多协议出口网关项目。**Shell 是统一安装与运维入口，Go 用于长期运行的高并发服务。**

## 支持目标

- Debian 11、Debian 12
- Ubuntu 20.04 LTS、Ubuntu 22.04 LTS
- Linux AMD64（x86_64）、ARM64（aarch64）
- 使用 systemd 的主机

> 发行版识别通过不等于全部功能已认证。nftables、conntrack、PPP/L2TP、IPv6 等能力必须逐项探测；每个系统/架构组合须经过 CI 和真实虚拟机验收后，才能标记为生产认证。

## 设计原则

1. `install.sh` 是唯一交互式入口；子脚本只由入口调用，也可用于自动化诊断。
2. Shell 负责系统识别、能力检测、依赖计划、备份、部署、升级、回滚、诊断和卸载。
3. Go 负责网关控制面、连接调度、协议适配和探测客户端等常驻服务。
4. 默认只读检测。修复必须展示计划并取得明确确认。
5. 禁止通用安装流程静默替换默认路由、清空防火墙、开启转发、修改 SSH 策略或更换内核。
6. 节点账号、密码、密钥、证书和运行数据库不得提交到 Git。
7. 当前版本是 Shell 框架，不包含可用于生产的 Gateway Core / Probe Client 二进制；菜单会明确提示尚未发布，不会伪装成已安装。

## 快速开始

```bash
git clone https://github.com/yonghu996/Linux-gateway.git
cd Linux-gateway
sudo bash install.sh
```

只读环境检测：

```bash
sudo bash install.sh --check
```

生成诊断报告：

```bash
sudo bash install.sh --diagnose
```

本地验证：

```bash
bash ci/validate.sh
```

## 目录

- `install.sh`：唯一交互式菜单入口
- `lib/`：通用函数、发行版识别、能力检测
- `scripts/`：检测、修复计划、安装、服务、升级、回滚、卸载、诊断
- `configs/`：不含真实凭据的配置模板
- `systemd/`：服务单元模板
- `tests/`：Shell 与系统识别测试
- `.github/workflows/`：四发行版 CI 矩阵
- `docs/`：架构、兼容、安全和运维约定

## 安全

默认不开放任何网络监听端口。管理 API 应绑定可信管理网段；探测服务使用 TLS、请求认证、限流和来源控制。不要在 issue、日志或 Git 中粘贴代理账号密码及 HMAC 密钥。
