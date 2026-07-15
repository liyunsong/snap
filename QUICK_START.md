# 快速开始 - 5 分钟发布到 GitHub Release

本指南帮助你快速将 Snap 打包并发布到 GitHub Release。

## ⚡ 最快方式（推荐）

### 步骤 1: 安装 GitHub CLI

```bash
brew install gh
gh auth login
```

### 步骤 2: 运行发布脚本

```bash
# 给脚本添加执行权限（仅首次需要）
chmod +x scripts/release.sh

# 运行发布脚本
./scripts/release.sh 1.0.0
```

### 步骤 3: 跟随提示

脚本会自动：
- ✅ 构建应用
- ✅ 创建 ZIP 和 DMG
- ✅ 创建 Git 标签
- ✅ 创建 GitHub Release
- ✅ 上传文件

### 步骤 4: 完成！

访问 Release 页面：
https://github.com/liyunsong/snap/releases

## 🎯 分步指南

如果你想手动控制每一步：

### 1. 构建应用

```bash
# 清理之前的构建
make clean

# 构建发布版本（包含 .app, ZIP, DMG）
make release
```

### 2. 创建 Git 标签

```bash
# 创建标签
git tag -a v1.0.0 -m "Release version 1.0.0"

# 推送标签
git push origin v1.0.0
```

### 3. 创建 GitHub Release

#### 方法 A: 使用 GitHub CLI（推荐）

```bash
gh release create v1.0.0 \
  .build/release/Snap-1.0.0.zip \
  .build/release/Snap-1.0.0.dmg \
  --title "Snap v1.0.0" \
  --notes-file RELEASE_NOTES.md
```

#### 方法 B: 使用 GitHub 网页

1. 访问: https://github.com/liyunsong/snap/releases/new
2. 选择标签: `v1.0.0`
3. 填写标题: `Snap v1.0.0`
4. 复制 `RELEASE_NOTES.md` 内容到描述
5. 上传文件:
   - `.build/release/Snap-1.0.0.zip`
   - `.build/release/Snap-1.0.0.dmg`
6. 点击 "Publish release"

### 4. 验证 Release

访问 Release 页面，确认：
- [ ] 版本号正确
- [ ] 文件可以下载
- [ ] 发布说明完整
- [ ] 下载链接有效

## 🤖 使用 GitHub Actions（自动化）

### 步骤 1: 推送代码

```bash
git add .
git commit -m "Ready for release"
git push
```

### 步骤 2: 创建并推送标签

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

### 步骤 3: 等待构建

- GitHub Actions 会自动构建
- 访问: https://github.com/liyunsong/snap/actions
- 等待构建完成（约 5-10 分钟）

### 步骤 4: 发布 Release

- 访问: https://github.com/liyunsong/snap/releases
- 找到新创建的 Draft Release
- 编辑并点击 "Publish release"

## 📋 Makefile 命令速查

```bash
# 显示帮助
make help

# 构建可执行文件
make build

# 创建 .app 包
make app

# 创建 ZIP
make zip

# 创建 DMG
make dmg

# 完整发布构建（推荐）
make release

# 清理构建产物
make clean

# 安装到 /Applications
make install
```

## 🔍 验证构建产物

### 检查文件

```bash
# 列出构建产物
ls -lh .build/release/

# 应该看到:
# Snap.app/
# Snap-1.0.0.zip
# Snap-1.0.0.dmg
```

### 测试应用

```bash
# 运行应用
open .build/release/Snap.app

# 验证功能
# - 菜单栏图标
# - 截图功能
# - 编辑工具
# - 保存/复制
```

### 计算文件哈希

```bash
# SHA256
shasum -a 256 .build/release/Snap-1.0.0.zip
shasum -a 256 .build/release/Snap-1.0.0.dmg

# MD5（可选）
md5 .build/release/Snap-1.0.0.zip
md5 .build/release/Snap-1.0.0.dmg
```

## ⚠️ 常见问题

### "无法打开应用"错误

用户下载后可能遇到 macOS Gatekeeper 警告。告诉用户：

**方法 1**: 右键 → 打开
1. 右键点击 Snap.app
2. 选择"打开"
3. 在对话框中点击"打开"

**方法 2**: 使用终端
```bash
xattr -cr /Applications/Snap.app
```

**方法 3**: 系统设置
1. 打开 系统设置 → 隐私与安全性
2. 找到 Snap 的提示
3. 点击"仍要打开"

### 构建失败

```bash
# 清理并重试
make clean
swift package clean
rm -rf .build

# 更新依赖
swift package resolve
swift package update

# 重新构建
make build
```

### GitHub CLI 未安装

```bash
# macOS
brew install gh

# 或下载: https://cli.github.com/
```

### 未登录 GitHub

```bash
gh auth login
# 跟随提示完成登录
```

## 📝 发布检查清单

发布前确认：

- [ ] 代码已提交并推送
- [ ] 版本号已更新
- [ ] RELEASE_NOTES.md 已更新
- [ ] 构建成功（`make release`）
- [ ] 应用可以正常运行
- [ ] 功能测试通过
- [ ] Git 标签已创建
- [ ] GitHub Release 已创建
- [ ] 文件可以下载
- [ ] 下载的应用可以运行

## 🚀 下次发布

发布新版本时：

1. **更新版本号**:
   - `RELEASE_NOTES.md`
   - `Makefile` (VERSION 变量)

2. **提交更改**:
   ```bash
   git add .
   git commit -m "Bump version to 1.1.0"
   git push
   ```

3. **运行发布脚本**:
   ```bash
   ./scripts/release.sh 1.1.0
   ```

## 📚 更多信息

- 详细指南: [RELEASE_GUIDE.md](RELEASE_GUIDE.md)
- 测试指南: [TESTING.md](TESTING.md)
- 贡献指南: [CONTRIBUTING.md](CONTRIBUTING.md)
- 架构文档: [ARCHITECTURE.md](ARCHITECTURE.md)

## 🆘 需要帮助？

- 查看 [Issues](https://github.com/liyunsong/snap/issues)
- 提交新 Issue
- 阅读详细的 [RELEASE_GUIDE.md](RELEASE_GUIDE.md)

---

**祝发布顺利！** 🎉
