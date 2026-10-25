# Architecture Decision Records

## ADR-001 — SwiftUI over AppKit
- **Status:** Accepted
- **Context:** macOS app shell needs editor, tabs, hub, settings, licensing views.
- **Decision:** SwiftUI, macOS 13+, Xcode 15+, Swift 5.9.
- **Consequences:** Declarative state via `AppState`; faster rebuild; AppKit retained only if a native control is unavailable.

## ADR-002 — Safe installer (rewrite, not a patch of the original)
- **Status:** Accepted
- **Context:** Original v4.1 installer is `curl|bash`, no checksums, HTTP Roblox fetch, destructive deletes, secrets in GET.
- **Decision:** Rewrite from scratch: local reviewed script, HTTPS only, checksum field (placeholder), backup before replace, explicit confirmation, `--dry-run` / `--help`, launcher placeholder + scripts dir only.
- **Consequences:** The installer cannot install the original product and never will; that is intentional.

## ADR-003 — Injection bridge is a stub only
- **Status:** Accepted
- **Context:** Live injection violates Roblox ToS and the original mechanism is a malware-indicator pattern.
- **Decision:** `InjectionBridge` is a protocol + stub returning `.notImplemented` with a clear reason. No `insert_dylib`, no codesign stripping, no dylib.
- **Consequences:** The app cannot execute scripts in Roblox. The Execute button reports this honestly.

## ADR-004 — Python API client prototype
- **Status:** Accepted
- **Context:** Version/licence protocol needs a testable prototype.
- **Decision:** Python 3.11+, stdlib `urllib` only, mocked pytest, keys via env/stdin, POST + Authorization header.
- **Consequences:** No third-party dependencies; tests run with no network.

## ADR-005 — Per-module documentation (18 files)
- **Status:** Accepted
- **Context:** User asked for one detailed MD per module in a separate folder.
- **Decision:** `docs/modules/NN-*.md`, each with Purpose / Observed behaviour / Clean-room design / Public API / Data flow / Files / Config / Edge cases / Security / Tests / Open questions.
- **Consequences:** Docs stay in sync with code via the CONTRIBUTING rule (same PR updates both).
