#!/usr/bin/env bash
# Raptor Rebuild — SAFE installer (clean-room rewrite)
# Installs ONLY: a launcher placeholder + ~/Documents/RaptorUI scripts dir.
# It NEVER patches Roblox, downloads a dylib, strips a code signature,
# runs an opaque binary, or executes anything downloaded.
# Usage: ./installer/install.sh [--dry-run] [--help] [--force]
set -euo pipefail

VERSION="0.1.0"
APP_NAME="Raptor.app"
INSTALL_DIR="/Applications"
SCRIPTS_DIR="$HOME/Documents/RaptorUI"
DRY_RUN=0
FORCE=0

log() { printf '[raptor-install] %s\n' "$*"; }
dry() { if [ "$DRY_RUN" -eq 1 ]; then log "[dry-run] would run: $*"; else "$@"; fi; }

usage() {
  cat <<'USAGE'
Usage: install.sh [--dry-run] [--help] [--force]
  --dry-run   Print every action without changing anything.
  --force     Skip the confirmation prompt (still backs up first).
  --help      Show this help.
This installer only creates a launcher placeholder and ~/Documents/RaptorUI.
It never downloads a binary, patches Roblox, or strips a signature.
USAGE
}

check_arch() {
  local arch
  arch="$(uname -m)"
  log "Architecture: $arch"
  case "$arch" in
    arm64|x86_64) ;;
    *) log "Unsupported architecture: $arch"; exit 1 ;;
  esac
}

check_rosetta() {
  # Rosetta is only relevant on Apple Silicon for Intel-only tools.
  # This rebuild ships no Intel-only binary, so this is informational only.
  if [ "$(uname -m)" = "arm64" ]; then
    if /usr/bin/pgrep -q oahd; then log "Rosetta 2 is present."; else log "Rosetta 2 not detected (not required for this rebuild)."; fi
  fi
}

verify_checksum() {
  # Placeholder: any future download MUST carry a SHA-256 and be verified
  # here before use. No download is implemented in this installer.
  local file="$1" expected="$2"
  if [ -z "$expected" ]; then log "No checksum supplied for $file — refusing to use it."; return 1; fi
  local actual
  actual="$(shasum -a 256 "$file" | awk '{print $1}')"
  [ "$actual" = "$expected" ] || { log "Checksum mismatch for $file"; return 1; }
  log "Checksum OK: $file"
}

download_https() {
  # HTTPS-only download helper. Unused by the current install path;
  # kept so the verified-download shape is reviewable and testable.
  local url="$1" dest="$2" expected_sha256="${3:-}"
  case "$url" in https://*) ;; *) log "Refusing non-HTTPS URL: $url"; return 1 ;; esac
  dry curl -fsSL --proto '=https' --tlsv1.2 "$url" -o "$dest"
  if [ -n "$expected_sha256" ] && [ "$DRY_RUN" -eq 0 ]; then verify_checksum "$dest" "$expected_sha256"; fi
}

backup_app() {
  local target="$1"
  if [ -e "$target" ]; then
    local backup="${target}.backup-$(date +%Y%m%d-%H%M%S)"
    log "Backing up existing $target to $backup"
    dry mv "$target" "$backup"
  fi
}

install_launcher_only() {
  local target="$INSTALL_DIR/$APP_NAME"
  if [ -e "$target" ] && [ "$FORCE" -eq 0 ]; then
    printf 'Replace existing %s? Existing install will be backed up first. [y/N] ' "$target"
    read -r answer </dev/tty || answer="n"
    case "$answer" in y|Y) ;; *) log "Aborted by user."; exit 0 ;; esac
  fi
  backup_app "$target"
  log "Creating launcher placeholder at $target (no binary is downloaded)."
  dry mkdir -p "$target/Contents/MacOS"
  dry mkdir -p "$target/Contents/Resources"
  # Placeholder launcher: a script that explains this is a clean-room shell.
  if [ "$DRY_RUN" -eq 0 ]; then
    cat > "$target/Contents/MacOS/Raptor" <<'LAUNCHER'
#!/bin/sh
echo "Raptor clean-room rebuild launcher placeholder."
echo "Build the SwiftUI app from App/ in Xcode to run the real UI."
LAUNCHER
    chmod +x "$target/Contents/MacOS/Raptor"
  else
    log "[dry-run] would write launcher script into $target/Contents/MacOS/Raptor"
  fi
  log "Creating scripts directory: $SCRIPTS_DIR"
  dry mkdir -p "$SCRIPTS_DIR/AutoExecute" "$SCRIPTS_DIR/Dumped"
  if [ "$DRY_RUN" -eq 0 ]; then
    mkdir -p "$HOME/Downloads"
    printf '{\n  "version": "%s",\n  "installed_at": "%s",\n  "launcher": "placeholder",\n  "notes": "Clean-room rebuild. No Roblox patching, no dylib, no injection."\n}\n' "$VERSION" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$HOME/Downloads/raptor-version.json"
  fi
  log "Done. Launcher placeholder installed; scripts dir ready at $SCRIPTS_DIR."
}

main() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      --force) FORCE=1 ;;
      --help|-h) usage; exit 0 ;;
      *) log "Unknown option: $1"; usage; exit 1 ;;
    esac
    shift
  done
  log "Raptor safe installer v$VERSION (dry-run=$DRY_RUN)"
  check_arch
  check_rosetta
  install_launcher_only
}

main "$@"
