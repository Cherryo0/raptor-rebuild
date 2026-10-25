# Module 11 — Script Hub / Library

| Field | Value |
|---|---|
| Status | Implemented — skeleton |
| Owner area | App/Views/ScriptHubView.swift, App/Resources/ |
| Related research | docs/research/01-raptor-fun-findings.md |

## Purpose
Provide a searchable library of bundled harmless sample scripts that open into editor tabs.

## Public behaviour observed
Original has a script hub/library (feature claimed on the site); its catalogue and sourcing were not observed.

## Clean-room design
ScriptHubView: search field + List of HubScript(name, description, content); tapping opens the script in a tab via AppState.openTab(for:). Samples are the three bundled editor samples only. A footer states samples are editor-only and never run against Roblox. No network fetch, no community scripts, no remote catalogue.

## Public API / types
```
HubScript(id, name, description, content)
ScriptHubView.samples: [HubScript]
AppState.openTab(for: ScriptFile)
```

## Data flow
Hub shown -> query filters by name/description -> tap -> openTab (reuse if already open) -> editor shows the script.

## Files
App/Views/ScriptHubView.swift; App/Resources/*.lua; App/Resources/README.md

## Config
None (bundled samples only).

## Edge cases
Empty query -> all samples. No match -> empty list. Duplicate open -> existing tab focused.

## Security notes
No remote script fetching (a remote hub would be a code-delivery channel). Bundled samples are reviewed, labelled, and inert.

## Tests
Planned Swift tests: filter matches name/description, case-insensitive. Manual: search + open each sample.

## Open questions
Should users be able to add their own local scripts to the Hub (local only)? Remote catalogue — no, unless separately scoped with signing/review.
