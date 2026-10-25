# Module 09 — Injection Bridge

| Field | Value |
|---|---|
| Status | STUB ONLY — intentionally unimplemented |
| Owner area | App/Services/InjectionBridge.swift |
| Related research | docs/research/02-install-sh-analysis.md, 04-malware-trust-check.md |

## Purpose
Define the boundary where live injection would sit — as an interface and a stub that always refuses — so the omission is explicit, reviewable, and honest.

## Public behaviour observed
Original: insert_dylib @rpath/macsploit.dylib into RobloxPlayer after codesign --remove-signature, then ad-hoc codesign -s '-'. 4 dylib endpoints by preview/arm64. Auto Inject claimed.

## Clean-room design
InjectionBridgeProtocol: attach() / execute(script:) / detach() async -> InjectionResult. InjectionBridgeStub implements all three returning .notImplemented(reason:) with a message citing Roblox ToS and this module's doc. InjectionResult: notImplemented(reason:) | attached | failed(reason:). The .attached case exists only so the type is complete; no code path can produce it. Callers (ScriptEditorView Execute button) surface the reason in the UI.

## Public API / types
```
protocol InjectionBridgeProtocol { attach() async -> InjectionResult; execute(script:) async -> InjectionResult; detach() async -> InjectionResult }
struct InjectionBridgeStub: InjectionBridgeProtocol
static let notImplementedReason: String
```

## Data flow
UI action -> InjectionBridgeStub.attach/execute -> .notImplemented -> UI displays the reason. No process is ever opened, no library loaded, no signature touched.

## Files
App/Services/InjectionBridge.swift; App/Views/ScriptEditorView.swift (Execute button)

## Config
None.

## Edge cases
Any caller must handle .notImplemented as a normal result, not an error to retry. Never map it to a fake success.

## Security notes
This stub is a safety control, not a placeholder to fill in. Implementing live injection would require violating Roblox ToS and reintroducing the exact code-injection pattern flagged in research 04. It is out of scope permanently unless the user explicitly re-scopes the project with full awareness.

## Tests
Planned Swift tests: all three methods return .notImplemented; reason mentions ToS / out of scope. Manual: Execute button shows the message.

## Open questions
None — the stub is the final state for this project as scoped.
