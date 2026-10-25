# Changelog

All notable changes to this project will be documented in this file. Format follows Keep a Changelog; versioning follows SemVer.

## [Unreleased]

### Added
- Initial clean-room rebuild: SwiftUI macOS app skeleton (editor, tabs, hub, settings, licensing).
- Safe installer rewrite (`installer/install.sh`) and repair script (`installer/quickfix.sh`) — launcher placeholder + UI scripts dir only.
- Python API client prototype (`api-client/`) with mocked pytest suite.
- Research docs: raptor.fun findings, install.sh analysis (v4.1, SHA256 ebb3abbf…), reverse-skill methodology, malware trust check.
- 18 per-module docs under `docs/modules/`, plus `docs/ROADMAP.md` and `docs/DECISIONS.md`.
- Root `ARCHITECTURE.md`, `CONTRIBUTING.md`, `SECURITY.md`, MIT `LICENSE`.

### Security
- Injection bridge is a stub only (`.notImplemented`); no dylib injection, codesign stripping, HWID spoofing, or Luau execution against Roblox.
- Installer: HTTPS only, `--dry-run`, backup before replace, confirmation before deletes, no secrets in URLs.

## [0.1.0] — 2026-10-25
- Project scaffold created.
