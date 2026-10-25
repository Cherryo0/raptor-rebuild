# Module 14 — Multi-Instance + Accounts

| Field | Value |
|---|---|
| Status | Design only — data model, no account switching |
| Owner area | App/AppState.swift (data model only) |
| Related research | docs/research/01-raptor-fun-findings.md |

## Purpose
Model multiple profiles/instances and the account (cookie-switch) UI state, without performing any Roblox account switching.

## Public behaviour observed
Original claims Multiple Roblox (multiple windows/ports) and an Account System (cookie switch). Neither was observed in operation.

## Clean-room design
No implementation in this skeleton beyond AppSettings/AppState structure: profiles are a future data model (id, displayName, notes) held locally. Cookie switching is explicitly not implemented — handling Roblox session cookies would be credential handling with no safe scope here. Multiple instances would mean multiple app windows/tabs, not multiple Roblox processes; no Roblox process is ever launched.

## Public API / types
```
(planned) struct Profile: Identifiable, Codable { id: UUID; displayName: String; notes: String }
AppState.profiles: [Profile] (planned — not yet in code)
```

## Data flow
Select profile -> editor context notes which profile is active -> no account action is taken. That is the whole flow.

## Files
App/AppState.swift (future extension point); docs/modules/14-multi-instance-accounts.md

## Config
None.

## Edge cases
A user expecting cookie switching will find it absent — the UI must say so, not fake it.

## Security notes
Session cookies are credentials. This rebuild never reads, stores, switches, or transmits Roblox cookies. Any future account feature needs a credential-handling design (Keychain, explicit consent) and is not planned.

## Tests
Planned: profile CRUD unit tests once the model lands. Manual: confirm no cookie file is read or written.

## Open questions
Is a local profiles/notes model even wanted, or should this module stay documentation-only?
