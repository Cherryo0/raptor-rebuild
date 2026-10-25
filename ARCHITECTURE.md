# Architecture

See also `docs/ARCHITECTURE.md`, `docs/DECISIONS.md`, and `docs/modules/01-product-overview.md`.

## System overview

```
┌─────────────────────────────────────────────────────────────┐
│  Raptor (SwiftUI, macOS 13+)                                │
│  ContentView ── TabBarView ── ScriptEditorView              │
│       │              │              │                       │
│  AppState (ObservableObject, single source of truth)        │
│       │              │              │                       │
│  ScriptStore ── LicensingService ── UpdaterService          │
│       │              │              │                       │
│  InjectionBridge (STUB ONLY — .notImplemented)              │
└─────────────────────────────────────────────────────────────┘
        │                       │                  │
   ~/Documents/RaptorUI/   api-client/ (Python)  installer/
   (local scripts dir)     version / licence     safe install
                           POST stubs, mocked    launcher only
                           tests, no network
```

## Layers

| Layer | Responsibility | Technology |
|---|---|---|
| UI | Editor, tabs, hub, settings, licensing views | SwiftUI, macOS 13+ |
| State | Tabs, files, settings, licence state | `AppState` (`@MainActor`, `ObservableObject`) |
| Services | Persistence, licensing, API, updates | Swift services, `URLSession` (HTTPS only) |
| Injection | Interface only | `InjectionBridge` stub — no implementation |
| Installer | Launcher placeholder + scripts dir | Bash, `--dry-run`, backup, confirmation |
| API prototype | Version/licence client logic | Python 3.11+, `urllib`, mocked pytest |

## Key decisions

- **SwiftUI over AppKit** (ADR-001): faster UI rebuild, declarative state; AppKit retained only if a native control is unavailable.
- **Stub injection** (ADR-003): live injection is intentionally omitted — Roblox ToS, safety, and the malware-trust warning.
- **Python API client** (ADR-004): prototype the version/licence protocol quickly and test it with mocked HTTP.
- **Safe installer** (ADR-002): HTTPS, checksums, backup, confirmation, no `curl|bash`.

## Data flow — opening a script

1. `ScriptStore` reads `~/Documents/RaptorUI/*.lua` (local files only).
2. `AppState.openTab(for:)` creates a `ScriptTab` (id, title, content, `isDirty`).
3. `ScriptEditorView` binds to the tab's content; edits set `isDirty = true`.
4. Save writes through `ScriptStore` with an atomic write (`.atomic` option).

## Data flow — licensing (stub)

1. User enters a key in `LicensingView` (never persisted in plain text in this skeleton — stored in memory only; Keychain integration is an open question in `docs/modules/03-licensing-sellix-hwid.md`).
2. `LicensingService.activate(key:)` validates format locally, then calls `ApiClient` — which in this repo is a stub returning `.notImplemented` for the live endpoint.
3. The Python prototype mirrors the same POST shape with key from env/stdin.

## Non-goals

Injection, HWID spoofing, desync, bypass, Luau execution in Roblox, any binary download or patching of Roblox.app.
