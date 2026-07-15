# Snap Architecture Documentation

## 概述

Snap 是一个原生 macOS 截图应用，采用现代 Swift 架构，注重性能和内存效率。

## 技术栈

### 语言和框架
- **Swift 6**: 主要编程语言，利用现代并发特性
- **SwiftUI**: 声明式 UI 框架（用于编辑器和工具面板）
- **AppKit**: 传统 UI 框架（用于选区覆盖窗口和窗口管理）
- **ScreenCaptureKit**: macOS 13+ 的现代截图 API

### 依赖管理
- **Swift Package Manager**: 依赖管理工具
- **KeyboardShortcuts**: 全局快捷键库

## 架构设计

### 1. MVVM 架构模式

```
┌─────────────┐
│    View     │ (SwiftUI Views)
└──────┬──────┘
       │ observes
       ▼
┌─────────────┐
│  ViewModel  │ (AppState)
└──────┬──────┘
       │ uses
       ▼
┌─────────────┐
│    Model    │ (Annotation, Services)
└─────────────┘
```

#### AppState (ViewModel)
- 中央状态管理
- 使用 `@Published` 属性触发 UI 更新
- 管理撤销/重做栈
- 协调各个服务

#### Views
- **MenuBarView**: 菜单栏界面
- **SelectionOverlay**: 全屏选区窗口
- **EditorView**: 截图编辑器
- **ToolPanelView**: 工具面板

#### Models
- **Annotation**: 标注数据结构
- **AnnotationType**: 工具类型枚举

### 2. 服务层设计

#### ScreenshotCapture Service
```swift
@MainActor
class ScreenshotCapture {
    // 单例模式，避免多实例
    static let shared = ScreenshotCapture()
    
    // 请求权限
    func requestPermission() async -> Bool
    
    // 捕获全屏
    func captureFullScreen() async throws -> NSImage?
    
    // 捕获区域
    func captureArea(_ rect: CGRect) async throws -> NSImage?
}
```

**设计要点**:
- 使用 `SCScreenshotManager.captureImage` 进行单次快照
- 避免 `SCStream` 持续流（节省内存）
- 使用 async/await 处理异步操作
- @MainActor 确保主线程安全

#### ClipboardHelper Service
```swift
class ClipboardHelper {
    static let shared = ClipboardHelper()
    
    // 复制到剪贴板
    func copyImageToClipboard(_ image: NSImage)
    
    // 保存到文件
    func saveImageToFile(_ image: NSImage) -> URL?
    
    // 渲染标注图像
    func renderAnnotatedImage(baseImage: NSImage, annotations: [Annotation]) -> NSImage
}
```

**设计要点**:
- 使用 CoreGraphics 进行高效渲染
- 直接操作 CGContext 避免中间层开销
- 支持所有标注类型的渲染

#### ShortcutManager Service
```swift
@MainActor
class ShortcutManager {
    static let shared = ShortcutManager()
    
    var onCaptureArea: (() -> Void)?
    var onCaptureFullScreen: (() -> Void)?
}
```

**设计要点**:
- 集成 KeyboardShortcuts 库
- 使用闭包回调解耦业务逻辑
- 支持运行时修改快捷键

### 3. 绘图工具系统

#### Protocol-Oriented Design
```swift
protocol DrawingTool {
    func draw(in context: GraphicsContext, annotation: Annotation)
    func createAnnotation(from: CGPoint, to: CGPoint, ...) -> Annotation
}
```

**工具实现**:
- **RectangleTool**: 矩形绘制
- **CircleTool**: 圆形/椭圆绘制
- **ArrowTool**: 箭头绘制（带自动计算角度）
- **LineTool**: 直线绘制
- **PenTool**: 自由画笔（路径点数组）
- **TextTool**: 文字标注
- **MosaicTool**: 马赛克效果（使用 CIPixellate）
- **BlurTool**: 模糊效果（使用 CIGaussianBlur）

### 4. 窗口管理架构

```
MenuBarExtra (常驻)
    │
    ├─→ MenuBarView (弹出菜单)
    │
    └─→ SelectionOverlayWindow (临时，全屏覆盖)
            │
            └─→ EditorWindow (截图编辑)
                    │
                    └─→ EditorView + ToolPanelView
```

#### SelectionOverlayWindow
- **NSWindow** with `.screenSaver` level
- 全屏透明覆盖
- 自定义鼠标事件处理
- 绘制半透明遮罩和选区高亮

#### EditorWindow
- 标准 NSWindow
- SwiftUI 内容视图（EditorView）
- 自适应截图尺寸

## 数据流

