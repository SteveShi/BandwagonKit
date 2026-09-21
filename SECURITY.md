# Security Policy

The BandwagonKit team takes the security and privacy of user credentials (VEIDs, API keys, and server infrastructure) extremely seriously.

---

## Supported Versions

We provide security updates and bug fixes for the current major release:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

---

## Reporting a Vulnerability

If you discover a security vulnerability or credential leak risk within BandwagonKit, **please do not open a public GitHub issue**.

Instead, report it directly via email to:
📧 **steveshi.dev@gmail.com**

Please include:
1. A description of the vulnerability and its potential impact.
2. Steps or proof-of-concept to reproduce the behavior.
3. Relevant environment details (macOS version, Xcode version, app build).

### What You Can Expect
- **Acknowledgement**: We will acknowledge receipt of your report within 48 hours.
- **Investigation**: We will triage the issue and determine an appropriate fix.
- **Coordination**: We will coordinate with you regarding release schedules and public disclosures.

---

## Security Architecture Principles

- **Zero Plaintext Storage**: VEID and API Key credentials are encrypted and stored exclusively in macOS **Keychain Services** (`kSecClassGenericPassword`), protected by system access controls.
- **Direct Communication**: BandwagonKit interacts directly with BandwagonHost API servers (`api.64clouds.com`). There are **no intermediary telemetry, relay, or proxy servers**.
- **Rate-Limiting Protection**: The built-in network client throttles outbound requests to prevent inadvertent API rate-limit suspensions.
