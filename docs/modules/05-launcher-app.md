# Module 05 — Launcher App

| Field | Value |
|---|---|
| Status | Implemented — SwiftUI skeleton |
| Owner area | App/ |
| Related research | docs/research/01-raptor-fun-findings.md |

## Purpose
Provide the macOS app shell: window, menus, toolbar, and the composition of editor/tabs/hub/settings/licensing.

## Public behaviour observed
Original is a macOS app (/Applications/MacSploit.app) with an editor, tab system, hub, settings and licence UI. Its internals were not inspected (no binary obtained).

## Clean-room design
SwiftUI, macOS 13+, Xcode 15+, Swift 5.9. RaptorApp (@main) owns an AppState @StateObject; ContentView composes TabBarView + ScriptEditorView + optional ScriptHubView, with Settings/Licensing as sheets. Menu commands: New Tab (Cmd-T), Open (Cmd-O), Save (Cmd-S). No Xcode project file is checked in yet — create one in Xcode (bundle id dev.raptor.rebuild) and add App/ files.

## Public API / types
```
RaptorApp: App
ContentView; TabBarView; ScriptEditorView; ScriptHubView; SettingsView; LicensingView
AppState: tabs, activeTabID, settings, licenceState, statusMessage
```

## Data flow
Launch -> AppState init (Welcome tab) -> ContentView renders -> toolbar/sheets mutate AppState -> views re-render.

## Files
App/RaptorApp.swift; App/AppState.swift; App/Views/ContentView.swift; App/Views/*.swift

## Config
macOS 13+ deployment target; min window 900x600.

## Edge cases
No tab open -> placeholder text; closing the last tab creates a new one. File-picker open is a placeholder (loads a sample) until the system picker is wired.

## Security notes
App never touches a Roblox process. No entitlements for injection. Sandbox-friendly by design (module 12).

## Tests
Manual UI walkthrough in Xcode; planned: snapshot tests, Swift unit tests for AppState tab operations.

## Open questions
Xcode project file — check in a generated one or keep creation manual? App icon / branding? Minimum macOS version — 13 vs 14?
