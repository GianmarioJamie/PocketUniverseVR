#!/bin/bash
set -euo pipefail
POCKET_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$POCKET_ROOT"
while [[ $(stat -f%z downloads/godot-macos.zip) -lt 170622178 ]]; do sleep 10; done
unzip -q -o downloads/godot-macos.zip -d tools
POCKET_BIN_DIR="$POCKET_ROOT/tools/Godot.app/Contents/MacOS"
touch "$POCKET_BIN_DIR/_sc_"
mkdir -p "$POCKET_ROOT/tools/editor_data" .cache/tmp logs
cat > "$POCKET_ROOT/tools/editor_data/editor_settings-4.7.tres" <<SETTINGS
[gd_resource type="EditorSettings" format=3]
[resource]
export/android/java_sdk_path = "$POCKET_ROOT/tools/jdk/Contents/Home"
export/android/android_sdk_path = "$POCKET_ROOT/tools/android-sdk"
filesystem/file_dialog/show_hidden_files = false
SETTINGS
export TMPDIR="$POCKET_ROOT/.cache/tmp/"
"$POCKET_BIN_DIR/Godot" --headless --xr-mode off --path "$POCKET_ROOT" --script scripts/make_action_map.gd --log-file "$POCKET_ROOT/logs/action-map.log"
"$POCKET_BIN_DIR/Godot" --headless --xr-mode off --path "$POCKET_ROOT" --editor --import --log-file "$POCKET_ROOT/logs/import.log"
