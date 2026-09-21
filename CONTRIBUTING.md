# Contributing to BandwagonKit

Thank you for your interest in contributing to **BandwagonKit**! We welcome bug reports, feature requests, documentation improvements, and code contributions.

Please review this document before submitting contributions to ensure a smooth collaboration process.

---

## Code of Conduct

All contributors and participants are expected to adhere to our [Code of Conduct](CODE_OF_CONDUCT.md). Please report unacceptable behavior to **steveshi.dev@gmail.com**.

---

## Architecture Overview

BandwagonKit follows a clean, decoupled architecture:

- **`Packages/BandwagonAPI`**: Zero-dependency async/await network client for KiwiVM REST API. Platform-independent.
- **`Packages/BandwagonCore`**: Business logic, `@Observable` state management, Keychain services, polling services. Platform-independent.
- **`BandwagonKit/`**: macOS application layer implementing the **Liquid Glass** aesthetic (SwiftUI, macOS 26 Tahoe+).
- **`BandwagonKitMobile/`** *(Planned Phase 2)*: iOS application target reusing `BandwagonAPI` and `BandwagonCore`.

---

## Development Setup

### Prerequisites
- macOS 15.0+ (macOS 26 Tahoe recommended)
- Xcode 16.0+ (Xcode 27 recommended)
- Swift 6.0+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

### Getting Started
1. Clone your fork of the repository:
   ```bash
   git clone https://github.com/<your-username>/BandwagonKit.git
   cd BandwagonKit
   ```
2. Generate the Xcode project:
   ```bash
   xcodegen generate
   ```
3. Open `BandwagonKit.xcodeproj` in Xcode.

---

## Contribution Workflow

1. **Check Existing Issues**: Check if the bug or feature is already discussed in the issue tracker.
2. **Create a Topic Branch**: Always branch from `main` (never use `master`):
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Develop & Verify**:
   - Write clean, idiomatic Swift adhering to Swift 6 Concurrency standards.
   - **Zero Hardcoded Strings**: All user-visible strings **must** be localized in [`BandwagonKit/Resources/Localizable.xcstrings`](BandwagonKit/Resources/Localizable.xcstrings) (English and Simplified Chinese).
   - **Liquid Glass Consistency**: Respect depth, translucency, and strictly aligned 8pt grid typography.
4. **Run Unit Tests**:
   ```bash
   swift test --package-path Packages/BandwagonAPI
   swift test --package-path Packages/BandwagonCore
   ```
5. **Verify Project Build**:
   ```bash
   xcodegen generate
   xcodebuild -scheme BandwagonKit -destination 'platform=macOS' build
   ```
6. **Commit with Clear Messages**: Follow conventional commits (e.g., `feat: ...`, `fix: ...`, `docs: ...`).
7. **Open a Pull Request**: Submit your PR targeting the `main` branch with a comprehensive description of the changes.

---

## License

By contributing to BandwagonKit, you agree that your contributions will be licensed under the [Mozilla Public License Version 2.0](LICENSE).
