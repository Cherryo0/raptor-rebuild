# Module 08 — Script Engine — Luau

| Field | Value |
|---|---|
| Status | Design only — NO execution implemented |
| Owner area | App/Resources/, docs (design only) |
| Related research | docs/research/01-raptor-fun-findings.md |

## Purpose
Define how Luau scripts are handled in this rebuild: as editable text only. There is no execution engine, by design.

## Public behaviour observed
Original executes Luau scripts inside Roblox (Script Compatibility claimed). The engine itself was not observed or obtained.

## Clean-room design
No Luau interpreter, compiler, or runtime is included. Scripts are plain text in the editor; bundled samples (hello.lua, loop-demo.lua, table-demo.lua) are labelled 'HARMLESS EDITOR SAMPLE ONLY' and are never executed against Roblox or any process. If a future local (non-Roblox) Luau sandbox is ever wanted, it would be a separate, explicitly-scoped decision — not this module.

## Public API / types
```
(none — intentionally) — any future local interpreter would expose: parse(script:) -> Result; runLocally(script:) only inside an explicit sandbox, never against Roblox.
```

## Data flow
User writes/loads text -> editor stores text -> save writes text to disk. There is no step that evaluates the text.

## Files
App/Resources/hello.lua; App/Resources/loop-demo.lua; App/Resources/table-demo.lua; App/Resources/README.md

## Config
None.

## Edge cases
A user pasting a malicious-looking script: it is inert text here. A user expecting execution: the Execute button explains it is not implemented.

## Security notes
This is the core safety boundary. Adding an executor would violate Roblox ToS and reintroduce the malware-risk pattern; it requires a fresh, explicit decision and is not planned.

## Tests
Grep check: no eval/exec/system() of script content anywhere in the repo (scripts/check.sh could add this). Samples contain only print/loops over literals.

## Open questions
Should a local, sandboxed Luau playground (no Roblox) ever be added? Out of scope unless the user explicitly asks.
