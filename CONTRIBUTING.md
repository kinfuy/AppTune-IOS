# 贡献指南

感谢您对 AppTune 项目的关注！我们欢迎所有形式的贡献。

## 🤝 如何贡献

### 报告 Bug

如果您发现了一个 bug，请通过以下步骤报告：

1. 在 [Issues](https://github.com/your-username/AppTune/issues) 页面搜索是否已经存在相关报告
2. 如果不存在，请创建一个新的 Issue
3. 使用 "Bug" 标签
4. 提供详细的复现步骤，包括：
   - 操作系统版本
   - iOS 版本
   - 应用版本
   - 具体的操作步骤
   - 期望的行为和实际的行为

### 功能建议

如果您有功能建议，请：

1. 在 [Discussions](https://github.com/your-username/AppTune/discussions) 中发起讨论
2. 详细描述您的建议和用例
3. 说明这个功能如何让用户受益

### 代码贡献

#### 环境准备

1. 确保您的开发环境满足要求：
   - Xcode 15.0+
   - iOS 15.0+
   - Swift 5.9+

2. Fork 项目到您的 GitHub 账户

3. 克隆您的 fork：
```bash
git clone https://github.com/your-username/AppTune.git
cd AppTune
```

#### 开发流程

1. **创建分支**
```bash
git checkout -b feature/your-feature-name
```

2. **开发功能**
   - 遵循项目的代码规范
   - 添加必要的测试
   - 更新相关文档

3. **提交代码**
```bash
git add .
git commit -m "feat: 添加新功能描述"
```

4. **推送分支**
```bash
git push origin feature/your-feature-name
```

5. **创建 Pull Request**
   - 在 GitHub 上创建 Pull Request
   - 填写详细的描述
   - 添加相关的 Issue 链接

#### 代码规范

##### Swift 代码规范

- 遵循 [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
- 使用 4 空格缩进
- 行长度不超过 120 字符
- 使用有意义的变量和函数名

##### 提交信息规范

使用 [Conventional Commits](https://www.conventionalcommits.org/) 格式：

- `feat:` 新功能
- `fix:` Bug 修复
- `docs:` 文档更新
- `style:` 代码格式调整
- `refactor:` 代码重构
- `test:` 测试相关
- `chore:` 构建过程或辅助工具的变动

示例：
```
feat: 添加用户登录功能
fix: 修复列表刷新问题
docs: 更新 README 文档
```

#### 测试要求

- 新功能必须包含单元测试
- UI 组件需要 UI 测试
- 确保所有测试通过

#### 代码审查

所有 Pull Request 都需要经过代码审查：

1. 至少需要一名维护者的批准
2. 所有 CI 检查必须通过
3. 代码必须符合项目规范

## 📋 贡献类型

### 🐛 Bug 修复
- 修复应用中的错误
- 改进错误处理
- 提升应用稳定性

### ✨ 新功能开发
- 添加用户请求的功能
- 改进现有功能
- 优化用户体验

### 📝 文档改进
- 更新 README 文档
- 添加代码注释
- 编写使用教程

### 🎨 UI/UX 优化
- 改进界面设计
- 优化用户交互
- 提升视觉效果

### ⚡ 性能优化
- 提升应用性能
- 减少内存使用
- 优化启动时间

### 🔧 代码重构
- 改进代码结构
- 提升代码可读性
- 减少代码重复

## 🏷️ Issue 标签说明

- `bug`: 错误报告
- `enhancement`: 功能增强
- `documentation`: 文档相关
- `good first issue`: 适合新手的简单问题
- `help wanted`: 需要帮助的问题
- `question`: 问题咨询

## 📞 获取帮助

如果您在贡献过程中遇到问题：

1. 查看 [Issues](https://github.com/your-username/AppTune/issues) 是否有类似问题
2. 在 [Discussions](https://github.com/your-username/AppTune/discussions) 中提问
3. 联系项目维护者

## 🙏 致谢

感谢所有为 AppTune 项目做出贡献的开发者！您的贡献让这个项目变得更好。

---

**注意**: 通过贡献代码，您同意您的贡献将在 MIT 许可证下发布。 
