# Module 10 — Auto Execute

| Field | Value |
|---|---|
| Status | Implemented — list/preview only, never executes |
| Owner area | App/Services/ScriptStore.swift, App/AppState.swift |
| Related research | docs/research/01-raptor-fun-findings.md |

## Purpose
Mirror the original's Auto Execute folder as a list/preview feature, without ever auto-running scripts.

## Public behaviour observed
Original: scripts in Documents/Macsploit/Automatic Execution with automate() at top run automatically (on attach).

## Clean-room design
ScriptStore.autoExecuteDirectory = ~/Documents/RaptorUI/AutoExecute; listAutoExecuteScripts() returns [ScriptFile] sorted by name. AppSettings.autoExecuteEnabled is a stored toggle that only controls whether the list is shown/considered — it triggers no execution. No automate() handling, no attach hook, no execution path exists.

## Public API / types
```
ScriptStore.autoExecuteDirectory: URL
ScriptStore.listAutoExecuteScripts() throws -> [ScriptFile]
ScriptFile.isAutoExecuteCandidate: Bool
AppSettings.autoExecuteEnabled: Bool
```

## Data flow
User enables the toggle -> UI lists AutoExecute scripts -> user may open one in a tab. Nothing runs, on attach or otherwise (there is no attach).

## Files
App/Services/ScriptStore.swift; App/AppState.swift (AppSettings); installer/install.sh (creates the dir)

## Config
AutoExecute dir: ~/Documents/RaptorUI/AutoExecute. Toggle default: false.

## Edge cases
Empty folder -> empty list. Non-.lua files ignored. Missing folder -> created by ensureDirectories(). A script named automate() is treated as plain text.

## Security notes
Auto-execution is an attack surface (a dropped file runs on next attach). This rebuild removes it entirely — the toggle cannot cause execution.

## Tests
Planned Swift tests: list returns only .lua, sorted; missing dir is created. Manual: drop a sample .lua in AutoExecute, confirm it lists and does not run.

## Open questions
Should AutoExecute scripts get a distinct badge in the Hub? Should the toggle be removed to avoid implying execution?
