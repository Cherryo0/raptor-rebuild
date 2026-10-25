# Module 06 — Script Editor

| Field | Value |
|---|---|
| Status | Implemented — skeleton |
| Owner area | App/Views/ScriptEditorView.swift, App/Models/ |
| Related research | docs/research/01-raptor-fun-findings.md |

## Purpose
Provide Script Editor V1-style editing: text editing, line/character counts, save, and an honestly-inert Execute button.

## Public behaviour observed
Original claims Script Editor V1 with a tab system; editor internals (syntax highlighting, autocomplete) were not observed directly.

## Clean-room design
ScriptEditorView binds a TextEditor to a draft string synced with the active ScriptTab; edits call AppState.updateActiveTabContent (sets isDirty). Save goes through ScriptStore with atomic writes. Execute sets a message with InjectionBridgeStub.notImplementedReason — it never runs anything. Monospaced font; line/character counts in the header.

## Public API / types
```
ScriptTab(id, title, content, isDirty, fileURL); displayTitle; lineCount; characterCount
ScriptFile(id, name, content, url, modifiedAt); isAutoExecuteCandidate
ScriptStore.save(_) throws; .listScripts() throws -> [ScriptFile]
```

## Data flow
1. Tab selected -> draft = tab.content. 2. Edit -> updateActiveTabContent -> isDirty. 3. Save -> ScriptStore.save (atomic) -> isDirty=false, status message.

## Files
App/Views/ScriptEditorView.swift; App/Models/ScriptTab.swift; App/Models/ScriptFile.swift; App/Services/ScriptStore.swift

## Config
Scripts dir ~/Documents/RaptorUI; samples in App/Resources/*.lua.

## Edge cases
Unsaved (dirty) tab closed -> content lost (no prompt yet — open question). Non-UTF-8 file -> read error surfaced. Very large files -> TextEditor performance (untested).

## Security notes
Editor never executes content. Samples are labelled harmless editor samples. No eval, no shell-out.

## Tests
Planned Swift tests: line/char counts, dirty flag transitions, atomic save round-trip. Manual: edit/save/reopen.

## Open questions
Syntax highlighting for Luau (TextKit vs third-party)? Dirty-tab close prompt? Undo/redo beyond TextEditor defaults?
