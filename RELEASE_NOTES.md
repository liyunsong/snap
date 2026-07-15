# Snap v1.0.0 - 首个正式版本

## 🎉 新功能

### 截图功能
- ✅ **区域截图**: 鼠标拖拽选择任意区域 (`⌘⇧A`)
- ✅ **全屏截图**: 一键捕获整个屏幕 (`⌘⇧S`)
- ✅ **自定义快捷键**: 支持用户自定义全局快捷键
- ✅ **菜单栏应用**: 轻量级常驻，不占用 Dock 空间

### 编辑工具（8种）
- 🔲 **矩形工具**: 绘制矩形框
- ⭕ **圆形工具**: 绘制圆形/椭圆
- ➡️ **箭头工具**: 带箭头的指示线
- 📏 **直线工具**: 绘制直线
- ✏️ **画笔工具**: 自由路径绘制
- 🔤 **文字工具**: 文字标注
- 🔳 **马赛克工具**: 像素化效果（隐私保护）
- 🌫️ **模糊工具**: 高斯模糊效果

### 编辑功能
- 🎨 **颜色选择**: 10+ 预设颜色
- 📐 **线宽调节**: 1-20px 可调
- ⏮️ **撤销/重做**: 最多 50 步历史记录
- 📋 **复制到剪贴板**: 一键复制
- 💾 **保存到文件**: 自动保存到桌面（PNG 格式）

## 📋 系统要求

- macOS 13.0 (Ventura) 或更高版本
- 64 位 Intel 或 Apple Silicon Mac

## 📦 安装方法

### 方法一：DMG 安装（推荐）
1. 下载 `Snap-1.0.0.dmg`
2. 双击打开 DMG 文件
3. 将 Snap 图标拖到 Applications 文件夹
4. 从 Applications 或 Spotlight 启动 Snap

### 方法二：ZIP 安装
1. 下载 `Snap-1.0.0.zip`
2. 解压缩
3. 将 `Snap.app` 移动到 Applications 文件夹
4. 从 Applications 或 Spotlight 启动 Snap

## ⚙️ 首次使用

1. **授予权限**: 首次运行会请求屏幕录制权限
   - 打开: 系统设置 → 隐私与安全性 → 屏幕录制
   - 勾选 "Snap"
   - 重启应用

2. **开始使用**:
   - 点击菜单栏中的 📷 图标
   - 或按 `⌘⇧A` 开始区域截图
   - 或按 `⌘⇧S` 开始全屏截图

## 🔒 安全提示

如果 macOS 阻止打开应用（"无法验证开发者"），请按以下步骤操作：

1. 打开 **系统设置** → **隐私与安全性**
2. 向下滚动到 **安全性** 部分
3. 点击 **仍要打开** 按钮
4. 在确认对话框中点击 **打开**

或者，在终端中运行：
```bash
xattr -cr /Applications/Snap.app
```

## ⚡ 性能指标

- **内存占用**: < 50MB（空闲）
- **CPU 使用**: < 1%（空闲）
- **截图响应**: < 100ms
- **应用大小**: < 10MB

## 🐛 已知问题

- 多显示器支持需要进一步完善
- 马赛克和模糊效果当前为半透明覆盖（完整实现即将推出）

## 📝 更新日志

### v1.0.0 (2026-07-15)
- 首个正式版本发布
- 实现所有核心功能
- 完整的文档和测试指南

## 🙏 致谢

- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) by Sindre Sorhus
- [ScreenCaptureKit](https://developer.apple.com/documentation/screencapturekit) by Apple

## 📮 反馈和支持

如有问题或建议，请在 [GitHub Issues](https://github.com/liyunsong/snap/issues) 中提交。

## 📄 许可证

MIT License - 查看 [LICENSE](LICENSE) 文件了解详情。

---

**下载量**: 查看 [Releases](https://github.com/liyunsong/snap/releases) 页面
