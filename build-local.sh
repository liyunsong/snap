#!/bin/bash

# Snap - 本地构建脚本（专为 Apple Silicon macOS 26）

set -e

# 颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}  Snap - 本地构建（M1 Pro）${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# 检查系统
ARCH=$(uname -m)
if [ "$ARCH" != "arm64" ]; then
    echo -e "${YELLOW}⚠️  警告: 检测到非 Apple Silicon 架构: $ARCH${NC}"
fi

echo -e "${GREEN}🔨 构建 Snap...${NC}"
swift build -c release --arch arm64

echo ""
echo -e "${GREEN}📦 创建 .app 包...${NC}"
make app

echo ""
echo -e "${GREEN}✅ 构建完成！${NC}"
echo ""
echo -e "${BLUE}📍 应用位置:${NC}"
echo "   .build/release/Snap.app"
echo ""
echo -e "${BLUE}🚀 安装到 Applications:${NC}"
echo "   sudo cp -r .build/release/Snap.app /Applications/"
echo ""
echo -e "${BLUE}🎯 运行应用:${NC}"
echo "   open .build/release/Snap.app"
echo ""
echo -e "${BLUE}或直接安装并运行:${NC}"
echo "   make install"
echo "   open /Applications/Snap.app"
echo ""
