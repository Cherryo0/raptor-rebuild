# Module 15 — Presence — Discord

| Field | Value |
|---|---|
| Status | Design only — local toggle, no Discord calls |
| Owner area | App/AppState.swift (toggle only) |
| Related research | docs/research/01-raptor-fun-findings.md |

## Purpose
Represent the original's Discord Presence settings as a local preference, with no Discord integration.

## Public behaviour observed
Original claims Presence Settings (Discord). No Discord RPC traffic or settings UI was observed.

## Clean-room design
AppSettings.discordPresenceEnabled is a Bool toggle in SettingsView with the label stating no Discord calls are made. No Discord SDK, no Rich Presence RPC, no network call to Discord exists in the project. If presence were ever added, it would need an explicit, opt-in design using Discord's official SDK with user consent — not this module.

## Public API / types
```
AppSettings.discordPresenceEnabled: Bool
```

## Data flow
Toggle -> stored preference -> nothing else happens.

## Files
App/Views/SettingsView.swift; App/AppState.swift

## Config
Default false.

## Edge cases
Toggle on -> still no Discord traffic (must be clear in UI copy).

## Security notes
Discord RPC can leak activity/identity. Keeping it a no-op toggle avoids any presence leak by construction.

## Tests
Manual: toggle on, confirm no network/Discord activity (no Discord code exists to call).

## Open questions
Should Discord presence be dropped entirely to avoid implying a feature? Only add via official SDK + opt-in if ever requested.
