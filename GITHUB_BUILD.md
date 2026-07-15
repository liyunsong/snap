# 在 GitHub 上构建 Snap

无需本地 Mac，直接在 GitHub Actions 上构建！

## 🚀 自动构建

每次推送代码到 GitHub，会自动触发构建。

### 触发构建

#### 方法 1: 推送代码（自动触发）

```bash
# 任意代码更改
git add .
git commit -m "Update code"
git push
```

GitHub Actions 会自动开始构建。

#### 方法 2: 手动触发

1. 访问: https://github.com/liyunsong/snap/actions
2. 点击 **Build Snap** workflow
3. 点击右上角 **Run workflow** 按钮
4. 选择分支（如 `cursor/macos-screenshot-app-0af3`）
5. 点击 **Run workflow**

## 📥 下载构建结果

### 步骤 1: 查看构建状态

1. 访问: https://github.com/liyunsong/snap/actions
2. 找到最新的 **Build Snap** 运行
3. 等待构建完成（约 2-3 分钟）
4. 看到绿色 ✅ 表示构建成功

### 步骤 2: 下载应用

1. 点击构建完成的 workflow 运行
2. 向下滚动到 **Artifacts** 部分
3. 点击 **Snap-macOS-AppleSilicon** 下载
4. 下载的是 ZIP 文件：`Snap-arm64.zip`

### 步骤 3: 安装应用

```bash
# 1. 解压下载的文件
unzip ~/Downloads/Snap-arm64.zip

# 2. 移动到 Applications
cp -r Snap.app /Applications/

# 3. 移除隔离属性
xattr -cr /Applications/Snap.app

# 4. 打开应用
open /Applications/Snap.app
```

或者使用 Finder：
1. 双击解压 `Snap-arm64.zip`
2. 拖动 `Snap.app` 到 `/Applications/` 文件夹
3. 右键点击 Snap.app → 打开

## 🔄 更新应用

### 方法 1: 推送新代码后下载

```bash
# 1. 更新代码
git add .
git commit -m "Update features"
git push

# 2. 等待 GitHub Actions 构建完成
# 3. 下载新的构建结果
# 4. 重新安装
```

### 方法 2: 手动触发构建

1. 访问 Actions 页面
2. 手动触发 **Build Snap** workflow
3. 下载新构建
4. 重新安装

## 📊 构建信息

### 构建环境
- **系统**: macOS 14 (Sonoma)
- **架构**: Apple Silicon (arm64)
- **Xcode**: 最新稳定版
- **Swift**: 5.9+

### 构建产物
- **应用包**: `Snap.app`
- **ZIP 文件**: `Snap-arm64.zip`
- **保留时间**: 30 天
- **文件大小**: 约 5-10 MB

### 构建时间
- **首次构建**: 约 3-5 分钟（需要下载依赖）
- **后续构建**: 约 2-3 分钟（有缓存）

## 🔍 查看构建日志

1. 访问: https://github.com/liyunsong/snap/actions
2. 点击任意构建运行
3. 点击 **Build for Apple Silicon** 任务
4. 展开各个步骤查看详细日志

### 关键步骤
- **Resolve dependencies** - 下载依赖
- **Build for Apple Silicon** - 编译代码
- **Create .app bundle** - 创建应用包
- **Create ZIP archive** - 打包
- **Upload artifact** - 上传到 GitHub

## ⚠️ 常见问题

### Q: 构建失败怎么办？

**A**: 查看构建日志找出错误：
1. 打开失败的 workflow 运行
2. 查看红色 ❌ 的步骤
3. 展开查看详细错误信息

常见错误：
- **依赖问题**: 运行 `swift package clean && swift package resolve`
- **语法错误**: 检查最近的代码更改
- **权限问题**: 检查 GitHub Actions 设置

### Q: 构建时间太长？

**A**: 首次构建需要下载依赖（约 5 分钟）。后续构建会利用缓存，只需 2-3 分钟。

### Q: 无法下载 Artifact？

**A**: 
- 确保你登录了 GitHub
- Artifacts 有 30 天保留期
- 检查浏览器是否阻止下载

### Q: 下载的应用无法打开？

**A**: 运行以下命令移除隔离属性：
```bash
xattr -cr /Applications/Snap.app
```

## 💡 高级用法

### 为特定提交构建

```bash
# 1. 创建特定的提交
git commit -m "Build version 1.0.1"
git push

# 2. 在 GitHub Actions 中找到该提交的构建
# 3. 下载对应的 Artifact
```

### 构建不同分支

1. 切换到目标分支
   ```bash
   git checkout feature-branch
   git push
   ```

2. GitHub Actions 会自动为该分支构建

3. 或手动触发时选择分支

### 禁用自动构建

如果不想每次推送都构建，编辑 `.github/workflows/build.yml`：

```yaml
on:
  workflow_dispatch:  # 仅手动触发
```

## 📚 相关文档

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [查看所有构建](https://github.com/liyunsong/snap/actions)
- [Swift Package Manager](https://swift.org/package-manager/)

## 🆘 获取帮助

如果遇到问题：

1. **查看构建日志**
   - Actions → 选择运行 → 查看步骤

2. **搜索 Issues**
   - https://github.com/liyunsong/snap/issues

3. **提交新 Issue**
   - 包含构建日志和错误信息

4. **检查 Actions 状态**
   - https://www.githubstatus.com/

## ✅ 快速参考

```bash
# 触发构建
git push

# 查看构建
open https://github.com/liyunsong/snap/actions

# 安装应用
unzip ~/Downloads/Snap-arm64.zip
cp -r Snap.app /Applications/
xattr -cr /Applications/Snap.app
open /Applications/Snap.app
```

---

**享受自动化构建！** 🚀

所有构建都在 GitHub 的服务器上完成，你只需下载结果即可！
