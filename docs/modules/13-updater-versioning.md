# Module 13 — Updater + Versioning

| Field | Value |
|---|---|
| Status | Implemented — check only, no download |
| Owner area | App/Services/UpdaterService.swift, App/Services/ApiClient.swift |
| Related research | docs/research/02-install-sh-analysis.md |

## Purpose
Check whether a newer version exists, without ever downloading or installing a binary.

## Public behaviour observed
Original pins Roblox via version.json (channel/clientVersionUpload) and writes ~/Downloads/ms-version.json; the app's own update path was not observed.

## Clean-room design
UpdaterService(currentVersion='0.1.0', apiClient): checkForUpdates() awaits ApiClient.fetchVersion() (stub -> throws -> result reports latestVersion=nil, updateAvailable=false). On a real version, updateAvailable = latest != current. downloadURL is always nil — no download URL is ever followed. The installer writes ~/Downloads/raptor-version.json (launcher placeholder metadata).

## Public API / types
```
UpdateCheckResult(currentVersion, latestVersion?, updateAvailable, downloadURL?)
UpdaterService.checkForUpdates() async -> UpdateCheckResult
ApiClient.fetchVersion() async throws -> VersionInfo
```

## Data flow
Check -> fetchVersion -> compare -> result. Failure -> safe default (no update reported, no download attempted).

## Files
App/Services/UpdaterService.swift; App/Services/ApiClient.swift; installer/install.sh (writes raptor-version.json)

## Config
currentVersion 0.1.0; no live endpoint configured.

## Edge cases
Network failure / stub -> updateAvailable=false, latest=nil. Version string mismatch -> update reported, download still nil (user must obtain a new build from source).

## Security notes
An updater that downloads+executes binaries is a prime malware channel (see research 04). This updater has no download path at all — that is deliberate, not missing.

## Tests
Planned Swift tests: stub -> no update; mocked version newer -> updateAvailable=true, downloadURL=nil. Python side covered by api-client tests.

## Open questions
Should update checks be opt-in? Where would a signed release be hosted if this ever ships?
