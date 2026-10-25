# Research 02 — install.sh Analysis (v4.1)

- **URL:** https://api.macsploit.dev/main/install.sh
- **Version:** v4.1 (as served at time of analysis, 2026-10-25)
- **SHA256:** `ebb3abbfe9b080c3a070d61c19600c74bda6c7b48d29f11ad91344a52cfdfd3e`
- **Length:** 181 lines
- **Method:** Static reading only. The script was fetched as text and read; it was **not** executed, and no binary it references was downloaded.

## Step table

| # | Step | What it does |
|---|---|---|
| 1 | Architecture check | `uname -m`; arm64 vs Intel branch |
| 2 | Rosetta install | On arm64, installs Rosetta if missing (`softwareupdate --install-rosetta`) |
| 3 | Download helpers | Downloads `jq` and a `hwid` binary (unsigned, no checksum) |
| 4 | HWID computation | Executes the downloaded `hwid` binary, then deletes it (hinders forensics) |
| 5 | HWID whitelist check | GET `api/whitelist?hwid=<hwid>` |
| 6 | Sellix activation | GET `api/sellix?key=<key>&hwid=<hwid>`; must return exactly `Key Activation Complete!` |
| 7 | Roblox version | Fetches `api.macsploit.dev/main/version.json`, reads `channel` / `clientVersionUpload` (preview vs stable, arm64 vs Intel) |
| 8 | Roblox download | Downloads `RobloxPlayer.zip` from `setup.rbxcdn.com` over **plain HTTP** |
| 9 | Destructive replace | Deletes `/Applications/Roblox.app` (no backup) and unzips the new player |
| 10 | macsploit.zip | Downloads `macsploit.zip` (supplies `insert_dylib`) |
| 11 | macsploit.dylib | Downloads `macsploit.dylib` (4 endpoints by preview/arm64 combination) |
| 12 | Codesign strip | `codesign --remove-signature` on RobloxPlayer |
| 13 | Injection | `insert_dylib @rpath/macsploit.dylib` into RobloxPlayer |
| 14 | Ad-hoc resign | `codesign -s "-"` (ad-hoc signature) |
| 15 | App install | Downloads `ms-app.zip` → `/Applications/MacSploit.app` |
| 16 | First-install scripts | Downloads `scripts.zip` → `~/Documents/MacsploitUI` |
| 17 | Version file | Writes `~/Downloads/ms-version.json` |

## Endpoints table

| Endpoint | Purpose | Transport |
|---|---|---|
| `https://api.macsploit.dev/main/install.sh` | Installer itself | HTTPS (but delivered via `curl \| bash`) |
| `api.macsploit.dev/main/version.json` | Roblox channel/version pin | HTTPS |
| `api.macsploit.dev/api/whitelist?hwid=` | HWID whitelist | HTTPS, secret in GET |
| `api.macsploit.dev/api/sellix?key=&hwid=` | Sellix activation | HTTPS, secrets in GET |
| `setup.rbxcdn.com/.../RobloxPlayer.zip` | Roblox player | **Plain HTTP** |
| `api.macsploit.dev/.../macsploit.zip` | insert_dylib bundle | HTTPS |
| `api.macsploit.dev/.../macsploit.dylib` (×4) | Injected library | HTTPS |
| `api.macsploit.dev/.../ms-app.zip` | MacSploit.app | HTTPS |
| `api.macsploit.dev/.../scripts.zip` | First-install UI scripts | HTTPS |

## Security findings

| # | Finding | Severity |
|---|---|---|
| 1 | `curl \| bash` — no verification, no checksum, no signature on the installer itself | High |
| 2 | Unsigned `jq` / `hwid` binaries downloaded and executed with no hash check | High |
| 3 | `hwid` binary executed then deleted — hinders forensic analysis | High |
| 4 | Licence key + HWID in GET query strings (`?key=&hwid=`) — logged by proxies/servers | High |
| 5 | RobloxPlayer.zip fetched over plain HTTP — MITM can substitute the binary | High |
| 6 | Deletes `/Applications/Roblox.app` with no backup | Medium |
| 7 | `codesign --remove-signature` + `insert_dylib` + ad-hoc resign — signature stripping + injection | High |
| 8 | No quickfix / normal mode branches exist in the script despite the site's wording — only one linear path | Info |
| 9 | No persistence, Keychain access, or cookie harvesting in the script itself — but the downloaded payloads were **not** analysed, so this proves nothing about them | Info |

## Conclusion

The installer is a high-risk delivery chain: it asks the user to pipe an unverified script into a shell, then downloads and executes unsigned binaries, exfiltrates a hardware ID, transmits a paid licence key in a URL, replaces the user's Roblox install over HTTP, and strips + re-signs its code signature to inject a library. Any one of these would be a red flag; together they are the basis for the "likely unsafe — suspicious, unverified" verdict in `04-malware-trust-check.md`. The safe rewrite in `installer/install.sh` removes every item in this table.
