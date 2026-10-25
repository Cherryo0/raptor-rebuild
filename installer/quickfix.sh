#!/usr/bin/env bash
# Raptor Rebuild — SAFE repair script.
# Verifies the launcher placeholder + ~/Documents/RaptorUI, re-creates
# missing directories, and rewrites the version file. No patching, no
# downloading, no Roblox interaction.
# Usage: ./installer/quickfix.sh [--dry-run] [--help]
set -euo pipefail

VERSION="0.1.0"
SCRIPTS_DIR="$HOME/Documents/RaptorUI"
DRY_RUN=0

log() { printf '[raptor-quickfix] %s\n' "$*"; }

usage() {
  cat <<'USAGE'
Usage: quickfix.sh [--dry-run] [--help]
  --dry-run   Report what would be fixed without changing anything.
Verifies the Raptor launcher placeholder and scripts directory, re-creates
missing folders, and rewrites ~/Downloads/raptor-version.json.
USAGE
}

main() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      --help|-h) usage; exit 0 ;;
      *) log "Unknown option: $1"; usage; exit 1 ;;
    esac
    shift
  done
  log "Raptor quickfix v$VERSION (dry-run=$DRY_RUN)"
  local problems=0
  if [ -d "/Applications/Raptor.app" ]; then log "OK: /Applications/Raptor.app exists."; else log "MISSING: /Applications/Raptor.app (run install.sh)"; problems=$((problems + 1)); fi
  for dir in "$SCRIPTS_DIR" "$SCRIPTS_DIR/AutoExecute" "$SCRIPTS_DIR/Dumped"; do
    if [ -d "$dir" ]; then log "OK: $dir"; else
      log "MISSING: $dir — recreating."
      if [ "$DRY_RUN" -eq 1 ]; then log "[dry-run] would run: mkdir -p $dir"; else mkdir -p "$dir"; fi
    fi
  done
  if [ "$DRY_RUN" -eq 0 ]; then
    printf '{\n  "version": "%s",\n  "repaired_at": "%s",\n  "launcher": "placeholder"\n}\n' "$VERSION" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$HOME/Downloads/raptor-version.json"
    log "Rewrote ~/Downloads/raptor-version.json"
  else
    log "[dry-run] would rewrite ~/Downloads/raptor-version.json"
  fi
  if [ "$problems" -gt 0 ]; then log "Quickfix finished with $problems missing item(s) noted above."; else log "Quickfix finished: everything present."; fi
}

main "$@"
