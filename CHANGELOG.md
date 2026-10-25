# Changelog

All notable changes to this project will be documented in this file. Format follows Keep a Changelog; versioning follows SemVer.

## [Unreleased]

### Added
- One-liner Mac install: `installer/bootstrap.sh` — clones the public repo into `~/raptor-rebuild` and runs the safe installer. Usable as `cd ~/ && curl -fsSL https://raw.githubusercontent.com/Cherryo0/raptor-rebuild/main/installer/bootstrap.sh | bash </dev/tty`, with `--dry-run` / `--force` / `--dir` / `--ref` options. Documented in `installer/README.md` and `docs/modules/02-installer.md`.

### Fixed
- `installer/bootstrap.sh`: removed all bash array use — expanding an empty array under `set -u` aborts on macOS's stock bash 3.2 with `args[@]: unbound variable` (line 104), while newer bash tolerates it, so Linux tests had passed. Flags are now passed with explicit branches; the script is written for bash 3.2 throughout.
- `installer/quickfix.sh`: create `~/Downloads` before rewriting `raptor-version.json` (same fresh-HOME bug as `install.sh`).
- `scripts/check.sh`: now syntax-checks `installer/bootstrap.sh` too.
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
