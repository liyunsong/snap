#!/bin/bash
# Snap 首次打开助手
# 绕过 macOS Gatekeeper「未打开 Snap.app / Apple 无法验证」提示后启动应用。
# 本应用未经过 Apple 公证（开源免费分发），下载后需要手动允许一次。

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -d "/Applications/Snap.app" ]; then
  APP="/Applications/Snap.app"
elif [ -d "$DIR/Snap.app" ]; then
  APP="$DIR/Snap.app"
else
  osascript <<'EOF' 2>/dev/null || true
display dialog "未找到 Snap.app。

请先将 Snap 拖到「应用程序」文件夹，然后再双击本脚本。" buttons {"好"} default button 1 with title "Snap" with icon caution
EOF
  exit 1
fi

# 检查应用是否在可写文件系统上（DMG 是只读的）
if [ ! -w "$APP" ]; then
  osascript <<'EOF' 2>/dev/null || true
display dialog "Snap.app 位于只读磁盘映像（DMG）上，无法清除隔离属性。

请先将 Snap 拖到「应用程序」文件夹，然后再双击本脚本。" buttons {"好"} default button 1 with title "Snap" with icon caution
EOF
  exit 1
fi

# 清除隔离属性（下载自互联网时由浏览器写入）
xattr -cr "$APP" 2>/dev/null || true

open "$APP"

osascript <<EOF 2>/dev/null || true
display notification "已允许打开 Snap，请在菜单栏查找 📷 图标" with title "Snap"
EOF
