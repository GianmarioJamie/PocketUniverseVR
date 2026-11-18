#!/bin/bash
set -euo pipefail
POCKET_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$POCKET_ROOT/scripts/android-env.sh"
APK="$POCKET_ROOT/builds/android/pocket-universe-debug.apk"
ADB="$ANDROID_HOME/platform-tools/adb"
if [[ ! -f "$APK" ]]; then echo 'APK mancante: esegui prima scripts/build-android.sh.'; exit 1; fi
"$ADB" devices
DEVICE_COUNT=$("$ADB" devices | awk 'NR>1 && $2=="device" {n++} END {print n+0}')
if [[ "$DEVICE_COUNT" != 1 ]]; then
 echo 'Collega un solo Quest via USB, abilita la modalità sviluppatore e autorizza il computer nel visore.'
 exit 1
fi
"$ADB" install -r "$APK"
echo 'Installazione completata. Apri Pocket Universe VR nel visore.'
