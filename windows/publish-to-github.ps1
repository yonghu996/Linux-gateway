$ErrorActionPreference = 'Stop'
$Repo = 'https://github.com/yonghu996/Linux-gateway.git'
function Stop-Publish([string]$Message) { throw $Message }
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Stop-Publish '请先安装 Git for Windows。' }
if (-not (Get-Command gitleaks -ErrorAction SilentlyContinue)) {
    Stop-Publish '未检测到 Gitleaks。为避免节点账号、密码或密钥误推送，脚本采取失败关闭策略。请先安装 Gitleaks。'
}
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root
if (-not (Test-Path '.git')) { Stop-Publish '当前目录不是 Git 仓库。请先克隆官方仓库。' }
$Origin = (git remote get-url origin).Trim()
if ($Origin -ne $Repo -and $Origin -ne 'git@github.com:yonghu996/Linux-gateway.git') { Stop-Publish "远端地址不匹配，拒绝推送：$Origin" }
$Branch = (git branch --show-current).Trim()
if ($Branch -ne 'main') { Stop-Publish "当前分支为 $Branch；只允许从 main 分支发布。" }

# 发布前确保本地仓库不是浅克隆，否则 --all 仍可能缺失早期历史。
$IsShallow = (git rev-parse --is-shallow-repository).Trim()
if ($LASTEXITCODE -ne 0) { Stop-Publish '无法判断 Git 历史是否完整。' }
if ($IsShallow -eq 'true') {
    git fetch --unshallow --tags origin
    if ($LASTEXITCODE -ne 0) { Stop-Publish '补全 Git 历史失败，拒绝发布。' }
}
git fetch --tags origin
if ($LASTEXITCODE -ne 0) { Stop-Publish '获取远端标签失败，拒绝发布。' }

# 先暂存所有新增、修改和删除，再扫描工作区与完整 Git 历史。
git add -A
if ($LASTEXITCODE -ne 0) { Stop-Publish 'git add 失败。' }
git diff --cached --check
if ($LASTEXITCODE -ne 0) { Stop-Publish '暂存区存在空白或补丁格式错误。' }
gitleaks dir --redact .
if ($LASTEXITCODE -ne 0) { Stop-Publish 'Gitleaks 工作区扫描未通过，已停止发布。' }
gitleaks git --redact --log-opts="--all" .
if ($LASTEXITCODE -ne 0) { Stop-Publish 'Gitleaks 全历史扫描未通过，已停止发布。' }

if (-not (git diff --cached --quiet)) {
    git commit -m 'chore: 发布 Linux-gateway 框架'
    if ($LASTEXITCODE -ne 0) { Stop-Publish 'git commit 失败。' }
}
git push -u origin main
if ($LASTEXITCODE -ne 0) { Stop-Publish '推送失败。' }
Write-Host '发布成功：完整历史检查、工作区扫描、暂存区检查和 Git 推送均已完成。' -ForegroundColor Green
