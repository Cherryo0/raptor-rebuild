# Research 01 — raptor.fun Findings

Checked: 2026-10-25. Sources: public pages at raptor.fun (home, /payments/products/monthly, lifetime page), public install script. No binary downloaded or executed; no account created; no payment made.

## Product

- **Product:** MacSploit — a paid, macOS-only Roblox script executor.
- **Developer:** Nexus42 (as presented on the site).
- **Site:** https://www.raptor.fun/
- **Pricing (verified):** Monthly $3.00/mo at `/payments/products/monthly`. Lifetime page exists; price unconfirmed (~$9.99 cited only by third parties — do not rely on it).
- **Platform:** macOS only (Apple Silicon + Intel via Rosetta, per the installer).

## Features claimed on the site

| Feature | Claim (as presented) |
|---|---|
| Script Editor V1 | Built-in editor |
| Powerful Tab System (TABSYS) | Multi-tab script editing |
| Auto Execute | Scripts in `Documents/Macsploit/Automatic Execution`, `automate()` at top |
| Unlimited FPS | FPS unlock |
| Sandbox System | Sandboxed execution |
| Error Protection | Script error handling |
| HWID Spoofer | HWID spoofing |
| Server Desync | Desync feature |
| Auto Inject | Automatic attach |
| Allow Server Teleports / Bypass Place Restrictions | Teleport / place bypass |
| Script Dumper (SPE) | Dumps to `Documents/Macsploit/Dumped` |
| Script Compatibility | Broad script support |
| Presence Settings (Discord) | Discord Rich Presence |
| Account System (cookie switch) | Multiple-account cookie switching |
| Multiple Roblox | Multiple Roblox windows / ports |

## Contradiction — two "MacSploits"

- raptor.fun sells MacSploit for $3/mo (Nexus42).
- macsploit.net distributes a free, keyless v3.2.7 and claims "nobody sells MacSploit".
- These directly contradict. At least one is an impersonator or a fork; neither is independently verifiable from public sources alone. See `04-malware-trust-check.md`.

## What was NOT verified

- No live purchase, activation, or execution was performed.
- No binary, dylib, or zip was downloaded or run.
- Feature claims above are the vendor's claims, not independently tested facts.
- Lifetime price, refund policy, and support responsiveness are unconfirmed.
