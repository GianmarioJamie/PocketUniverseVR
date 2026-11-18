#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/android-env.sh"
cd "$POCKET_PROJECT_ROOT"
POCKET_GODOT="$POCKET_PROJECT_ROOT/tools/Godot.app/Contents/MacOS/Godot"
if [[ ! -x "$POCKET_GODOT" || ! -x "$JAVA_HOME/bin/java" ]]; then
    printf '%s\n' 'Godot or JDK not installed yet. See docs/ANDROID.md.' >&2
    exit 1
fi
mkdir -p builds/android
POCKET_APP_VERSION="$(python3 -c 'import pathlib,re; print(re.search(r"^version/name=\"([0-9.]+)\"",pathlib.Path("export_presets.cfg").read_text(),re.M).group(1))')"
if [[ "${1:-}" == "--release" ]]; then
    if [[ ! -f signing/release.env ]]; then
        printf '%s\n' 'Missing release signing key. See docs/ANDROID.md.' >&2
        exit 1
    fi
    source signing/release.env
    export GODOT_ANDROID_KEYSTORE_RELEASE_PATH="$POCKET_PROJECT_ROOT/signing/pocket-universe-release.keystore"
    export GODOT_ANDROID_KEYSTORE_RELEASE_USER GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD
    exec "$POCKET_GODOT" --headless --xr-mode off --log-file "$POCKET_PROJECT_ROOT/logs/android-release-export.log" --path "$POCKET_PROJECT_ROOT" --export-release "Meta Quest" "$POCKET_PROJECT_ROOT/builds/android/pocket-universe-release-v$POCKET_APP_VERSION.apk"
fi
if [[ -n "${1:-}" ]]; then
    printf '%s\n' 'Usage: build-android.sh [--release]' >&2
    exit 1
fi
exec "$POCKET_GODOT" --headless --xr-mode off --log-file "$POCKET_PROJECT_ROOT/logs/android-export.log" --path "$POCKET_PROJECT_ROOT" --export-debug "Meta Quest" "$POCKET_PROJECT_ROOT/builds/android/pocket-universe-debug.apk"
