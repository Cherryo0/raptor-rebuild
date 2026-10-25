# Research 03 — reverse-skill Methodology

- **Repo:** https://github.com/zhaoxuya520/reverse-skill
- **Licence:** MIT · **Stars:** 43,252 (at time of checking) · **Files:** 880
- **Nature:** An AI skill router pack — 44 rules (R0–R45) for reverse engineering. Methodology only; it is not a decompiler and no code from it is vendored here.

## Routing applied

| Rule | Skill | How it was applied here |
|---|---|---|
| R31 | macos-reverse | macOS app analysis: `codesign`, `otool`, Mach-O structure, Hopper/Ghidra/IDA, Frida/lldb — used as the lens for the installer + app-shell analysis |
| R32 | thick-client | Thick-client (desktop app) analysis: local files, config, UI surface |
| R21 | protocol-reverse | Protocol analysis: version.json shape, whitelist/activation request shape (GET vs POST) |
| R20 | docs-generator | Documentation generation: the 18 module docs in `docs/modules/` follow this pattern |
| R0 | (router / scope) | Authorised scope + evidence chain: only public site + public install script; no binary, no execution, no credentials |

## Rules honoured

- **Authorised scope only:** public website and public install script. No account, no payment, no binary download, no execution.
- **Evidence chain:** every factual claim carries a source (URL + date). Unverified claims are labelled as vendor claims.
- **No copying:** the rebuild is clean-room — behaviour described from observation, implementation written fresh.
- **Safety:** the methodology's tooling (Frida, lldb, injection) was *not* applied to a live Roblox process; the injection bridge is a stub.

## What reverse-skill did NOT do

- It did not decompile anything (no binary was obtained).
- It did not provide the installer, the dylib, or any proprietary code.
- It did not verify the vendor's feature claims — those remain claims.
