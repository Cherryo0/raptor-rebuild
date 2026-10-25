# Module 02 — Installer

| Field | Value |
|---|---|
| Status | Implemented — safe rewrite |
| Owner area | installer/ |
| Related research | docs/research/02-install-sh-analysis.md, 04-malware-trust-check.md |

## Purpose
Install the launcher placeholder and the local scripts directory safely, replacing the original v4.1 installer's unsafe delivery chain.

## Public behaviour observed
Original v4.1 (181 lines, SHA256 ebb3abbf…): arch check, Rosetta, unsigned jq/hwid binaries, HWID whitelist + Sellix activation via GET (?key=&hwid=), RobloxPlayer.zip over plain HTTP, deletes /Applications/Roblox.app, insert_dylib + codesign stripping + ad-hoc resign, ms-app.zip to /Applications/MacSploit.app, scripts.zip to ~/Documents/MacsploitUI, ms-version.json. No quickfix/normal branches.

## Clean-room design
installer/install.sh: bash, set -euo pipefail, functions check_arch, check_rosetta, verify_checksum (placeholder), backup_app, download_https (HTTPS-only, unused by install path), install_launcher_only. Flags --dry-run / --help / --force. Confirmation before any replace; timestamped backup first. Creates /Applications/Raptor.app placeholder + ~/Documents/RaptorUI/{AutoExecute,Dumped} + ~/Downloads/raptor-version.json. quickfix.sh verifies and re-creates missing dirs and rewrites the version file.

## Public API / types
```
install.sh [--dry-run] [--help] [--force]
quickfix.sh [--dry-run] [--help]
check_arch(); check_rosetta(); verify_checksum(file, sha256); backup_app(target); download_https(url, dest, sha256); install_launcher_only()
```

## Data flow
1. Parse flags. 2. check_arch + check_rosetta (informational). 3. Confirm if target exists (unless --force). 4. backup_app. 5. Create placeholder app + scripts dirs. 6. Write raptor-version.json.

## Files
installer/install.sh; installer/quickfix.sh; installer/README.md

## Config
VERSION=0.1.0; APP_NAME=Raptor.app; INSTALL_DIR=/Applications; SCRIPTS_DIR=$HOME/Documents/RaptorUI.

## Edge cases
No /dev/tty (non-interactive): confirmation defaults to abort. Existing install without --force prompts; --force still backs up. Rosetta absent on arm64 is informational only — no Intel binary is shipped.

## Security notes
No curl|bash. HTTPS only. No binary download. No secrets in URLs. Backup + confirm before deletes. verify_checksum refuses use without a checksum. See research 02 for the original flaws this removes.

## Tests
bash -n installer/*.sh; ./installer/install.sh --dry-run; ./installer/install.sh --help; ./installer/quickfix.sh --dry-run; shellcheck if present (scripts/check.sh).

## Open questions
Should the placeholder eventually be a real signed .app bundle built by Xcode? Where should the version file live long-term?
