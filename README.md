# BandwagonKit

[English](README.md) | [简体中文](README.zh-CN.md)

**BandwagonKit** is a native macOS application designed with the **Liquid Glass** aesthetic (tailored for macOS 26 Tahoe+) to monitor and manage multiple [BandwagonHost](https://bandwagonhost.com/) VPS instances via the official KiwiVM REST API.

---

## Highlights

- 💎 **Liquid Glass Design**: Native translucency, depth, and fluid animations tailored for macOS 26 Tahoe+.
- 🖥️ **Multi-VPS Management**: Add, organize, and toggle between multiple BandwagonHost servers with instantaneous health and usage gauges.
- ⚡ **Real-Time Resource Monitoring**: Live CPU load, RAM utilization, SSD disk space, and monthly bandwidth meters with auto-refreshing polling.
- 🕹️ **Power Operations**: One-click Start, Stop, Reboot, and Force Stop with built-in safety confirmation dialogs.
- 🚀 **One-Click External SSH Launch**: Launch SSH sessions into your favorite terminal emulator with automatic detection:
  - **Terminal.app**
  - **iTerm2**
  - **Ghostty**
  - **MacSSH**
  - **Custom**
- 📸 **Snapshot & Backup Management**: View existing snapshots, generate point-in-time images, delete expired images, or restore disk states with safe confirmation.
- 🌐 **Data Center Migration**: Inspect available target facilities, view migration status, and initiate live migrations.
- ⚙️ **System & Network Controls**: Hostname updates, reverse DNS (PTR) modifications, root password resetting, OS reinstallations, and IPv6 address allocation.
- 🔒 **Security & Audit Records**: View registered SSH public keys, audit logs, and live API rate-limit quotas.
- 🔑 **Secure Credentials**: Sensitive API keys and VEIDs are securely saved within macOS **Keychain Services**.
- 📦 **Zero Hardcoded Text**: 100% internationalized via `Localizable.xcstrings` supporting English and Simplified Chinese.

---

## Architecture

BandwagonKit adopts a modular Swift Package architecture to ensure effortless cross-platform porting to iOS:

```
BandwagonKit/
├── BandwagonKit/                  # macOS SwiftUI App Target (macOS 26+)
│   ├── App/                       # Application lifecycle & Menu bar commands
│   ├── Views/                     # SwiftUI views (Liquid Glass cards & gauges)
│   ├── Platform/                  # Native platform adapters (Terminal launcher)
│   └── Resources/                 # Localizable.xcstrings (en & zh-Hans)
├── Packages/
│   ├── BandwagonAPI/              # Zero-dependency async/await KiwiVM API client
│   │   ├── Sources/BandwagonAPI/
│   │   └── Tests/BandwagonAPITests/
│   └── BandwagonCore/             # Shared state (@Observable), Keychain, Polling
│       ├── Sources/BandwagonCore/
│       └── Tests/BandwagonCoreTests/
└── project.yml                    # XcodeGen project definition
```

---

## Build & Development

### Requirements
- macOS 15.0+ (macOS 26 Tahoe recommended for full Liquid Glass experience)
- Xcode 16.0+ (Xcode 27 recommended)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

### Building the Project
```bash
# 1. Clone repository
git clone https://github.com/steveshi/BandwagonKit.git
cd BandwagonKit

# 2. Run unit tests on packages
swift test --package-path Packages/BandwagonAPI
swift test --package-path Packages/BandwagonCore

# 3. Generate Xcode project
xcodegen generate

# 4. Build macOS scheme
xcodebuild -scheme BandwagonKit -destination 'platform=macOS' build
```

---

## Community & Contributing

- **[Contributing Guidelines](CONTRIBUTING.md)**: Workflow, coding conventions, and setup instructions.
- **[Code of Conduct](CODE_OF_CONDUCT.md)**: Contributor Covenant Code of Conduct.
- **[Security Policy](SECURITY.md)**: Security reporting and credential protection policies.

---

## Author & License

- **Author**: Steve Shi / 轩楝
- **Bundle ID**: `com.steveshi.bandwagonkit`
- **License**: [Mozilla Public License Version 2.0 (MPL-2.0)](LICENSE)

