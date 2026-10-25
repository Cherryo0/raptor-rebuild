#!/usr/bin/env bash
# Dev setup: create the local scripts dir + Python venv (optional).
# Usage: ./scripts/dev-setup.sh [--with-venv]
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p "$HOME/Documents/RaptorUI/AutoExecute" "$HOME/Documents/RaptorUI/Dumped"
echo "Created ~/Documents/RaptorUI/{AutoExecute,Dumped}"
if [ "${1:-}" = "--with-venv" ]; then
  python3 -m venv .venv
  .venv/bin/pip install -r api-client/requirements.txt
  echo "Virtualenv ready: .venv"
fi
echo "Dev setup done. Run ./scripts/check.sh to verify."
