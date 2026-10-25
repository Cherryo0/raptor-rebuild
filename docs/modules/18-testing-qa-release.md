# Module 18 — Testing, QA + Release

| Field | Value |
|---|---|
| Status | Implemented — static checks + mocked tests |
| Owner area | scripts/, api-client/tests/ |
| Related research | docs/research/02-install-sh-analysis.md |

## Purpose
Define how this project is verified and released, given that live Roblox behaviour can never be tested here.

## Public behaviour observed
Original release process was not observed; versioning evidence is version.json + ms-version.json (installer) and the $3/mo product page.

## Clean-room design
Three layers: (1) static — scripts/check.sh runs find/tree, python3 -m py_compile, bash -n, shellcheck if present, pytest if present; (2) unit — pytest mocked suite for the API client (7 tests, no network); Swift unit tests planned for AppState/ScriptStore/LicensingService/InjectionBridge; (3) manual — Xcode UI walkthrough, installer --dry-run, quickfix --dry-run. Release: SemVer + CHANGELOG.md (Keep a Changelog); no binary is ever released by this project — releases are source only. GitHub push is done by the parent agent (not this build).

## Public API / types
```
scripts/check.sh; scripts/dev-setup.sh [--with-venv]
pytest api-client/tests/ -q
CHANGELOG.md: [Unreleased] / [0.1.0] 2026-10-25
```

## Data flow
Change -> update matching docs/modules/NN file in same PR -> ./scripts/check.sh -> pytest -> manual Xcode/installer dry-run -> CHANGELOG entry -> release tag (source only).

## Files
scripts/check.sh; scripts/dev-setup.sh; api-client/tests/test_api_client.py; CHANGELOG.md; CONTRIBUTING.md

## Config
Python 3.11+; pytest 8.0+; bash 5; macOS 13+ / Xcode 15+ for the app.

## Edge cases
No macOS/Xcode in this Linux build environment — Swift files are compile-plausible by review, not compiled here. That is a stated gap: first Xcode build must be done on a Mac and any errors fixed there.

## Security notes
Tests never hit live endpoints and never use real keys/HWIDs. No test fixture contains a credential.

## Tests
Current: py_compile passes; bash -n passes; pytest suite (run on Mac/dev machine — see verification note). Planned: Swift tests, shellcheck in CI, forbidden-string grep guard.

## Open questions
CI host (GitHub Actions macOS runner for Swift build)? Add swiftlint? Check in a generated Xcode project?
