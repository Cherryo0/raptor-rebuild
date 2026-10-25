#!/usr/bin/env bash
# Raptor Rebuild — bootstrap installer (clean-room)
#
# One-command Mac install. What it does, nothing more:
#   1. Checks you are on macOS (Darwin) with curl + git available.
#   2. Clones (or updates) the public repo https://github.com/Cherryo0/raptor-rebuild
#      into ~/raptor-rebuild (override with --dir).
#   3. Runs that repo's safe installer (installer/install.sh), which ONLY
#      creates a /Applications/Raptor.app launcher placeholder and
#      ~/Documents/RaptorUI/{AutoExecute,Dumped}, plus ~/Downloads/raptor-version.json.
#
# It NEVER patches Roblox, downloads a binary/dylib, strips a code signature,
# runs an opaque binary, asks for a licence key, or touches your Roblox install.
# Compare with the original MacSploit one-liner, which did all of that.
#
# Install it (download first, then run — do NOT pipe it into bash):
#   cd ~/ && curl -fsSL https://raw.githubusercontent.com/Cherryo0/raptor-rebuild/v1.1.0/installer/bootstrap.sh -o /tmp/raptor-bootstrap.sh && bash /tmp/raptor-bootstrap.sh
# Inspect it first with: less /tmp/raptor-bootstrap.sh
#
# Why not `curl ... | bash </dev/tty` (the original MacSploit style)? On macOS
# (zsh) the piped script runs, but bash then stays waiting for terminal input
# after it finishes, so the terminal looks stuck. Download-then-run exits
# cleanly. If you ran the pipe form and look stuck, press Ctrl-C once — the
# install itself already finished.
#
# Options: --dry-run --force --help --dir <path> --ref <branch-or-tag>
# Env overrides (forks / testing): RAPTOR_REPO_URL, RAPTOR_INSTALL_DIR,
# RAPTOR_ALLOW_NON_DARWIN=1 (testing on Linux only — prints a warning).
#
# Compatibility: written for macOS /bin/bash 3.2 — no arrays, no associative
# arrays, no mapfile, no [[ ]], no process substitution. (An empty-array
# expansion under `set -u` broke v1 of this script on real Macs; see
# run_installer().) Tested with bash -n + end-to-end dry-run/real runs.
set -euo pipefail

REPO_URL="${RAPTOR_REPO_URL:-https://github.com/Cherryo0/raptor-rebuild.git}"
RAW_BASE="https://raw.githubusercontent.com/Cherryo0/raptor-rebuild/main"
INSTALL_DIR="${RAPTOR_INSTALL_DIR:-$HOME/raptor-rebuild}"
REF="${RAPTOR_REF:-main}"
DRY_RUN=0
FORCE=0

log() { printf '[raptor-bootstrap] %s\n' "$*"; }
dry() { if [ "$DRY_RUN" -eq 1 ]; then log "[dry-run] would run: $*"; else "$@"; fi; }

usage() {
  cat <<'USAGE'
Usage: bootstrap.sh [--dry-run] [--force] [--help] [--dir <path>] [--ref <branch-or-tag>]
  --dry-run   Print every action without changing anything.
  --force     Skip confirmation prompts (the installer still backs up first).
  --dir       Where to clone the repo (default: ~/raptor-rebuild).
  --ref       Branch or tag to check out (default: main).
  --help      Show this help.
What this does: clone the public raptor-rebuild repo, then run its safe
installer (launcher placeholder + ~/Documents/RaptorUI only). No binaries,
no Roblox patching, no licence key, no dylib.
USAGE
}

check_os() {
  if [ "$(uname -s)" != "Darwin" ]; then
    if [ "${RAPTOR_ALLOW_NON_DARWIN:-0}" = "1" ]; then
      log "WARNING: not macOS (testing override RAPTOR_ALLOW_NON_DARWIN=1) — continuing anyway."
    else
      log "This installer is for macOS only (detected: $(uname -s)). Aborting."
      exit 1
    fi
  else
    log "macOS detected: $(sw_vers -productVersion 2>/dev/null || echo unknown)."
  fi
}

check_tools() {
  for tool in curl git; do
    command -v "$tool" >/dev/null 2>&1 || { log "Missing required tool: $tool (macOS ships both — check your PATH)."; exit 1; }
  done
  log "Found curl + git."
}

fetch_repo() {
  if [ -d "$INSTALL_DIR/.git" ]; then
    log "Repo already present at $INSTALL_DIR — updating to $REF."
    dry git -C "$INSTALL_DIR" fetch --quiet origin
    dry git -C "$INSTALL_DIR" checkout --quiet "$REF"
    dry git -C "$INSTALL_DIR" pull --ff-only --quiet origin "$REF"
  elif [ -e "$INSTALL_DIR" ]; then
    log "$INSTALL_DIR exists but is not a git repo. Remove it or pick another --dir. Aborting."
    exit 1
  else
    log "Cloning $REPO_URL ($REF) into $INSTALL_DIR ..."
    dry git clone --quiet --branch "$REF" "$REPO_URL" "$INSTALL_DIR"
  fi
  log "Repo ready at $INSTALL_DIR."
}

run_installer() {
  # NOTE: no arrays here on purpose. macOS ships bash 3.2 (/bin/bash), and
  # expanding an empty array under `set -u` ("${args[@]}") aborts there with
  # "args[@]: unbound variable" — newer bash (4.4+) tolerates it, which is why
  # this passed tests on Linux but failed on a real Mac. Flags are passed
  # with explicit branches instead.
  local installer="$INSTALL_DIR/installer/install.sh"
  if [ "$DRY_RUN" -eq 1 ]; then
    log "Running the safe installer: $installer --dry-run"
    dry "$installer" --dry-run
    return 0
  fi
  if [ ! -x "$installer" ]; then
    log "Installer not found at $installer — the clone may be incomplete. Aborting."
    exit 1
  fi
  if [ "$FORCE" -eq 1 ]; then
    log "Running the safe installer: $installer --force"
    "$installer" --force
  else
    log "Running the safe installer: $installer"
    "$installer"
  fi
}

finish() {
  cat <<EOF
Done.
  Repo:      $INSTALL_DIR
  Launcher:  /Applications/Raptor.app (placeholder — build the real UI below)
  Scripts:   ~/Documents/RaptorUI/{AutoExecute,Dumped}
  Version:   ~/Downloads/raptor-version.json

Next — build the SwiftUI app (needs Xcode 15+ on macOS 13+):
  open $INSTALL_DIR in Xcode (File -> New -> Project -> App, SwiftUI,
  bundle id dev.raptor.rebuild), add the files under App/, then Cmd+R.

Or check everything first:
  $INSTALL_DIR/scripts/check.sh
EOF
}

main() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      --force) FORCE=1 ;;
      --dir) INSTALL_DIR="$2"; shift ;;
      --ref) REF="$2"; shift ;;
      --help|-h) usage; exit 0 ;;
      *) log "Unknown option: $1"; usage; exit 1 ;;
    esac
    shift
  done
  log "Raptor bootstrap (ref=$REF, dir=$INSTALL_DIR, dry-run=$DRY_RUN)"
  [ "$DRY_RUN" -eq 1 ] || check_os
  check_tools
  fetch_repo
  run_installer
  [ "$DRY_RUN" -eq 1 ] || finish
}

main "$@"
