# Module 16 — Security + Threat Model

| Field | Value |
|---|---|
| Status | Documented — mitigations enforced in code |
| Owner area | SECURITY.md, docs/research/04-malware-trust-check.md |
| Related research | docs/research/02-install-sh-analysis.md, 04-malware-trust-check.md |

## Purpose
Threat-model the original product and this rebuild, classify the malware indicators, and record the mitigations the rebuild enforces.

## Public behaviour observed
See research 02 (installer) and research 04 (reputation + verdict).

## Clean-room design
Threat model in three parts: (a) original delivery chain, (b) this rebuild's attack surface, (c) residual risks. See Security notes below and research 04 sections 2 and 7.

## Public API / types
```
(documentation module — no code API; controls live in installer/, ApiClient, InjectionBridge, ScriptStore)
```

## Data flow
Threat -> control -> verification: e.g. curl|bash -> local reviewed script -> check.sh; GET secrets -> POST+header stub -> pytest; injection -> stub -> Swift tests (planned).

## Files
SECURITY.md; docs/research/04-malware-trust-check.md; docs/research/02-install-sh-analysis.md; installer/install.sh; App/Services/InjectionBridge.swift

## Config
None.

## Edge cases
Reputation data changes over time — re-check Gridinsoft/VirusTotal before any verdict change; see research 04 section 8 pending-findings checklist.

## Security notes
## Malware-indicator section (merged verdict, 2026-10-25)
Verdict: Likely unsafe — Suspicious, unverified. Medium-high confidence DO NOT trust/run on a main machine. Low confidence it is a confirmed stealer/keylogger — no confirmed evidence official MacSploit steals accounts/cookies/crypto/miner/RAT, and no published VirusTotal file verdict or sandbox report for macsploit.dylib/ms-app.zip was found. Absence of reports is NOT proof of safety.
Confirmed indicators: raptor.fun blacklisted Malware/Malicious by 8 vendors (Fortinet, Sophos, VIPRE, Lionic, CyRadar, Chong Lua Dao, alphaMountain.ai, ADMINUSLabs); BitDefender Warned; ESET Suspicious; 10/28 sources warning; Gridinsoft 1/100 (was 28/100 on 2026-04-08). Source: gridinsoft.com/online-virus-scanner/url/raptor-fun. Domain registered 2026-07-18 via NameCheap, owner withheld, now crawls as 'Abyss' not MacSploit, IP changed — domain drift. raptor.fun (paid $3/mo, Nexus42) vs macsploit.net (free keyless v3.2.7, 'nobody sells MacSploit') directly contradict — at least one is impersonator/fork, neither verifiable. Parallel threat: fake Xeno Executor installers (2026) push Java RAT/stealer Powercat (browser cookies, Discord/Roblox tokens, crypto, keylogging, screenshots, webcam, persistence) — BleepingComputer/Bitdefender Aug 2026. Proves the lure pattern, not that MacSploit does this. install.sh v4.1: unsigned jq/hwid binaries, no hash; hwid binary executed then deleted (hinders forensics); secrets in GET ?key=&hwid=; Roblox over plain HTTP; deletes /Applications/Roblox.app, no backup; strips codesign + insert_dylib + ad-hoc resign; unsigned ms-app.zip/scripts.zip. No persistence/Keychain/cookie harvesting in the script itself, but payloads were NOT analysed.
Hacktool vs malware: injection/signature-stripping/HWID exfiltration prove a hacktool delivered unsafely; they do not by themselves prove credential theft. The delivery chain still grants arbitrary code execution to the vendor (or a MITM/compromise), so it is untrusted either way.
Safe-rebuild mitigations enforced: no curl|bash (local reviewed installer, --dry-run/--help); no binary downloaded at all, SHA-256 checksum field is a placeholder for any future HTTPS download; no opaque hwid binary (device id computed locally in plain code, never uploaded); secrets via POST + Authorization header, key from env/stdin only, live activation is a stub; HTTPS only, no Roblox download; no dylib, no insert_dylib, no signature stripping — InjectionBridge stub (.notImplemented); timestamped backup + explicit confirmation before any replace; scripts listed/previewed only, nothing auto-executes, nothing runs against Roblox; launcher is a placeholder, real UI built from source in Xcode; sandboxed launcher model (module 12).
What NOT to do: do not run the original installer on a main machine; do not download/execute macsploit.dylib, ms-app.zip, macsploit.zip, scripts.zip, or the hwid/jq binaries; do not enter Roblox/Discord/payment credentials into the installer/app; do not trust free mirrors/key generators. If already run: rotate credentials from a clean device, revoke sessions, check persistence, consider a clean OS reinstall.

## Tests
scripts/check.sh (bash -n, py_compile, tree); pytest mocked suite; planned grep check that no eval/insert_dylib/codesign-strip string appears in code (except in docs describing the original).

## Open questions
Re-check reputation before any verdict change (research 04 section 8). Should check.sh add the grep guard for forbidden strings in code?
