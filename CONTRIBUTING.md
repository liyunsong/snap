# Contributing to Snap

感谢您对 Snap 的关注！我们欢迎任何形式的贡献。

## 开发环境设置

### 必需工具
- macOS 13.0+ (Ventura or later)
- Xcode 15.0+ 或 Swift 5.9+
- Git

### 获取代码
```bash
git clone <repository-url>
cd snap
swift package resolve
```

### 构建项目
```bash
swift build
```

### 运行项目
```bash
swift run
```

## 开发流程

### 1. Fork 和 Clone
1. Fork 此仓库到您的 GitHub 账户
2. Clone 您的 fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/snap.git
   ```

### 2. 创建分支
```bash
git checkout -b feature/your-feature-name
```

分支命名约定:
- `feature/` - 新功能
- `fix/` - Bug 修复
- `docs/` - 文档更新
- `perf/` - 性能优化
- `refactor/` - 代码重构

### 3. 开发
1. 编写代码
2. 遵循代码规范（见下文）
3. 添加必要的注释
4. 更新相关文档

### 4. 测试
```bash
swift test
```

确保所有测试通过，并添加新的测试覆盖您的更改。

### 5. Commit
```bash
git add .
git commit -m "feat: add new drawing tool"
```

Commit 消息约定（遵循 Conventional Commits）:
- `feat:` - 新功能
- `fix:` - Bug 修复
- `docs:` - 文档更新
- `style:` - 代码格式（不影响功能）
- `refactor:` - 重构
- `perf:` - 性能优化
- `test:` - 添加测试
- `chore:` - 构建/工具更改

### 6. Push 和 Pull Request
```bash
git push origin feature/your-feature-name
```

然后在 GitHub 上创建 Pull Request。

## 代码规范

### Swift 风格指南

#### 命名
```swift
// 类型名使用 PascalCase
class ScreenshotCapture { }
struct Annotation { }
enum AnnotationType { }

// 变量和函数使用 camelCase
var currentTool: AnnotationType
func captureArea(_ rect: CGRect) { }

// 常量使用 camelCase
let maxUndoStackSize = 50

// 私有属性使用 camelCase（不需要下划线）
private var isCapturing: Bool
```

#### 缩进和格式
- 使用 4 个空格缩进（不使用 Tab）
- 函数大括号另起一行
- 控制流大括号同行

```swift
// ✅ 推荐
func captureScreen() {
    if someCondition {
        doSomething()
    } else {
        doSomethingElse()
    }
}

// ❌ 不推荐
func captureScreen()
{
    if someCondition
    {
        doSomething()
    }
}
```

#### 类型推断
```swift
// ✅ 使用类型推断
let color = Color.red
let tools = [RectangleTool(), CircleTool()]

// ❌ 不必要的类型注解
let color: Color = Color.red
```

#### 可选值处理
```swift
// ✅ 使用 guard 早返回
func process(_ image: NSImage?) {
    guard let image = image else { return }
    // 处理 image
}

// ✅ 使用 if let 处理可选链
if let size = capturedImage?.size {
    print("Size: \(size)")
}

// ❌ 避免强制解包（除非确定安全）
let size = capturedImage!.size  // 危险！
```

#### 闭包
```swift
// ✅ 尾随闭包语法
KeyboardShortcuts.onKeyUp(for: .captureArea) { [weak self] in
    self?.handleCapture()
}

// ✅ 简短闭包使用 $0
annotations.filter { $0.type == .rectangle }
```

#### 注释
```swift
// ✅ 为复杂逻辑添加注释
/// Captures a specific area of the screen
/// - Parameter rect: The rectangle area to capture
/// - Returns: The captured image, or nil if capture failed
func captureArea(_ rect: CGRect) async throws -> NSImage? {
    // 避免使用已弃用的 CGWindowListCreateImage
    // 使用 ScreenCaptureKit 以避免 ReplayKit 后台进程
    let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
    // ...
}
```

### SwiftUI 规范

```swift
// ✅ 视图分解
struct EditorView: View {
    var body: some View {
        VStack {
            headerView
            contentView
            footerView
        }
    }
    
    private var headerView: some View {
        // ...
    }
}

// ✅ 使用 @State 和 @Binding 正确
struct ToolButton: View {
    @Binding var selectedTool: AnnotationType
    let tool: AnnotationType
    
