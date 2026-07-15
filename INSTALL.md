# Snap 安装指南 - M1 Pro macOS 26

专为 Apple Silicon Mac 设计的简单安装指南。

## 🚀 快速安装（3 步）

### 步骤 1: 构建应用

```bash
# 进入项目目录
cd snap

# 运行构建脚本
./build-local.sh
```

### 步骤 2: 安装应用

```bash
# 复制到 Applications 文件夹
sudo cp -r .build/release/Snap.app /Applications/
```

### 步骤 3: 启动应用

```bash
# 打开应用
open /Applications/Snap.app
```

完成！📸

## 📋 详细步骤

### 准备工作

确保你已经安装了 Xcode Command Line Tools：

```bash
xcode-select --install
```

### 构建

```bash
# 克隆仓库（如果还没有）
git clone https://github.com/liyunsong/snap.git
cd snap

# 清理之前的构建（可选）
make clean

# 构建应用
./build-local.sh
```

### 安装

#### 方法 1: 命令行安装（推荐）

```bash
sudo cp -r .build/release/Snap.app /Applications/
```

#### 方法 2: Makefile 安装

```bash
make install
```

#### 方法 3: 手动安装

1. 在 Finder 中打开 `.build/release/`
2. 将 `Snap.app` 拖到 `/Applications/` 文件夹

### 首次运行

1. **打开应用**
   ```bash
   open /Applications/Snap.app
   ```
   
   或在 Spotlight 搜索 "Snap"

2. **授予权限**
   
   应用会请求屏幕录制权限：
   - 点击 "打开系统设置"
   - 或手动：系统设置 → 隐私与安全性 → 屏幕录制
   - 勾选 "Snap"
   
3. **允许打开应用**（如果出现警告）
   
   如果看到"无法验证开发者"警告：
   
   **方法 A**: 右键打开
   - 右键点击 Snap.app
   - 选择"打开"
   - 点击"打开"
   
   **方法 B**: 使用终端
   ```bash
   xattr -cr /Applications/Snap.app
   open /Applications/Snap.app
   ```

4. **重启应用**
   
   授予权限后，退出并重新打开 Snap

## ✅ 验证安装

### 检查应用是否安装

```bash
ls -la /Applications/Snap.app
```

应该看到应用的详细信息。

### 测试基本功能

1. **检查菜单栏图标**
   - 菜单栏应该显示 📷 图标

2. **测试区域截图**
   - 按 `⌘ + ⇧ + A`
   - 拖拽选择区域
   - 应该打开编辑器

3. **测试全屏截图**
   - 按 `⌘ + ⇧ + S`
   - 应该捕获整个屏幕

4. **测试编辑工具**
   - 选择一个工具（矩形、圆形等）
   - 在截图上绘制
   - 点击"复制"或"保存"

## 🔄 更新

更新到新版本：

```bash
# 1. 拉取最新代码
cd snap
git pull

# 2. 重新构建
./build-local.sh

# 3. 重新安装
sudo cp -r .build/release/Snap.app /Applications/
```

## 🗑️ 卸载

如果需要卸载 Snap：

```bash
# 删除应用
sudo rm -rf /Applications/Snap.app

# 删除配置（如果有）
rm -rf ~/Library/Preferences/com.snap.screenshot.plist
rm -rf ~/Library/Application\ Support/Snap
```

## 🐛 常见问题

### Q: 构建失败，提示找不到 Swift

**A**: 安装 Xcode Command Line Tools：
```bash
xcode-select --install
```

### Q: 应用无法打开，提示"已损坏"

**A**: 移除隔离属性：
```bash
xattr -cr /Applications/Snap.app
```

### Q: 没有屏幕录制权限

**A**: 手动添加权限：
1. 系统设置 → 隐私与安全性 → 屏幕录制
2. 点击 "+" 添加 Snap
3. 重启应用

### Q: 快捷键不工作

**A**: 检查是否与系统快捷键冲突：
1. 系统设置 → 键盘 → 键盘快捷键
2. 检查是否有冲突
3. 在 Snap 中自定义快捷键

### Q: 构建很慢

**A**: 首次构建会下载依赖，需要一些时间。后续构建会快很多。

## 💡 实用技巧

### 开机自动启动

1. 系统设置 → 通用 → 登录项
2. 点击 "+" 添加 Snap
3. 下次开机会自动启动

### 自定义快捷键

1. 点击菜单栏的 Snap 图标
2. 选择"设置"
3. 点击快捷键录制器
4. 按下你想要的快捷键组合

### 查看内存使用

```bash
# 查看 Snap 进程
ps aux | grep Snap

# 或使用 Activity Monitor
open -a "Activity Monitor"
```

## 📊 性能监控

### 使用 Activity Monitor

1. 打开 Activity Monitor
2. 搜索 "Snap"
3. 查看 CPU 和内存使用

### 命令行监控

```bash
# 实时监控
top -pid $(pgrep -x Snap)

# 内存详情
vmmap $(pgrep -x Snap) | grep -i "MALLOC"
```

## 🔧 开发模式

如果你想修改代码：

```bash
# 1. 编辑源代码
# 2. 测试运行
swift run

# 3. 调试构建
swift build
.build/debug/SnapApp

# 4. 发布构建
./build-local.sh
```

## 📚 更多资源

- [LOCAL_BUILD.md](LOCAL_BUILD.md) - 详细构建指南
- [README.md](README.md) - 项目概述
- [ARCHITECTURE.md](ARCHITECTURE.md) - 技术架构

## 🆘 需要帮助？

如果遇到问题：
1. 查看 [GitHub Issues](https://github.com/liyunsong/snap/issues)
2. 提交新的 Issue
3. 查看系统日志：`log stream --predicate 'processImagePath contains "Snap"'`

---

**享受你的截图体验！** 📸
