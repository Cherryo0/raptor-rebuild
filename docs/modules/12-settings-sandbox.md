# Module 12 — Settings + Sandbox

| Field | Value |
|---|---|
| Status | Implemented — preferences only |
| Owner area | App/Views/SettingsView.swift, App/AppState.swift |
| Related research | docs/research/01-raptor-fun-findings.md |

## Purpose
Store user preferences (sandbox, FPS, error protection, presence) as local configuration with no effect on Roblox.

## Public behaviour observed
Original claims Sandbox System, Unlimited FPS, Error Protection, Presence Settings (Discord). Their implementations were not observed.

## Clean-room design
AppSettings (Codable, Equatable): autoExecuteEnabled, unlimitedFPS, sandboxEnabled, errorProtection, discordPresenceEnabled, allowServerTeleports, autoInjectEnabled. SettingsView is a grouped Form; injection-related toggles (Auto Inject, teleports/bypass) are disabled with an explanatory note. No Discord RPC call is made; discordPresenceEnabled is a local toggle only. Sandbox here means the app model (no process injection, local files only), not a code-execution sandbox — the distinction is stated because the original's 'Sandbox System' is unverified.

## Public API / types
```
AppSettings: Codable, Equatable — fields listed in Clean-room design
SettingsView; AppState.settings
```

## Data flow
Toggle -> AppState.settings updated -> (planned) persisted to UserDefaults -> read back on launch. No other effect.

## Files
App/Views/SettingsView.swift; App/AppState.swift

## Config
Defaults: sandboxEnabled=true, errorProtection=true, others false. Persistence via UserDefaults is planned, not yet wired.

## Edge cases
Toggling a disabled option is impossible by design. Settings are per-machine (no sync).

## Security notes
No toggle can enable injection or execution — the dangerous options are disabled, not merely off. No network call is triggered by any setting.

## Tests
Planned Swift tests: AppSettings Codable round-trip; disabled toggles remain off. Manual: settings sheet walkthrough.

## Open questions
UserDefaults vs a settings file? Should the disabled injection toggles be removed rather than shown disabled?