    var body: some View {
        // ...
    }
}
```

### 错误处理

```swift
// ✅ 使用自定义错误类型
enum ScreenshotError: Error {
    case noDisplayFound
    case captureFailure
    case permissionDenied
}

// ✅ 抛出明确的错误
func captureArea(_ rect: CGRect) async throws -> NSImage? {
    guard rect.width > 0 && rect.height > 0 else {
        throw ScreenshotError.captureFailure
    }
    // ...
}

// ✅ 处理错误
do {
    let image = try await capture()
} catch ScreenshotError.permissionDenied {
    print("Permission denied")
} catch {
    print("Unknown error: \(error)")
}
```

## 贡献类型

### 报告 Bug
1. 检查是否已有相关 Issue
2. 创建新 Issue，包含:
   - 清晰的标题
   - 详细的重现步骤
   - 预期行为 vs 实际行为
   - 环境信息（macOS 版本、Snap 版本）
   - 截图或录屏（如适用）

### 功能建议
1. 创建 Issue 描述建议
2. 解释为什么需要此功能
3. 提供使用场景示例
4. 如果可能，提供设计草图或原型

### 代码贡献

#### 添加新绘图工具
1. 在 `AnnotationType` 枚举中添加类型
2. 创建实现 `DrawingTool` 协议的结构体
3. 在 `getTool(for:)` 中添加分支
4. 在 `ToolPanelView` 中添加按钮
5. 添加测试
6. 更新文档

示例:
```swift
// 1. 添加类型
enum AnnotationType {
    // ...
    case triangle
}

// 2. 实现工具
struct TriangleTool: DrawingTool {
    func draw(in context: GraphicsContext, annotation: Annotation) {
        // 实现绘制逻辑
    }
    
    func createAnnotation(from start: CGPoint, to end: CGPoint, color: Color, lineWidth: CGFloat) -> Annotation {
        Annotation(type: .triangle, points: [start, end], color: color, lineWidth: lineWidth)
    }
}

// 3. 添加到工具获取方法
private func getTool(for type: AnnotationType) -> DrawingTool {
    switch type {
    // ...
    case .triangle: return TriangleTool()
    }
}
```

#### 优化性能
1. 使用 Instruments 分析性能瓶颈
2. 提供前后对比数据
3. 确保不影响功能
4. 添加性能测试

#### 修复 Bug
1. 引用相关 Issue
2. 描述修复方法
3. 添加回归测试防止再次发生

## Pull Request 清单

提交 PR 前，请确保:

- [ ] 代码遵循项目风格指南
- [ ] 所有测试通过
- [ ] 添加了必要的测试
- [ ] 更新了相关文档
- [ ] Commit 消息清晰明确
- [ ] 没有合并冲突
- [ ] PR 描述清楚说明了变更内容

### PR 模板

```markdown
## 变更类型
- [ ] Bug 修复
- [ ] 新功能
- [ ] 性能优化
- [ ] 重构
- [ ] 文档更新

## 描述
简要描述此 PR 的目的和内容。

## 相关 Issue
Closes #123

## 变更内容
- 添加了 XXX 功能
- 修复了 YYY 问题
- 优化了 ZZZ 性能

## 测试
- [ ] 添加了单元测试
- [ ] 添加了 UI 测试
- [ ] 手动测试通过

## 截图（如适用）
[粘贴截图]

## 其他说明
任何需要审查者注意的内容。
```

## 审查流程

1. **自动检查**: CI 会运行测试和 linter
2. **代码审查**: 维护者会审查您的代码
3. **反馈**: 可能需要进行修改
4. **合并**: 通过审查后，PR 将被合并

## 社区准则

### 行为准则
- 尊重所有贡献者
- 保持建设性和专业
- 欢迎新手
- 专注于代码和想法，而非个人

### 沟通
- Issue 和 PR 中使用清晰的语言
- 提供足够的上下文
- 接受建设性批评
- 及时回复反馈

## 获得帮助

如果您在贡献过程中遇到问题:
1. 查看现有文档（README, ARCHITECTURE.md）
2. 搜索相关 Issue
3. 创建新 Issue 寻求帮助
4. 在 PR 中 @mention 维护者

## 许可证

贡献代码即表示您同意在 MIT 许可证下发布您的贡献。

## 致谢

感谢所有贡献者！您的贡献让 Snap 变得更好。

---

再次感谢您的贡献！🎉
