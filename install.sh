#!/bin/bash
# Download the Chinese DMG and open its drag-to-install window.
set -euo pipefail
if [ "$(uname -s)" != Darwin ] || [ "$(uname -m)" != arm64 ]; then
  echo '需要 Apple 芯片 Mac。' >&2
  exit 1
fi
name='RemoveMacAI-1.0.1-zh-Hans.1-arm64.dmg'
base='https://github.com/nextwa/RemoveMacAI/releases/download/v1.0.1-zh-Hans.1'
folder="$(mktemp -d -t removemacai-install)"
curl -fL "$base/$name" -o "$folder/$name"
open "$folder/$name"
printf '请将中文版应用拖入 Applications。安装映像：%s\n' "$folder/$name"
