# Module 07 — Tab System (TABSYS)

| Field | Value |
|---|---|
| Status | Implemented — skeleton |
| Owner area | App/Views/TabBarView.swift, App/AppState.swift |
| Related research | docs/research/01-raptor-fun-findings.md |

## Purpose
Implement the Powerful Tab System: multiple open scripts, selection, new/close, dirty indicators.

## Public behaviour observed
Original advertises a 'Powerful Tab System (TABSYS)'. Tab behaviour details (reorder, pin, restore) were not observed.

## Clean-room design
AppState holds [ScriptTab] + activeTabID; TabBarView renders a horizontal scrollable strip; active tab highlighted; dirty tab shows a dot; close button per tab; '+' creates Untitled N.lua. openTab(for:) reuses an existing tab with the same title instead of duplicating.

## Public API / types
```
AppState.tabs: [ScriptTab]; activeTabID: UUID?
AppState.newTab(); closeTab(_:); openTab(for:); updateActiveTabContent(_:)
ScriptTab.displayTitle
```

## Data flow
New -> append tab, set active. Select -> set activeTabID. Close -> remove; active falls back to last tab; empty -> new tab. Open file -> reuse or append.

## Files
App/Views/TabBarView.swift; App/AppState.swift; App/Models/ScriptTab.swift

## Config
None.

## Edge cases
Closing the active tab -> last tab becomes active. Closing the only tab -> a fresh Untitled tab is created (never zero tabs). Duplicate titles reuse the first match.

## Security notes
Tabs hold only local text. No content is sent anywhere.

## Tests
Planned Swift tests: new/close/select/reuse semantics, dirty-dot display title. Manual: tab strip walkthrough.

## Open questions
Tab reorder (drag)? Pinned tabs? Session restore across launches? Tab overflow menu?
