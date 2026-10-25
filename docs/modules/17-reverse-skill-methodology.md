# Module 17 — Reverse-Skill Methodology

| Field | Value |
|---|---|
| Status | Documented |
| Owner area | docs/research/03-reverse-skill-methodology.md |
| Related research | docs/research/03-reverse-skill-methodology.md |

## Purpose
Record how the reverse-skill router pack was applied to this project, and its limits.

## Public behaviour observed
reverse-skill (zhaoxuya520/reverse-skill, MIT, 43,252 stars, 880 files, 44 rules R0-R45) is a methodology router, not a decompiler. Relevant rules: R31 macos-reverse, R32 thick-client, R21 protocol-reverse, R20 docs-generator.

## Clean-room design
Applied as: R0 authorised scope + evidence chain (public site + public install script only); R31 lens for the macOS installer/app analysis; R32 for the thick-client surface (local files, UI); R21 for the version/licence protocol shape; R20 for this 18-module documentation set. No binary was obtained, so no decompilation, Frida, or lldb work was performed — and none was needed for a shell/installer/protocol rebuild.

## Public API / types
```
(methodology — no code API)
```

## Data flow
Scope (R0) -> observe public artefacts -> classify (R31/R32/R21) -> document (R20) -> clean-room rebuild -> verify (check.sh, pytest).

## Files
docs/research/03-reverse-skill-methodology.md; docs/modules/17-reverse-skill-methodology.md

## Config
None.

## Edge cases
Reverse-skill does not verify vendor claims and does not supply code — claims remain claims. Its tooling (Frida/lldb/injection) was not applied to a live Roblox process.

## Security notes
Methodology use respects authorised scope: no account, no payment, no binary, no execution, no credentials.

## Tests
Docs cross-check: every factual claim in modules 01-16 traces to research 01/02/04 or is labelled a vendor claim.

## Open questions
If a binary is ever lawfully obtained for analysis, which R31 tools (Hopper/Ghidra/otool) would be used, and under what scope? Not planned.
