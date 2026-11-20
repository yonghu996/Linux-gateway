# Probe Server 源码归档分片

本目录保存源码归档的 Base64 分片。单片不超过 2500 字符，避免 GitHub Contents API 对大文本截断。分片顺序与 SHA256 清单由 `archive-index.txt` 固定。CI 会从 Git blob 重组原始 tar.gz，校验 SHA256、检查 tar 路径和文件类型、解包后运行 Gitleaks。不要手工调整分片顺序或内容。
