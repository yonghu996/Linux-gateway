$ErrorActionPreference = 'Stop'
$Repo = 'https://github.com/yonghu996/Linux-gateway.git'
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw '请先安装 Git for Windows。' }
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root
if (-not (Test-Path '.git')) { git init; git branch -M main; git remote add origin $Repo }
$Origin = git remote get-url origin
if ($Origin -ne $Repo -and $Origin -ne 'git@github.com:yonghu996/Linux-gateway.git') { throw "远端地址不匹配，拒绝推送：$Origin" }
$SecretPatterns = 'PROBE_SECRET\s*=\s*[^\s#]+|password\s*[:=]\s*[^\s#]+'
$Tracked = git ls-files
foreach ($File in $Tracked) { if (Test-Path $File) { $Text = Get-Content -Raw $File; if ($Text -match $SecretPatterns) { throw "检测到疑似凭据：$File" } } }
git add .
git diff --cached --check
if (-not (git diff --cached --quiet)) { git commit -m 'chore: 发布 Linux-gateway 框架' }
git push -u origin main
