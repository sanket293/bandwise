#!/usr/bin/env bash
# Regenerates Drift code (*.g.dart).
#
# Why this script exists: sqlite3 >=3.3 ships a Dart 3.10 native *build hook*
# that breaks build_runner's AOT snapshot of its own codegen script. The Flutter
# app itself needs sqlite3 3.x at runtime (drift 2.34 API), so we can't just pin
# it down permanently. This script temporarily overrides sqlite3 to the last
# hook-free version (2.9.4) ONLY for the generation step, then restores the app's
# normal dependency set. The generated .g.dart is version-independent.
#
# Run from the project root:  ./tool/codegen.sh
set -euo pipefail

cd "$(dirname "$0")/.."

OVERRIDE_FILE="pubspec_overrides.yaml"
CREATED_OVERRIDE=0

cleanup() {
  if [[ "$CREATED_OVERRIDE" == "1" ]]; then
    rm -f "$OVERRIDE_FILE"
    echo "→ Removed temporary $OVERRIDE_FILE; restoring dependencies…"
    flutter pub get >/dev/null
  fi
}
trap cleanup EXIT

if [[ ! -f "$OVERRIDE_FILE" ]]; then
  cat > "$OVERRIDE_FILE" <<'YAML'
# TEMPORARY — created by tool/codegen.sh so build_runner can run. Safe to delete.
dependency_overrides:
  sqlite3: 2.9.4
YAML
  CREATED_OVERRIDE=1
  echo "→ Applied temporary sqlite3 2.9.4 override for codegen…"
  flutter pub get >/dev/null
fi

echo "→ Running build_runner…"
dart run build_runner build --delete-conflicting-outputs

echo "✓ Codegen complete."
