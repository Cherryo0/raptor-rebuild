# Module 01 — Product Overview

| Field | Value |
|---|---|
| Status | Documented — rebuild is a clean-room shell only |
| Owner area | Product |
| Related research | docs/research/01-raptor-fun-findings.md, 04-malware-trust-check.md |

## Purpose
Define what the product is, what this rebuild covers, and what it deliberately does not cover, so every other module has a single scope reference.

## Public behaviour observed
raptor.fun sells MacSploit, a paid macOS-only Roblox script executor by Nexus42, $3.00/mo verified (lifetime price unconfirmed, ~$9.99 third-party only). Claimed: Script Editor V1, TABSYS, Auto Execute, Unlimited FPS, Sandbox, Error Protection, HWID Spoofer, Server Desync, Auto Inject, teleports/bypass, Script Dumper, Discord presence, account/cookie switching, multiple Roblox instances.

## Clean-room design
This rebuild covers only the app shell, installer, licensing client, editor UI and architecture — all written fresh from observed behaviour. Injection, spoofing, desync, bypass and Luau execution against Roblox are out of scope and represented only by stubs returning .notImplemented. No original binary, asset, or code is included.

## Public API / types
```
RaptorApp (SwiftUI @main)
AppState: ObservableObject — tabs, activeTabID, settings, licenceState
LicenceState: unknown | checking | active(expires:) | inactive(reason:) | notImplemented
```

## Data flow
1. User opens the app — AppState initialises with a Welcome tab.
2. Tabs/editor/hub/settings read and mutate AppState only.
3. Any live Roblox action routes to InjectionBridgeStub — .notImplemented — UI shows the reason.

## Files
README.md; ARCHITECTURE.md; App/RaptorApp.swift; App/AppState.swift; docs/modules/01-product-overview.md

## Config
None. Bundle id for the Xcode project: dev.raptor.rebuild (planned).

## Edge cases
Vendor claims are unverified — treat as claims, not facts. Two contradictory MacSploit distributions exist (raptor.fun paid vs macsploit.net free); see module 16 / research 04.

## Security notes
Trust verdict: likely unsafe — suspicious, unverified; do not run the original on a main machine. This rebuild contains no original code or binary. See docs/research/04-malware-trust-check.md.

## Tests
Manual: README feature table matches observed claims; no code path claims a live Roblox capability. Automated: scripts/check.sh tree check.

## Open questions
Lifetime price (unconfirmed)? Refund/support policy? Which distribution, if either, is genuine?