### 截图流程
```
用户触发 (快捷键/菜单)
    ↓
ShortcutManager.onCaptureArea
    ↓
显示 SelectionOverlayWindow
    ↓
用户拖拽选择区域
    ↓
ScreenshotCapture.captureArea(rect)
    ↓
AppState.setCapturedImage(image)
    ↓
显示 EditorWindow
```

### 编辑流程
```
用户选择工具 → AppState.currentTool
    ↓
用户拖拽绘制 → DragGesture
    ↓
创建临时 Annotation
    ↓
onEnded → AppState.addAnnotation
    ↓
保存到 undoStack
    ↓
触发 View 更新 (@Published)
```

### 导出流程
```
用户点击"复制"
    ↓
ClipboardHelper.renderAnnotatedImage
    ↓
遍历所有 annotations
    ↓
使用 CGContext 逐个绘制
    ↓
生成最终 NSImage
    ↓
写入 NSPasteboard
```

## 内存优化策略

### 1. 避免 ReplayKit 后台进程
- ❌ 不使用 `CGWindowListCreateImage`（已弃用，会启动 ReplayKit）
- ✅ 使用 `ScreenCaptureKit.captureImage`（单次快照）

### 2. 资源管理
```swift
func reset() {
    annotations.removeAll()
    undoStack.removeAll()
    redoStack.removeAll()
    capturedImage = nil  // 立即释放图像
    isEditorVisible = false
    isSelectingArea = false
}
```

### 3. 撤销栈限制
```swift
private func saveStateForUndo() {
    undoStack.append(annotations)
    if undoStack.count > 50 {
        undoStack.removeFirst()  // 限制历史记录数量
    }
}
```

### 4. 懒加载和按需创建
- CoreImage filters 仅在使用时创建
- 窗口仅在需要时创建和显示
- 使用 `@StateObject` 管理对象生命周期

### 5. 避免循环引用
```swift
KeyboardShortcuts.onKeyUp(for: .captureArea) { [weak self] in
    // 使用 weak self 避免循环引用
}
```

## 并发模型

### Actor 隔离
```swift
@MainActor
class AppState: ObservableObject {
    // 所有状态更新在主线程
}

@MainActor
class ScreenshotCapture {
    // UI 相关操作在主线程
}
```

### Async/Await
```swift
Task {
    let image = try await ScreenshotCapture.shared.captureArea(rect)
    await MainActor.run {
        appState.setCapturedImage(image)
    }
}
```

## 扩展性设计

### 添加新工具
1. 创建实现 `DrawingTool` 的结构体
2. 在 `AnnotationType` 枚举中添加类型
3. 在 `getTool(for:)` 中添加分支
4. 在 `ToolPanelView` 中添加按钮

### 添加新快捷键
1. 在 `KeyboardShortcuts.Name` 扩展中定义
2. 在 `ShortcutManager` 中注册
3. 在 `MenuBarView` 中添加 UI

### 添加新导出格式
1. 在 `ClipboardHelper` 中添加方法
2. 使用 `NSBitmapImageRep` 转换格式
3. 在 `ToolPanelView` 中添加按钮

## 测试策略

### 单元测试
- Model 层逻辑（Annotation, AppState）
- Service 层功能（ClipboardHelper）
- 工具算法（DrawingTool）

### 集成测试
- 截图捕获流程
- 标注渲染正确性
- 快捷键触发

### UI 测试
- 选区交互
- 工具切换
- 撤销/重做

### 性能测试
- 内存占用（Instruments - Allocations）
- CPU 使用率（Instruments - Time Profiler）
- 截图响应时间

## 已知限制和未来改进

### 当前限制
1. **多显示器**: 仅支持主显示器
2. **文件格式**: 仅支持 PNG
3. **云同步**: 无云同步功能
4. **历史记录**: 不持久化

### 未来改进
1. **多显示器完整支持**
   - 检测所有显示器
   - 支持跨显示器选区
   
2. **更多导出格式**
   - JPEG (可调质量)
   - WebP
   - PDF
   
3. **智能功能**
   - OCR 文字识别
   - 自动标注建议
   - 模板系统
   
4. **性能优化**
   - 硬件加速渲染
   - 增量保存
   - 图像压缩

## 安全和隐私

### 权限管理
- 明确请求屏幕录制权限
- Info.plist 中清晰说明用途
- 不收集用户数据

### 数据处理
- 截图仅保存在本地
- 不上传到云端
- 用户完全控制数据

## 总结

Snap 采用现代 Swift 架构，注重：
1. **性能**: 使用最新 API，避免已知性能陷阱
2. **内存**: 及时释放资源，限制缓存大小
3. **可维护性**: 清晰的分层，协议导向设计
4. **用户体验**: 流畅的交互，直观的 UI

通过合理的架构设计，Snap 实现了低内存占用（<50MB）和快速响应（<100ms 截图时间）的目标。
