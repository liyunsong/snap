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

## 系统要求

- **macOS**: 13.0 (Ventura) 或更高版本
- **开发工具**: Xcode 15.0+ 或 Swift 5.9+
- **架构**: Apple Silicon 或 Intel Mac

## 构建说明

### 使用 Swift Package Manager

1. 克隆仓库:
```bash
git clone <repository-url>
cd snap
```

2. 构建项目:
```bash
swift build -c release
```

3. 运行应用:
```bash
swift run
```

### 使用 Xcode

1. 在项目根目录运行:
```bash
open Package.swift
```

2. 在 Xcode 中:
   - 选择 "SnapApp" scheme
   - 点击 Run（⌘ + R）

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

## 联系方式

如有问题或建议，请提交 Issue。
