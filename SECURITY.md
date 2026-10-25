# Security Policy

## Scope

This is a clean-room educational rebuild. It must never:

- download, include, execute, or link any MacSploit binary, dylib, zip, RobloxPlayer.zip, or proprietary code;
- perform dylib injection, `insert_dylib` usage, code-signature stripping, HWID spoofing, server desync, or anti-cheat bypass;
- execute Luau (or any script) inside Roblox, or against any Roblox process;
- send a licence key, HWID, or credential in a URL query string — keys are accepted only via environment variable or stdin, and are sent only via POST with an `Authorization` header where an endpoint exists (all such calls are stubs in this repo);
- fetch anything over plain HTTP — HTTPS only, with a checksum field for any future download (no download is implemented).

## Trust warning

Treat the original MacSploit as **likely unsafe — suspicious, unverified. DO NOT trust or run on a main machine.** Verdict merged 2026-10-25 (see `docs/research/04-malware-trust-check.md` for the full evidence table). Medium-high confidence it should not be trusted; low confidence it is a confirmed stealer/keylogger — no confirmed evidence was found that official MacSploit steals accounts/cookies/crypto, and no published VirusTotal file verdict or sandbox report for `macsploit.dylib`/`ms-app.zip` was found. Absence of reports is NOT proof of safety.

Confirmed red flags: raptor.fun blacklisted Malware/Malicious by 8 vendors (Fortinet, Sophos, VIPRE, Lionic, CyRadar, Chong Lua Dao, alphaMountain.ai, ADMINUSLabs), BitDefender Warned, ESET Suspicious, 10/28 sources warning, Gridinsoft 1/100 (down from 28/100 on 2026-04-08) — source: gridinsoft.com/online-virus-scanner/url/raptor-fun. Domain registered 2026-07-18 via NameCheap, owner withheld, now crawls as 'Abyss' not MacSploit, IP changed. raptor.fun (paid $3/mo, Nexus42) vs macsploit.net (free keyless v3.2.7, 'nobody sells MacSploit') directly contradict — at least one is an impersonator/fork. Installer v4.1: unsigned jq/hwid binaries with no hash, hwid binary executed then deleted, secrets in GET `?key=&hwid=`, Roblox over plain HTTP, deletes /Applications/Roblox.app with no backup, strips codesign + insert_dylib + ad-hoc resign, unsigned ms-app.zip/scripts.zip. No persistence/Keychain/cookie harvesting in the script itself, but payloads were NOT analysed. Parallel threat: fake Xeno Executor installers in 2026 push Java RAT/stealer Powercat (BleepingComputer/Bitdefender Aug 2026) — proves the lure pattern, not that MacSploit does this.

If you already ran the original installer: treat the machine as potentially compromised — rotate Roblox/Discord credentials from a clean device, revoke sessions, check for unknown persistence, and consider a clean OS reinstall.

## Reporting a vulnerability

Open an issue in this repository with the title prefix `[SECURITY]` and a minimal reproduction. Do not include keys, HWIDs, or credentials. Do not attach binaries.

## Safe-rebuild mitigations (summary)

| Original risk | Mitigation in this rebuild |
|---|---|
| `curl\|bash`, no verification | Installer is a reviewed local script; `--dry-run`, `--help`, no pipe-to-shell |
| No checksums, HTTP fetch | HTTPS only; checksum field present, verified before use (no binary download implemented) |
| Destructive deletes, no backup | `backup_app` timestamps a backup; explicit confirmation before any delete |
| Secrets in GET query | POST + header / stdin only; stubs return `.notImplemented` for live activation |
| HWID exfiltration | HWID is computed locally for display only in the stub; never uploaded |
| Injection / codesign stripping | `InjectionBridge` is an interface + stub returning `.notImplemented` |
