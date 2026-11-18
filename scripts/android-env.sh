#!/usr/bin/env bash
# Source this file. Project/SDK stay on SSD; user-approved temporary Gradle cache uses internal APFS.
POCKET_PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export ANDROID_HOME="$POCKET_PROJECT_ROOT/tools/android-sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export ANDROID_USER_HOME="$POCKET_PROJECT_ROOT/.cache/android"
export ANDROID_EMULATOR_HOME="$POCKET_PROJECT_ROOT/.cache/android/emulator"
export POCKET_BUILD_CACHE="/private/tmp/pocket-universe-build-cache"
export GRADLE_USER_HOME="$POCKET_BUILD_CACHE/gradle"
export TMPDIR="$POCKET_BUILD_CACHE/tmp"
export JAVA_HOME="$POCKET_PROJECT_ROOT/tools/jdk/Contents/Home"
export JAVA_TOOL_OPTIONS="-Duser.home=$POCKET_PROJECT_ROOT/.cache/java -Djava.io.tmpdir=$TMPDIR"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
mkdir -p "$ANDROID_USER_HOME" "$ANDROID_EMULATOR_HOME" "$GRADLE_USER_HOME" "$TMPDIR" "$POCKET_PROJECT_ROOT/.cache/java"

mkdir -p "$GRADLE_USER_HOME/init.d"
cp "$POCKET_PROJECT_ROOT/scripts/gradle-internal-cache.init.gradle" "$GRADLE_USER_HOME/init.d/pocket-cache.gradle"
