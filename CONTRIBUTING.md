# Contributing

## Principles

1. **Clean-room only.** Describe observed public behaviour; never copy proprietary code, binaries, or assets. Never download or run a MacSploit binary/dylib.
2. **Stub, don't fake.** Live Roblox behaviour that is out of scope must return `.notImplemented` / a clear error, never a fake success.
3. **Safety first.** HTTPS only, no secrets in URLs, no `curl | bash`, backup before replace, `--dry-run` on every installer change.
4. **Evidence chain.** Every factual claim about the original needs a source (URL + date checked) in the relevant `docs/research/` or `docs/modules/` file.

## Workflow

- Branch from `main`, one module per branch/PR.
- Update the matching `docs/modules/NN-*.md` file in the same PR as any code change.
- Run `./scripts/check.sh` before opening a PR; all checks must pass.
- Swift: Swift 5.9, macOS 13+, SwiftUI. No `TODO` in code paths — file an issue instead.
- Python: `python3 -m py_compile` + `pytest` (mocked HTTP only, no live network in tests).
- Shell: `bash -n` clean; `shellcheck` clean where available.

## What will not be accepted

Injection, dylib patching, codesign stripping, HWID spoofing, desync/bypass code, Luau execution against Roblox, credentials, keys, HWIDs, or any binary blob.
