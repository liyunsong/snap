#!/bin/bash

# Snap Release Script
# 用于手动创建 GitHub Release

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
APP_NAME="Snap"
VERSION=""
GITHUB_REPO="liyunsong/snap"

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}  Snap - GitHub Release Creator${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# 检查是否安装 gh CLI
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) 未安装${NC}"
    echo -e "${YELLOW}请访问: https://cli.github.com/ 安装${NC}"
    echo -e "或运行: brew install gh"
    exit 1
fi

# 检查是否登录
if ! gh auth status &> /dev/null; then
    echo -e "${RED}❌ 未登录 GitHub${NC}"
    echo -e "${YELLOW}请运行: gh auth login${NC}"
    exit 1
fi

# 获取版本号
if [ -z "$1" ]; then
    echo -e "${YELLOW}请输入版本号 (例如: 1.0.0):${NC}"
    read VERSION
else
    VERSION="$1"
fi

# 验证版本号格式
if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}❌ 版本号格式错误。应为: X.Y.Z (例如: 1.0.0)${NC}"
    exit 1
fi

TAG="v${VERSION}"

echo ""
echo -e "${BLUE}📦 准备创建 Release: ${TAG}${NC}"
echo ""

# 检查标签是否已存在
if git rev-parse "$TAG" >/dev/null 2>&1; then
    echo -e "${RED}❌ 标签 ${TAG} 已存在${NC}"
    echo -e "${YELLOW}请使用不同的版本号或删除现有标签:${NC}"
    echo -e "   git tag -d ${TAG}"
    echo -e "   git push origin :refs/tags/${TAG}"
    exit 1
fi

# 确保在正确的分支
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${BLUE}当前分支: ${CURRENT_BRANCH}${NC}"

# 确保代码是最新的
echo -e "${YELLOW}📥 拉取最新代码...${NC}"
git pull

# 清理之前的构建
echo -e "${YELLOW}🧹 清理之前的构建...${NC}"
make clean

# 构建发布版本
echo ""
echo -e "${GREEN}🔨 开始构建...${NC}"
make release

# 检查构建产物
BUILD_DIR=".build/release"
ZIP_FILE="${BUILD_DIR}/${APP_NAME}-${VERSION}.zip"
DMG_FILE="${BUILD_DIR}/${APP_NAME}-${VERSION}.dmg"

if [ ! -f "$ZIP_FILE" ]; then
    echo -e "${RED}❌ ZIP 文件不存在: ${ZIP_FILE}${NC}"
    exit 1
fi

if [ ! -f "$DMG_FILE" ]; then
    echo -e "${RED}❌ DMG 文件不存在: ${DMG_FILE}${NC}"
    exit 1
fi

# 显示文件信息
echo ""
echo -e "${GREEN}✅ 构建成功！${NC}"
echo ""
echo -e "${BLUE}📦 构建产物:${NC}"
ls -lh "$ZIP_FILE"
ls -lh "$DMG_FILE"
echo ""

# 计算文件哈希
echo -e "${BLUE}🔐 计算文件哈希...${NC}"
ZIP_SHA256=$(shasum -a 256 "$ZIP_FILE" | awk '{print $1}')
DMG_SHA256=$(shasum -a 256 "$DMG_FILE" | awk '{print $1}')

echo "ZIP SHA256: $ZIP_SHA256"
echo "DMG SHA256: $DMG_SHA256"
echo ""

# 更新 RELEASE_NOTES.md 中的版本号
if [ -f "RELEASE_NOTES.md" ]; then
    sed -i.bak "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v${VERSION}/g" RELEASE_NOTES.md
    rm -f RELEASE_NOTES.md.bak
fi

# 确认发布
echo -e "${YELLOW}❓ 是否创建 Git 标签并推送? (y/N)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${BLUE}🏷️  创建标签 ${TAG}...${NC}"
    git tag -a "$TAG" -m "Release version ${VERSION}"
    
    echo -e "${BLUE}📤 推送标签到 GitHub...${NC}"
    git push origin "$TAG"
else
    echo -e "${YELLOW}⚠️  跳过标签创建${NC}"
fi

echo ""
echo -e "${YELLOW}❓ 是否创建 GitHub Release? (y/N)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${BLUE}🚀 创建 GitHub Release...${NC}"
    
    # 创建临时发布说明文件（包含哈希）
    TEMP_NOTES=$(mktemp)
    cat RELEASE_NOTES.md > "$TEMP_NOTES"
    echo "" >> "$TEMP_NOTES"
    echo "## 🔐 文件校验" >> "$TEMP_NOTES"
    echo "" >> "$TEMP_NOTES"
    echo "### SHA256 校验和" >> "$TEMP_NOTES"
    echo "" >> "$TEMP_NOTES"
    echo "\`\`\`" >> "$TEMP_NOTES"
    echo "ZIP: $ZIP_SHA256" >> "$TEMP_NOTES"
    echo "DMG: $DMG_SHA256" >> "$TEMP_NOTES"
    echo "\`\`\`" >> "$TEMP_NOTES"
    
    # 使用 gh CLI 创建 Release
    gh release create "$TAG" \
        "$ZIP_FILE" \
        "$DMG_FILE" \
        --title "${APP_NAME} ${TAG}" \
        --notes-file "$TEMP_NOTES" \
        --repo "$GITHUB_REPO"
    
    rm -f "$TEMP_NOTES"
    
    echo ""
    echo -e "${GREEN}✅ GitHub Release 创建成功！${NC}"
    echo ""
    echo -e "${BLUE}🔗 Release URL:${NC}"
    echo "   https://github.com/${GITHUB_REPO}/releases/tag/${TAG}"
else
    echo -e "${YELLOW}⚠️  跳过 GitHub Release 创建${NC}"
    echo ""
    echo -e "${BLUE}手动创建 Release:${NC}"
    echo "   gh release create ${TAG} \\"
    echo "     ${ZIP_FILE} \\"
    echo "     ${DMG_FILE} \\"
    echo "     --title '${APP_NAME} ${TAG}' \\"
    echo "     --notes-file RELEASE_NOTES.md"
fi

echo ""
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}  🎉 Release 流程完成！${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""
echo -e "${BLUE}下一步:${NC}"
echo "  1. 访问 https://github.com/${GITHUB_REPO}/releases"
echo "  2. 验证 Release 信息"
echo "  3. 如有需要，编辑 Release 说明"
echo "  4. 分享给用户！"
echo ""
