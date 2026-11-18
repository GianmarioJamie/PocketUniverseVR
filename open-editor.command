#!/bin/bash
set -euo pipefail
POCKET_ROOT="$(cd "$(dirname "$0")" && pwd)"
source "$POCKET_ROOT/scripts/android-env.sh"
exec "$POCKET_ROOT/tools/Godot.app/Contents/MacOS/Godot" --editor --path "$POCKET_ROOT" --xr-mode off --log-file "$POCKET_ROOT/logs/editor.log"
