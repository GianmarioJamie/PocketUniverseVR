#!/bin/bash
set -euo pipefail
POCKET_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$POCKET_ROOT/logs" "$POCKET_ROOT/.cache/tmp"
export TMPDIR="$POCKET_ROOT/.cache/tmp/"
GODOT="$POCKET_ROOT/tools/Godot.app/Contents/MacOS/Godot"
"$GODOT" --headless --xr-mode off --path "$POCKET_ROOT" --editor --import --log-file "$POCKET_ROOT/logs/import.log"
"$GODOT" --headless --xr-mode off --path "$POCKET_ROOT" --log-file "$POCKET_ROOT/logs/smoke-test.log" -- --desktop --smoke-test
