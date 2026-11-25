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
if [ -f Raptor.xcodeproj/project.pbxproj ]; then
  echo "== xcodeproj references =="
  missing=0
  for f in $(find App -name '*.swift'); do
    base=$(basename "$f")
    if ! grep -q "$base" Raptor.xcodeproj/project.pbxproj; then echo "missing from project.pbxproj: $f"; missing=1; fi
  done
  if [ "$missing" -eq 1 ]; then echo "xcodeproj check FAILED"; exit 1; fi
  echo "xcodeproj OK"
  echo "== app icon =="
  if [ ! -f App/Assets.xcassets/AppIcon.appiconset/Contents.json ]; then echo "missing AppIcon Contents.json"; exit 1; fi
  if [ ! -f App/Assets.xcassets/AppIcon.appiconset/icon_1024x1024.png ]; then echo "missing 1024 master icon"; exit 1; fi
  if ! grep -q "Assets.xcassets" Raptor.xcodeproj/project.pbxproj; then echo "Assets.xcassets not referenced in project.pbxproj"; exit 1; fi
  if ! grep -q "ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon" Raptor.xcodeproj/project.pbxproj; then echo "APPICON_NAME not set in project.pbxproj"; exit 1; fi
  python3 -c "import json; c=json.load(open('App/Assets.xcassets/AppIcon.appiconset/Contents.json')); assert len(c['images'])==10, len(c['images'])"
  echo "app icon OK"
fi
echo "All checks passed."
