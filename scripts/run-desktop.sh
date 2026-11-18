#!/bin/bash
set -euo pipefail
POCKET_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$POCKET_ROOT/.cache/tmp" "$POCKET_ROOT/logs"
export TMPDIR="$POCKET_ROOT/.cache/tmp/"
exec "$POCKET_ROOT/tools/Godot.app/Contents/MacOS/Godot" --path "$POCKET_ROOT" --xr-mode off --rendering-method gl_compatibility --log-file "$POCKET_ROOT/logs/desktop.log" "$@" -- --desktop
