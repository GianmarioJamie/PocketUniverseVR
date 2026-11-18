#!/bin/bash
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT_BIN="$PROJECT_ROOT/tools/Godot.app/Contents/MacOS/Godot"
if [[ ! -x "$GODOT_BIN" ]]; then
  printf '%s\n' 'Godot non è ancora disponibile in tools/Godot.app.' >&2
  exit 1
fi
RUNTIME_MANIFEST="$(/usr/bin/find "$PROJECT_ROOT/tools/meta-xr-simulator" -type f -name meta_openxr_simulator.json -print -quit)"
if [[ -z "$RUNTIME_MANIFEST" ]]; then
  printf '%s\n' 'Meta XR Simulator non è ancora installato. Leggi docs/SIMULATOR.md.' >&2
  exit 1
fi
mkdir -p "$PROJECT_ROOT/logs" "$PROJECT_ROOT/tools/tmp"
export XR_RUNTIME_JSON="$RUNTIME_MANIFEST"
export TMPDIR="$PROJECT_ROOT/tools/tmp/"
printf 'Runtime: %s\n' "$XR_RUNTIME_JSON"
exec "$GODOT_BIN" --path "$PROJECT_ROOT" --rendering-method mobile --rendering-driver vulkan --xr-mode on --log-file "$PROJECT_ROOT/logs/xr-simulator.log" "$@"
