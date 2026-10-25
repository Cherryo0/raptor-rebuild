# Raptor Rebuild — Clean-Room Educational Rebuild of MacSploit (raptor.fun)

A clean-room, educational rebuild of the **application shell, installer, licensing client, editor UI and architecture** of MacSploit, the macOS Roblox script executor sold at [raptor.fun](https://www.raptor.fun/) by developer Nexus42.

This project **does not** contain, implement, or enable Roblox injection, dylib injection, code-signature stripping, HWID spoofing, server desync, anti-cheat bypass, or Luau bytecode execution against Roblox. The injection bridge is an interface + stub that returns `.notImplemented`. See [SECURITY.md](SECURITY.md) and [docs/modules/09-injection-bridge.md](docs/modules/09-injection-bridge.md).

> **Trust warning — treat the original as potentially malware until proven otherwise.** The original installer (`curl | bash`, unsigned binaries, HWID exfiltration, licence key in a GET query, plain-HTTP Roblox download, `codesign --remove-signature`, dylib injection) exhibits multiple suspicious behaviours. See [docs/research/04-malware-trust-check.md](docs/research/04-malware-trust-check.md). This rebuild deliberately removes every one of those behaviours. No original binary, dylib, zip, key, or HWID is downloaded, included, or executed anywhere in this project.

## What it is / is not

| Area | Original (observed) | This rebuild |
|---|---|---|
| App shell / editor UI | macOS app, Script Editor V1, tab system (TABSYS) | SwiftUI skeleton, macOS 13+, Xcode 15+ |
| Installer | `curl -s https://api.macsploit.dev/main/install.sh \| bash`, v4.1 | Safe rewrite: HTTPS only, `--dry-run`, backup before replace, confirmation, no `curl\|bash` |
| Licensing | Sellix key + HWID whitelist via GET | POST stubs, key from env/stdin only, no GET secrets |
| Versioning | `api.macsploit.dev/main/version.json` | Python API client, mocked tests, no network in tests |
| Injection | `insert_dylib`, codesign stripping, `macsploit.dylib` | **Stub only — intentionally omitted** |
| HWID spoofer / desync / bypass | Claimed features | **Not implemented, out of scope** |
| Script execution vs Roblox | Executes Luau in Roblox | Editor samples only — harmless local demo scripts, never sent to Roblox |

## Features (clean-room)

- Script Editor V1-style SwiftUI editor with syntax-adjacent plain-text editing, line counts, save/load.
- Powerful Tab System (TABSYS): multiple tabs, new/close/rename, dirty-state tracking.
- Auto Execute: user-configured local script folder (`~/Documents/RaptorUI/AutoExecute`) — lists scripts that *would* auto-run on attach in the original; here it only lists and previews them, it never executes them against Roblox.
- Script Hub / library: bundled harmless sample scripts, searchable, importable into a tab.
- Script Dumper (SPE): stub — documents the original's `~/Documents/Macsploit/Dumped` location; no dumping implemented.
- Settings & sandbox: presence (Discord) settings as local toggles only (no Discord RPC calls), FPS / sandbox toggles as stored preferences with no effect on Roblox.
- Licensing view: Sellix key entry (stdin/env only in the CLI client), HWID shown as a locally computed, never-uploaded identifier in the stub client.
- Updater: version check against a configurable HTTPS endpoint, checksum field (placeholder — no binary is ever downloaded by this project).
- Multi-instance / accounts: data model for multiple profiles and cookie-switcher UI state only; no Roblox account switching is performed.

## Install on your Mac (one-liner)

```bash
cd ~/ && curl -fsSL https://raw.githubusercontent.com/Cherryo0/raptor-rebuild/main/installer/bootstrap.sh | bash </dev/tty
```

That clones this repo into `~/raptor-rebuild` and runs the safe installer
(launcher placeholder + `~/Documents/RaptorUI` only — no binaries, no licence
key, never touches Roblox). Prefer to read it first? Download, inspect, run:

```bash
curl -fsSL https://raw.githubusercontent.com/Cherryo0/raptor-rebuild/main/installer/bootstrap.sh -o /tmp/raptor-bootstrap.sh
less /tmp/raptor-bootstrap.sh
bash /tmp/raptor-bootstrap.sh
```

## Quickstart (macOS)

```bash
# 1. Clone
git clone https://github.com/Cherryo0/raptor-rebuild.git raptor-rebuild && cd raptor-rebuild

# 2. Check the tree / run static checks
./scripts/check.sh

# 3. Safe installer (launcher placeholder + UI scripts dir ONLY — never patches Roblox)
./installer/install.sh --help
./installer/install.sh --dry-run
./installer/install.sh

# 4. Repair / verify an install
./installer/quickfix.sh --dry-run
./installer/quickfix.sh

# 5. API client prototype (Python 3.11+)
cd api-client && python3 -m pip install -r requirements.txt
python3 -m pytest tests/ -q
RAPTOR_API_BASE=https://api.example.invalid python3 raptor_api.py version
```

Open `App/` in Xcode 15+ (macOS 13+ target) to build the SwiftUI app. There is no Xcode project file checked in yet — create one with Xcode (File → New → Project → App, SwiftUI, bundle id `dev.raptor.rebuild`) and add the files under `App/`. See [docs/modules/05-launcher-app.md](docs/modules/05-launcher-app.md).

## Repository layout

```
.
├── App/                    SwiftUI macOS app skeleton
├── installer/              install.sh (safe rewrite), quickfix.sh
├── api-client/             Python prototype + mocked pytest suite
├── scripts/                dev-setup.sh, check.sh
├── docs/
│   ├── research/           01 findings, 02 install.sh analysis, 03 reverse-skill, 04 malware trust check
│   ├── modules/            18 detailed per-module docs (one file per module)
│   ├── ARCHITECTURE.md     (see root ARCHITECTURE.md)
│   ├── ROADMAP.md
│   └── DECISIONS.md        Architecture Decision Records
├── ARCHITECTURE.md  CONTRIBUTING.md  CHANGELOG.md  SECURITY.md  LICENSE (MIT)
```

## Disclaimer

Educational / interoperability research only. Not affiliated with, endorsed by, or connected to raptor.fun, MacSploit, Nexus42, Roblox Corporation, Sellix, or the reverse-skill project. Roblox is a trademark of Roblox Corporation. Do not use this project to violate the Roblox Terms of Use, to inject into Roblox, or to circumvent any anti-cheat. The original product is paid software ($3.00/mo verified; lifetime price unconfirmed) — this rebuild is not a free copy of it and cannot execute scripts in Roblox.

## Credits

- Original product & site: raptor.fun / MacSploit, developer Nexus42.
- Methodology: [zhaoxuya520/reverse-skill](https://github.com/zhaoxuya520/reverse-skill) (MIT, 43,252 stars) — macos-reverse R31, thick-client R32, protocol-reverse R21, docs-generator R20. Methodology only; no code from that repo is vendored here.
- Research basis: public site pages and the public install script `https://api.macsploit.dev/main/install.sh` v4.1 (SHA256 `ebb3abbfe9b080c3a070d61c19600c74bda6c7b48d29f11ad91344a52cfdfd3e`, 181 lines), analysed without downloading or running any binary.
