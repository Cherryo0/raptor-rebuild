# Roadmap

## 0.1.0 — Scaffold (done, 2026-10-25)
- SwiftUI app skeleton, safe installer + quickfix, Python API prototype + mocked tests, research docs, 18 module docs, malware trust check.

## 0.2.0 — App completeness (planned)
- Xcode project file (create in Xcode; bundle id `dev.raptor.rebuild`).
- System file picker for Open/Save (replacing the sample-load placeholder in `AppState.openScriptFromDisk`).
- Keychain-backed licence key storage (see module 03 open questions).
- UserDefaults persistence for `AppSettings`.
- Real `URLSession` version check against a configurable HTTPS endpoint (no binary download).

## 0.3.0 — Quality
- Swift unit tests (ScriptTab, ScriptStore, LicensingService format validation).
- UI snapshot checks for ContentView / SettingsView.
- `shellcheck` in CI; `swiftlint` if adopted.

## Explicitly out of scope (never)
- Live Roblox injection, dylib injection, codesign stripping, HWID spoofing, server desync, anti-cheat bypass, Luau execution in Roblox, binary downloads, opaque binaries, secrets in URLs.
