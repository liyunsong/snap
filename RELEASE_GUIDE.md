# Snap 打包和发布指南

本指南详细说明如何将 Snap 打包并发布到 GitHub Release，让用户可以下载使用。

## 📋 前置要求

### 必需工具
- **macOS 13.0+**: 构建环境
- **Xcode 15.0+**: Swift 编译器
- **GitHub CLI**: 发布到 GitHub
  ```bash
  brew install gh
  gh auth login
  ```

### 可选工具（用于 DMG）
- **hdiutil**: macOS 自带，用于创建 DMG

## 🚀 发布方式

### 方式一：自动发布（推荐）

#### 使用 GitHub Actions

1. **推送标签触发自动构建**
   ```bash
   # 创建标签
   git tag -a v1.0.0 -m "Release version 1.0.0"
   
   # 推送标签到 GitHub
   git push origin v1.0.0
   ```

2. **GitHub Actions 自动执行**
   - 自动构建 macOS 应用
   - 创建 .app 包
   - 生成 ZIP 和 DMG
   - 创建 GitHub Release
   - 上传构建产物

3. **查看构建状态**
   - 访问: https://github.com/liyunsong/snap/actions
   - 等待构建完成（约 5-10 分钟）

4. **发布 Release**
   - 访问: https://github.com/liyunsong/snap/releases
   - 找到新创建的 Release（Draft 状态）
   - 编辑 Release 说明（如需要）
   - 点击 "Publish release"

### 方式二：本地手动发布

#### 使用发布脚本

1. **运行发布脚本**
   ```bash
   ./scripts/release.sh 1.0.0
   ```

   或者交互式输入版本号：
   ```bash
   ./scripts/release.sh
   ```

2. **脚本会自动**:
   - ✅ 检查环境和工具
   - ✅ 验证版本号格式
   - ✅ 清理之前的构建
   - ✅ 构建发布版本
   - ✅ 创建 ZIP 和 DMG
   - ✅ 计算文件哈希（SHA256）
   - ✅ 创建 Git 标签
   - ✅ 推送到 GitHub
   - ✅ 创建 GitHub Release
   - ✅ 上传构建产物

3. **完成！**
   访问 Release 页面验证：
   https://github.com/liyunsong/snap/releases

## 🔧 手动构建步骤

如果你想完全手动控制构建过程：

### 1. 清理环境
```bash
make clean
```

### 2. 构建可执行文件
```bash
# 构建 Universal Binary（Intel + Apple Silicon）
swift build -c release --arch arm64 --arch x86_64
```

或使用 Makefile：
```bash
make build
```

### 3. 创建 .app 包
```bash
make app
```

这会创建完整的 .app 包结构：
```
.build/release/Snap.app/
├── Contents/
│   ├── Info.plist
│   ├── MacOS/
│   │   └── Snap
│   └── Resources/
│       └── AppIcon.icns (可选)
```

### 4. 创建分发包

#### ZIP 格式（推荐用于快速分发）
```bash
make zip
```

输出: `.build/release/Snap-1.0.0.zip`

#### DMG 格式（推荐用于正式发布）
```bash
make dmg
```

输出: `.build/release/Snap-1.0.0.dmg`

### 5. 完整发布构建
```bash
make release
```

这会执行: clean → build → app → zip → dmg

## 📦 手动创建 GitHub Release

### 使用 GitHub CLI

```bash
# 创建标签
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# 创建 Release 并上传文件
gh release create v1.0.0 \
  .build/release/Snap-1.0.0.zip \
  .build/release/Snap-1.0.0.dmg \
  --title "Snap v1.0.0" \
  --notes-file RELEASE_NOTES.md
```

### 使用 GitHub 网页界面

1. **访问仓库 Releases 页面**
   https://github.com/liyunsong/snap/releases

2. **点击 "Draft a new release"**

3. **填写信息**:
   - Tag version: `v1.0.0`
   - Release title: `Snap v1.0.0`
   - Description: 复制 `RELEASE_NOTES.md` 内容

4. **上传文件**:
   - 拖拽或选择 `Snap-1.0.0.zip`
   - 拖拽或选择 `Snap-1.0.0.dmg`

5. **点击 "Publish release"**

## 🎨 创建应用图标（可选）

### 1. 准备图标图片

创建以下尺寸的 PNG 图片：
- 16x16
- 32x32
- 64x64
- 128x128
- 256x256
- 512x512
- 1024x1024

### 2. 创建 iconset
```bash
mkdir -p icon.iconset
cp icon_16x16.png icon.iconset/icon_16x16.png
cp icon_32x32.png icon.iconset/icon_16x16@2x.png
cp icon_32x32.png icon.iconset/icon_32x32.png
cp icon_64x64.png icon.iconset/icon_32x32@2x.png
cp icon_128x128.png icon.iconset/icon_128x128.png
cp icon_256x256.png icon.iconset/icon_128x128@2x.png
cp icon_256x256.png icon.iconset/icon_256x256.png
cp icon_512x512.png icon.iconset/icon_256x256@2x.png
cp icon_512x512.png icon.iconset/icon_512x512.png
cp icon_1024x1024.png icon.iconset/icon_512x512@2x.png
```

### 3. 生成 icns 文件
```bash
iconutil -c icns icon.iconset -o AppIcon.icns
cp AppIcon.icns SnapApp/Resources/
```

### 4. 重新构建
```bash
make clean
make app
```

## 🔐 代码签名（推荐）

### 为什么需要签名？
- 避免 macOS Gatekeeper 警告
- 提升用户信任度
- 支持公证（Notarization）

