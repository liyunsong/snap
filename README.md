# Snap - macOS Screenshot App

一个轻量级、原生的 macOS 截图应用，支持区域选择、全屏截图和丰富的编辑功能。

## 功能特性

### 截图功能
- **区域截图**: 使用鼠标拖拽选择任意区域
- **全屏截图**: 快速捕获整个屏幕
- **自定义快捷键**: 支持用户自定义全局快捷键
  - 默认区域截图: `⌘ + ⇧ + A`
  - 默认全屏截图: `⌘ + ⇧ + S`

### 编辑工具
- **绘图工具**:
  - 矩形: 绘制矩形框
  - 圆形: 绘制圆形/椭圆
  - 箭头: 绘制带箭头的指示线
  - 直线: 绘制直线
  - 画笔: 自由绘制
  - 文字: 添加文字标注

- **效果工具**:
  - 马赛克: 像素化区域（隐私保护）
  - 模糊: 高斯模糊区域

- **编辑功能**:
  - 颜色选择: 10+ 预设颜色
  - 线宽调节: 1-20px 可调
  - 撤销/重做: 最多 50 步历史记录

### 输出选项
- **复制到剪贴板**: 一键复制编辑后的截图
- **保存到文件**: 自动保存到桌面（PNG 格式）
- **菜单栏应用**: 轻量级常驻，不占用 Dock 空间

## 技术架构

### 核心技术
- **Swift 6** + **SwiftUI** + **AppKit** 混合架构
- **ScreenCaptureKit**: 现代高性能截图 API（macOS 13+）
- **KeyboardShortcuts**: 全局快捷键管理
- **MenuBarExtra**: 菜单栏应用

### 内存优化
- 使用单次快照 API（避免持续流）
- 避免使用已弃用的 `CGWindowListCreateImage`（会启动 ReplayKit 后台进程）
- 编辑完成后立即释放图像资源
- 使用 `@StateObject` 管理对象生命周期

### 项目结构
```
SnapApp/
├── SnapApp.swift                    # App 入口
├── Models/
│   ├── AppState.swift              # 全局状态管理
│   ├── ScreenshotCapture.swift     # 截图捕获服务
│   └── Annotation.swift            # 注释数据模型
├── Views/
│   ├── MenuBarView.swift           # 菜单栏视图
│   ├── SelectionOverlay.swift      # 选区覆盖窗口
│   ├── EditorView.swift            # 编辑器主视图
│   └── ToolPanelView.swift         # 工具栏面板
├── Tools/
│   ├── DrawingTool.swift           # 绘图工具实现
│   └── EffectTools.swift           # 效果工具实现
├── Utils/
│   ├── ShortcutManager.swift       # 快捷键管理
│   └── ClipboardHelper.swift       # 剪贴板工具
└── Resources/
    └── Info.plist                   # 权限配置
```

## 📥 安装和使用

### 从 GitHub Release 下载（推荐）

1. 访问 [Releases 页面](https://github.com/liyunsong/snap/releases)
2. 下载最新版本的 **DMG** 或 **ZIP** 文件
3. 安装到 Applications 文件夹
4. 首次运行时授予屏幕录制权限

### 从源码构建（本地使用）

```bash
# 克隆仓库
git clone https://github.com/liyunsong/snap.git
cd snap

# 快速构建（推荐）
./build-local.sh

# 安装到 Applications
sudo cp -r .build/release/Snap.app /Applications/

# 或使用 Makefile
make release
make install
```

详细指南: [LOCAL_BUILD.md](LOCAL_BUILD.md)

## 系统要求

- **macOS**: 15.0 (Sequoia) 或更高版本
- **架构**: Apple Silicon (M1/M2/M3)
- **开发工具**: Xcode 15.0+ 或 Swift 5.9+（仅开发时需要）

> 注: 本版本针对 Apple Silicon 优化，专为个人使用

## 权限配置

首次运行时，应用会请求以下权限：

1. **屏幕录制权限**: 
   - 系统设置 → 隐私与安全性 → 屏幕录制
   - 勾选 "SnapApp"

2. **辅助功能权限**（可选，用于全局快捷键）:
   - 系统设置 → 隐私与安全性 → 辅助功能
   - 勾选 "SnapApp"

## 使用方法

### 方式一：使用快捷键
1. 按下 `⌘ + ⇧ + A` 开始区域截图
2. 鼠标拖拽选择区域
3. 释放鼠标完成截图
4. 在编辑器中添加标注
5. 点击"复制"或"保存"

### 方式二：使用菜单栏
1. 点击菜单栏中的 📷 图标
2. 选择"区域截图"或"全屏截图"
3. 完成截图和编辑

### 快捷键自定义
1. 点击菜单栏图标
2. 选择"设置"
3. 在快捷键录制器中设置新的快捷键

## 开发说明

### 依赖项

通过 Swift Package Manager 自动管理：

- **KeyboardShortcuts** (2.0.0+): 全局快捷键支持
  - https://github.com/sindresorhus/KeyboardShortcuts

### 系统框架

- ScreenCaptureKit: 屏幕捕获
- SwiftUI: 用户界面
- AppKit: 原生窗口管理
- CoreImage: 图像效果处理
- CoreGraphics: 图形绘制

### 内存优化建议

1. **及时释放**: 编辑完成后点击"关闭"释放资源
2. **避免多个实例**: 同时只编辑一张截图
3. **合理使用效果**: 马赛克和模糊工具会占用额外内存

### 已知限制

1. **多显示器**: 目前主要支持主显示器
2. **沙盒模式**: 需要屏幕录制权限
3. **文件格式**: 仅支持 PNG 输出

## 测试清单

- [x] 区域选择功能
- [x] 全屏截图功能
- [x] 所有绘图工具（矩形、圆形、箭头、直线、画笔、文字）
- [x] 效果工具（马赛克、模糊）
- [x] 颜色选择
- [x] 线宽调节
- [x] 撤销/重做
- [x] 复制到剪贴板
- [x] 保存到文件
- [x] 全局快捷键
- [x] 快捷键自定义
- [ ] 多显示器支持（待完善）
- [ ] Retina 显示屏优化（待测试）
- [ ] 内存泄漏检测（需 Instruments）

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

## 致谢

- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) by Sindre Sorhus
- [ScreenCaptureKit](https://developer.apple.com/documentation/screencapturekit) by Apple
- 灵感来源于 macOS 内置截图工具和其他优秀的截图应用

## 📦 打包和发布

### 快速发布到 GitHub Release

```bash
# 1. 安装 GitHub CLI
brew install gh
gh auth login

# 2. 运行发布脚本
./scripts/release.sh 1.0.0
```

### 手动构建

```bash
# 完整发布构建（包含 .app, ZIP, DMG）
make release

# 单独构建
make app    # 创建 .app 包
make zip    # 创建 ZIP 归档
make dmg    # 创建 DMG 安装包
```

### 详细指南

- 📖 [快速开始 (5分钟)](QUICK_START.md) - 最快发布方式
- 📚 [完整发布指南](RELEASE_GUIDE.md) - 详细步骤和说明
- 🔧 [Makefile 命令](Makefile) - 所有可用命令

## 联系方式

如有问题或建议，请提交 Issue。
