# Snap v1.0.1

## 修复

- **修复 v1.0.0 DMG「已损坏」**：打包的 `Snap.app` 缺少 `CFBundleExecutable`，可执行文件名与 Info.plist 不一致，导致 macOS 认为应用损坏无法打开。
- 打包时补齐 Info.plist、校验 bundle，并对 `.app` 做 ad-hoc 签名。
- CI 发布按 tag 版本命名 DMG（例如 `Snap-1.0.1.dmg`）。

> 请不要再使用 v1.0.0 的安装包，改用本版本的 `Snap-1.0.1.dmg`。

## 📋 系统要求

- macOS 15.0 (Sequoia) 或更高版本
- Apple Silicon (arm64) Mac

## 📦 安装方法

1. 下载 `Snap-1.0.1.dmg`
2. 双击打开 DMG，将 Snap 拖到 Applications
3. 首次打开若提示无法验证开发者或「已损坏」：
   ```bash
   xattr -cr /Applications/Snap.app
   ```
   然后再打开 Snap
4. 授予「屏幕录制」权限后即可使用

## 🎉 功能概览

- 区域截图 (`⌘⇧A`) / 全屏截图 (`⌘⇧S`)
- 矩形、圆形、箭头、直线、画笔、文字、马赛克、模糊
- 复制到剪贴板 / 保存到桌面
- 菜单栏常驻，可自定义快捷键

## 📝 更新日志

### v1.0.1
- 修复发布包 Info.plist / 签名问题导致的「文件已损坏」

### v1.0.0
- 首个正式版本
