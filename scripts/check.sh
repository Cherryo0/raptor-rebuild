#!/usr/bin/env bash
# Static checks: file tree, Python compile, shell syntax, shellcheck if present.
set -euo pipefail
cd "$(dirname "$0")/.."
echo "== tree =="
find . -type f -not -path './.venv/*' -not -path './.git/*' | sort
echo "== python compile =="
python3 -m py_compile api-client/raptor_api.py api-client/tests/test_api_client.py
echo "Python OK"
echo "== shell syntax =="
bash -n installer/bootstrap.sh installer/install.sh installer/quickfix.sh scripts/dev-setup.sh scripts/check.sh
echo "Shell OK"
if command -v shellcheck >/dev/null 2>&1; then
  echo "== shellcheck =="
  shellcheck installer/bootstrap.sh installer/install.sh installer/quickfix.sh scripts/dev-setup.sh scripts/check.sh
  echo "shellcheck OK"
else
  echo "shellcheck not installed — skipped"
fi
if command -v pytest >/dev/null 2>&1; then
  echo "== pytest =="
  (cd api-client && python3 -m pytest tests/ -q)
fi
echo "All checks passed."