### 签名步骤

1. **获取开发者证书**
   - 需要 Apple Developer 账号（$99/年）
   - 在 Xcode → Preferences → Accounts 中登录
   - 下载开发者证书

2. **签名应用**
   ```bash
   # 查看可用证书
   security find-identity -v -p codesigning
   
   # 签名应用
   codesign --deep --force --verify --verbose \
     --sign "Developer ID Application: Your Name (TEAM_ID)" \
     .build/release/Snap.app
   
   # 验证签名
   codesign --verify --deep --strict --verbose=2 \
     .build/release/Snap.app
   
   spctl -a -t exec -vv .build/release/Snap.app
   ```

3. **公证应用（可选但推荐）**
   ```bash
   # 压缩应用
   ditto -c -k --keepParent .build/release/Snap.app Snap.zip
   
   # 提交公证
   xcrun notarytool submit Snap.zip \
     --apple-id "your@email.com" \
     --team-id "TEAM_ID" \
     --password "app-specific-password" \
     --wait
   
   # 装订公证凭证
   xcrun stapler staple .build/release/Snap.app
   ```

## 📊 文件大小优化

### 减小应用大小

1. **Strip 符号**
   ```bash
   strip .build/release/Snap.app/Contents/MacOS/Snap
   ```

2. **压缩可执行文件**
   ```bash
   upx --best .build/release/Snap.app/Contents/MacOS/Snap
   ```
   
   注意: UPX 可能导致签名失效

3. **移除不必要的文件**
   ```bash
   find .build/release/Snap.app -name ".DS_Store" -delete
   ```

## 🧪 发布前测试清单

### 功能测试
- [ ] 应用可以正常启动
- [ ] 菜单栏图标显示正常
- [ ] 区域截图功能正常
- [ ] 全屏截图功能正常
- [ ] 编辑工具全部可用
- [ ] 快捷键可以自定义
- [ ] 复制到剪贴板正常
- [ ] 保存到文件正常

### 兼容性测试
- [ ] 在 macOS 13 Ventura 上测试
- [ ] 在 macOS 14 Sonoma 上测试
- [ ] 在 macOS 15+ 上测试（如可用）
- [ ] Intel Mac 测试
- [ ] Apple Silicon Mac 测试

### 安装测试
- [ ] DMG 可以正常挂载
- [ ] 可以拖拽到 Applications
- [ ] ZIP 可以正常解压
- [ ] 从 Applications 可以启动
- [ ] 权限请求正常工作

### 安全测试
- [ ] Gatekeeper 不阻止运行（或提供解决方案）
- [ ] 无恶意软件警告
- [ ] 权限请求说明清晰

## 📝 发布检查清单

### 发布前
- [ ] 更新版本号（Package.swift, Info.plist, RELEASE_NOTES.md）
- [ ] 更新 CHANGELOG.md
- [ ] 运行所有测试
- [ ] 在多个 macOS 版本测试
- [ ] 更新文档
- [ ] 准备发布说明
- [ ] 截图和演示视频（可选）

### 发布时
- [ ] 创建并推送 Git 标签
- [ ] 构建发布版本
- [ ] 验证构建产物
- [ ] 计算文件哈希
- [ ] 创建 GitHub Release
- [ ] 上传文件（ZIP + DMG）
- [ ] 填写详细的发布说明

### 发布后
- [ ] 验证下载链接
- [ ] 测试从 Release 下载的文件
- [ ] 更新 README.md 中的下载链接
- [ ] 在社交媒体宣布（可选）
- [ ] 通知用户（邮件列表、论坛等）
- [ ] 监控 Issues 反馈

## 🔄 版本号规范

使用语义化版本（Semantic Versioning）：

- **MAJOR.MINOR.PATCH** (例如: 1.2.3)
  - **MAJOR**: 不兼容的 API 更改
  - **MINOR**: 向后兼容的新功能
  - **PATCH**: 向后兼容的 Bug 修复

示例：
- `1.0.0` - 首个正式版本
- `1.1.0` - 添加新功能
- `1.1.1` - 修复 Bug
- `2.0.0` - 重大更新，可能不兼容

## 📚 参考资源

- [GitHub Releases 文档](https://docs.github.com/en/repositories/releasing-projects-on-github)
- [Apple 代码签名指南](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [Semantic Versioning](https://semver.org/)
- [Creating DMG files](https://www.ej-technologies.com/resources/install4j/help/doc/concepts/dmgCreation.html)

## 💡 常见问题

### Q: 用户反馈"无法打开应用，因为它来自身份不明的开发者"
**A**: 用户需要：
1. 右键点击应用 → 选择"打开"
2. 或在终端运行: `xattr -cr /Applications/Snap.app`
3. 或在系统设置中允许

### Q: 如何创建 Universal Binary？
**A**: 使用 `--arch arm64 --arch x86_64` 参数：
```bash
swift build -c release --arch arm64 --arch x86_64
```

### Q: 如何减小应用大小？
**A**: 
1. 使用 Release 配置构建
2. Strip 符号信息
3. 移除调试信息
4. 压缩资源文件

### Q: GitHub Actions 构建失败怎么办？
**A**: 
1. 检查 Actions 日志
2. 确保所有依赖可用
3. 验证 Swift 版本兼容性
4. 检查权限设置

## 🆘 获取帮助

如果遇到问题：
1. 查看 [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. 搜索 [GitHub Issues](https://github.com/liyunsong/snap/issues)
3. 创建新的 Issue
4. 联系维护者

---

**祝发布顺利！** 🚀
