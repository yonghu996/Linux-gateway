#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
if ! command -v git >/dev/null 2>&1 || [[ ! -d "$ROOT_DIR/.git" ]]; then
  echo '当前目录不是 Git 工作树，无法安全检查更新。' >&2; exit 2
fi
REMOTE_URL="$(git -C "$ROOT_DIR" remote get-url origin 2>/dev/null || true)"
[[ "$REMOTE_URL" == 'https://github.com/yonghu996/Linux-gateway.git' || "$REMOTE_URL" == 'git@github.com:yonghu996/Linux-gateway.git' ]] || { echo 'origin 与预期仓库不一致，拒绝更新。' >&2; exit 3; }
if [[ -n "$(git -C "$ROOT_DIR" status --porcelain)" ]]; then
  echo '工作区存在未提交更改，拒绝更新。' >&2; exit 4
fi
git -C "$ROOT_DIR" fetch --tags origin
printf '当前版本：%s\n' "$(git -C "$ROOT_DIR" describe --tags --always 2>/dev/null || git -C "$ROOT_DIR" rev-parse --short HEAD)"
printf '远端 main：%s\n' "$(git -C "$ROOT_DIR" rev-parse --short origin/main)"
echo '当前版本只检查更新，不自动覆盖本地修改。正式升级器将在版本制品校验和回滚实现后启用。'
