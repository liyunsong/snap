# 打包和发布系统 - 使用指南

## 🎉 打包系统已完成！

我已经为 Snap 创建了完整的打包和发布系统。现在你可以轻松地将应用发布到 GitHub Release。

## 📦 已创建的文件

### 核心文件
1. **Makefile** - 构建系统
   - `make release` - 完整发布构建
   - `make app` - 创建 .app 包
   - `make zip` - 创建 ZIP 归档
   - `make dmg` - 创建 DMG 安装包

2. **scripts/release.sh** - 自动发布脚本
   - 一键创建 GitHub Release
   - 自动构建和上传文件
   - 计算文件哈希

3. **.github/workflows/release.yml** - GitHub Actions
   - 推送标签自动触发构建
   - CI/CD 自动化发布

### 文档文件
4. **QUICK_START.md** - 5分钟快速开始指南
5. **RELEASE_GUIDE.md** - 完整发布指南
6. **RELEASE_NOTES.md** - 发布说明模板

## 🚀 三种发布方式

### 方式一：最快方式（推荐）⚡

```bash
# 1. 安装 GitHub CLI（仅首次需要）
brew install gh
gh auth login

# 2. 运行发布脚本
./scripts/release.sh 1.0.0
```

就这么简单！脚本会自动完成所有工作。

### 方式二：使用 Makefile 🛠️

```bash
# 1. 构建发布版本
make release

# 2. 手动创建 GitHub Release
gh release create v1.0.0 \
  .build/release/Snap-1.0.0.zip \
  .build/release/Snap-1.0.0.dmg \
  --title "Snap v1.0.0" \
  --notes-file RELEASE_NOTES.md
```

### 方式三：GitHub Actions 自动化 🤖

```bash
# 1. 创建并推送标签
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# 2. GitHub Actions 自动构建和发布
# 访问: https://github.com/liyunsong/snap/actions
```

## 📋 Makefile 命令一览

```bash
make help        # 显示所有可用命令
make build       # 构建 Swift 可执行文件
make app         # 创建 .app 包
make zip         # 创建 ZIP 归档
make dmg         # 创建 DMG 安装包
make release     # 完整发布构建（推荐）
make install     # 安装到 /Applications
make clean       # 清理构建产物
```

## 🎯 推荐发布流程

### 首次发布（v1.0.0）

```bash
# 1. 确保代码已提交
git add .
git commit -m "Ready for v1.0.0 release"
git push

# 2. 运行发布脚本
./scripts/release.sh 1.0.0

# 3. 验证 Release
# 访问: https://github.com/liyunsong/snap/releases
```

### 后续发布（v1.1.0, v1.2.0...）

```bash
# 1. 更新版本号
# 编辑 RELEASE_NOTES.md

# 2. 提交并发布
git add .
git commit -m "Bump version to 1.1.0"
git push

./scripts/release.sh 1.1.0
```

## 📦 构建产物说明

运行 `make release` 后，会在 `.build/release/` 目录生成：

### 1. Snap.app
- 完整的 macOS 应用包
- 包含所有必需文件和资源
- 可直接拖到 Applications 文件夹

### 2. Snap-1.0.0.zip
- ZIP 压缩包
- 适合快速分发
- 文件较小（通常 < 5MB）
- 用户解压即可使用

### 3. Snap-1.0.0.dmg
- DMG 磁盘镜像
- 专业的 macOS 安装包
- 包含拖拽安装界面
- 推荐用于正式发布

## 🔍 验证构建

发布前务必测试：

```bash
# 1. 构建应用
make release

# 2. 测试 .app
open .build/release/Snap.app

# 3. 测试功能
# - 菜单栏图标
# - 截图功能
# - 编辑工具
# - 保存/复制

# 4. 检查文件大小
ls -lh .build/release/
```

## 📝 版本号规范

使用语义化版本（Semantic Versioning）：

- **1.0.0** - 首个正式版本
- **1.1.0** - 添加新功能（向后兼容）
- **1.0.1** - 修复 Bug（向后兼容）
- **2.0.0** - 重大更新（可能不兼容）

## ⚠️ 重要提示

### 首次运行前

确保用户知道需要：

1. **授予屏幕录制权限**
   - 系统设置 → 隐私与安全性 → 屏幕录制
   - 勾选 "Snap"

2. **允许打开应用**（如果未签名）
   - 右键 → 打开
   - 或: `xattr -cr /Applications/Snap.app`

### 代码签名（可选但推荐）

如果你有 Apple Developer 账号：

```bash
# 签名应用
codesign --deep --force --verify --verbose \
  --sign "Developer ID Application: Your Name" \
  .build/release/Snap.app

# 公证应用（推荐）
xcrun notarytool submit Snap.zip \
  --apple-id "your@email.com" \
  --team-id "TEAM_ID" \
  --password "app-specific-password"
```

签名后用户不会看到"无法验证开发者"警告。

## 🎬 完整示例

假设你现在要发布 v1.0.0：

```bash
# 步骤 1: 准备代码
git status
git add .
git commit -m "Prepare for v1.0.0 release"
git push

# 步骤 2: 安装 GitHub CLI（仅首次）
brew install gh
gh auth login

# 步骤 3: 运行发布脚本
./scripts/release.sh 1.0.0

# 脚本会自动：
# ✅ 检查环境
# ✅ 清理旧构建
# ✅ 构建应用
# ✅ 创建 ZIP 和 DMG
# ✅ 计算 SHA256
# ✅ 创建 Git 标签
# ✅ 推送到 GitHub
# ✅ 创建 GitHub Release
# ✅ 上传文件

# 步骤 4: 验证
# 访问: https://github.com/liyunsong/snap/releases
# 测试下载和安装

# 完成！ 🎉
```

## 📚 详细文档

- **5分钟快速开始**: 查看 [QUICK_START.md](QUICK_START.md)
- **完整发布指南**: 查看 [RELEASE_GUIDE.md](RELEASE_GUIDE.md)
- **测试清单**: 查看 [TESTING.md](TESTING.md)

## 🆘 故障排除

### "gh: command not found"

```bash
# 安装 GitHub CLI
brew install gh

# 或访问: https://cli.github.com/
```

### "make: command not found"

make 应该预装在 macOS 上。如果没有：

```bash
xcode-select --install
```

### 构建失败

```bash
# 清理并重试
make clean
rm -rf .build
swift package clean
make build
```

### 无法创建 DMG

确保有足够的磁盘空间，并且 hdiutil 可用：

```bash
which hdiutil
# 应该返回: /usr/bin/hdiutil
```

## 🎓 学习资源

- [GitHub Releases 文档](https://docs.github.com/en/repositories/releasing-projects-on-github)
- [Semantic Versioning](https://semver.org/)
- [Apple 代码签名指南](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)

## ✅ 下一步

现在你可以：

1. ✨ 运行 `./scripts/release.sh 1.0.0` 创建首个 Release
2. 📝 自定义 `RELEASE_NOTES.md` 中的发布说明
3. 🎨 添加应用图标（可选）
4. 🔐 设置代码签名（可选）
5. 🚀 分享你的应用！

---

**祝发布成功！** 如有问题，查看详细文档或提交 Issue。🎉
