# BandwagonKit

[English](README.md) | [简体中文](README.zh-CN.md)

**BandwagonKit** 是一款采用 **Liquid Glass**（流动拟玻）视觉设计、专为 macOS 26 Tahoe+ 打造的原生管理工具。通过官方 KiwiVM REST API，实现多台 [搬瓦工 (BandwagonHost)](https://bandwagonhost.com/) VPS 主机的状态监控与全部后台运维控制。

---

## 核心特性

- 💎 **Liquid Glass 视觉设计**：专为 macOS 26 Tahoe 深度定制，融合自然通透的材质层次、高光边缘与流畅动效。
- 🖥️ **多主机管理**：便捷添加、分类与无缝切换多台搬瓦工 VPS，实时监控运行状态。
- ⚡ **实时资源监控**：实时展现 CPU 负载、RAM 内存占用、SSD 存储空间与月度流量配额进度条，支持后台自动轮询。
- 🕹️ **完整电源控制**：一键开机、关机、重启及强制关机（内置防误触二次确认弹窗）。
- 🚀 **一键直连外部 SSH 终端**：快速在本地外部终端发起 SSH 连接，自动检测并支持：
  - **Terminal.app (系统默认终端)**
  - **iTerm2**
  - **Ghostty**
  - **MacSSH**
  - **自定义终端**
- 📸 **快照与备份管理**：快照列表浏览、创建临时/永久快照、安全删除与一键全盘恢复。
- 🌐 **机房迁移管理**：查询可选目标机房、检测实时状态并触发跨机房平滑迁移。
- ⚙️ **系统与网络运维**：主机名自定义、PTR 反向解析记录设置、Root 密码重置、操作系统一键重装、IPv6 地址增删。
- 🔒 **安全与操作审计**：公钥管理、敏感操作审计日志回溯、实时 API 速率额度监控。
- 🔑 **Keychain 凭证保护**：VEID 与 API Key 敏感信息严格保存在 macOS 系统 **Keychain Services** 中。
- 📦 **全原生本地化**：零硬编码字符串，采用 `Localizable.xcstrings` 原生格式，完整支持英文与简体中文。

---

## 项目架构

BandwagonKit 采用模块化的 Swift Package 架构，保持 API 层与业务逻辑层完全解耦，为后续迁移 iOS 平台提供最大化复用保障：

```
BandwagonKit/
├── BandwagonKit/                  # macOS SwiftUI App Target (macOS 26+)
│   ├── App/                       # 应用生命周期与菜单命令
│   ├── Views/                     # SwiftUI 界面组件 (Liquid Glass 卡片与用量进度)
│   ├── Platform/                  # 平台系统适配器 (外部终端调用器)
│   └── Resources/                 # Localizable.xcstrings (英文 & 简体中文)
├── Packages/
│   ├── BandwagonAPI/              # 零第三方依赖的 async/await KiwiVM API 封装
│   │   ├── Sources/BandwagonAPI/
│   │   └── Tests/BandwagonAPITests/
│   └── BandwagonCore/             # 共享业务逻辑 (@Observable), Keychain, 自动轮询
│       ├── Sources/BandwagonCore/
│       └── Tests/BandwagonCoreTests/
└── project.yml                    # XcodeGen 工程配置文件
```

---

## 构建与运行

### 环境要求
- macOS 15.0+（推荐 macOS 26 Tahoe 以获得原生 Liquid Glass 效果）
- Xcode 16.0+（推荐 Xcode 27）
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

### 本地编译
```bash
# 1. 克隆代码仓库
git clone https://github.com/steveshi/BandwagonKit.git
cd BandwagonKit

# 2. 运行底层 Package 单元测试
swift test --package-path Packages/BandwagonAPI
swift test --package-path Packages/BandwagonCore

# 3. 生成 Xcode 工程
xcodegen generate

# 4. 构建 macOS Target
xcodebuild -scheme BandwagonKit -destination 'platform=macOS' build
```

---

## 作者与许可证

- **作者**：Steve Shi / 轩楝
- **Bundle ID**：`com.steveshi.bandwagonkit`
- **许可证**：MIT License
