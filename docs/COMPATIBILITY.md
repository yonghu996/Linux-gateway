# 系统兼容策略

目标系统：Debian 11、Debian 12、Ubuntu 20.04 LTS、Ubuntu 22.04 LTS。目标架构：AMD64 与 ARM64。

发行版版本识别和内核能力检测分离。必须独立检查 systemd、iproute2、nftables、conntrack、PPP、L2TP、IPv6、`/dev/ppp` 和相关模块。

CI 容器测试只能证明脚本在对应用户空间环境中执行；无法证明宿主内核模块、PPP 设备、路由行为或真实数据平面可用。生产认证需要对应发行版/架构的真实 VM 验收。

Debian 11 与 Ubuntu 20.04 在 2026 年应确认适用的安全维护/ESM 覆盖。可安装运行不代表仍处于标准安全支持期。
