# 本地构建指南 - Apple Silicon (M1 Pro) macOS 26

本指南专门为在 M1 Pro 上运行 macOS 26 的个人使用优化。

## 🚀 快速开始

### 一键构建和安装

```bash
# 构建应用
./build-local.sh

# 安装到 Applications
sudo cp -r .build/release/Snap.app /Applications/

# 运行
open /Applications/Snap.app
```

或者使用 Makefile：

```bash
# 构建并安装
make release
make install

# 运行
open /Applications/Snap.app
```

## 📦 构建命令

### 快速构建（推荐）

```bash
# 使用本地构建脚本
./build-local.sh
```

### 使用 Makefile

```bash
# 完整构建
make release

# 单独步骤
make clean       # 清理
make build       # 构建可执行文件
make app         # 创建 .app 包
make install     # 安装到 /Applications
```

### 手动构建

```bash
# 1. 清理
rm -rf .build

# 2. 构建（仅 Apple Silicon）
swift build -c release --arch arm64

# 3. 创建 .app 包
make app

# 4. 安装
sudo cp -r .build/release/Snap.app /Applications/
```

## ⚙️ 系统要求

- **macOS**: 15.0 (Sequoia) 或更高版本
- **架构**: Apple Silicon (arm64)
- **Mac**: M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3 等

## 🔧 开发模式

### 快速测试

```bash
# 直接运行（不安装）
swift run
```

### 调试构建

```bash
# Debug 模式构建
swift build

# 运行 debug 版本
.build/debug/SnapApp
```

### 查看构建日志

```bash
# 详细构建日志
swift build -c release --arch arm64 -v
```

## 📝 首次使用

### 1. 授予权限

首次运行需要授予屏幕录制权限：

1. 打开 **系统设置**
2. 进入 **隐私与安全性** → **屏幕录制**
3. 找到并勾选 **Snap**
4. 重启应用

### 2. 允许打开应用

如果 macOS 提示"无法验证开发者"：

**方法 1**: 右键打开
1. 右键点击 Snap.app
2. 选择"打开"
3. 点击"打开"确认

**方法 2**: 终端命令
```bash
xattr -cr /Applications/Snap.app
```

**方法 3**: 系统设置
1. 系统设置 → 隐私与安全性
2. 找到 Snap 的提示
3. 点击"仍要打开"

## 🔄 更新应用

```bash
# 1. 拉取最新代码
git pull

# 2. 重新构建
./build-local.sh

# 3. 重新安装
sudo cp -r .build/release/Snap.app /Applications/
```

## 🧹 清理

```bash
# 清理构建产物
make clean

# 完全清理（包括依赖）
rm -rf .build .swiftpm
swift package clean
```

## 📊 构建产物

构建成功后，你会在 `.build/release/` 目录看到：

```
.build/release/
├── Snap.app/           # 完整的应用包
│   └── Contents/
│       ├── Info.plist
│       ├── MacOS/
│       │   └── Snap    # 可执行文件
│       └── Resources/
└── SnapApp             # 原始可执行文件
```

## 💡 实用技巧

### 构建并立即运行

```bash
./build-local.sh && open .build/release/Snap.app
```

### 安装并运行

```bash
make install && open /Applications/Snap.app
```

### 监控内存使用

```bash
# 运行应用后，在另一个终端
ps aux | grep Snap

# 或使用 Activity Monitor
open -a "Activity Monitor"
```

### 查看应用日志

```bash
# 系统日志
log stream --predicate 'processImagePath contains "Snap"'

# 或使用 Console.app
open -a Console
```

## 🐛 故障排除

### 构建失败

```bash
# 清理并重试
make clean
rm -rf .build
swift package clean
swift package resolve
./build-local.sh
```

### 应用无法打开

```bash
# 移除隔离属性
xattr -cr /Applications/Snap.app

# 验证应用结构
ls -la /Applications/Snap.app/Contents/MacOS/
```

### 权限问题

```bash
# 重置权限数据库
tccutil reset ScreenCapture com.snap.screenshot

# 重新打开应用并授予权限
```

## 📚 更多信息

- [README.md](README.md) - 项目概述
- [ARCHITECTURE.md](ARCHITECTURE.md) - 技术架构
- [TESTING.md](TESTING.md) - 测试指南

## 🆘 需要帮助？

如果遇到问题：
1. 查看 [TROUBLESHOOTING.md](TROUBLESHOOTING.md)（如果存在）
2. 检查系统日志
3. 提交 Issue 到 GitHub

---

**专为 M1 Pro macOS 26 优化** 🚀
