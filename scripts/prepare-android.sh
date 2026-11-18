#!/bin/bash
set -euo pipefail
POCKET_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$POCKET_ROOT"
source scripts/android-env.sh
python3 - <<'PY'
import time,zipfile,pathlib,hashlib
p=pathlib.Path('downloads/android_source.zip')
while not zipfile.is_zipfile(p):time.sleep(10)
with zipfile.ZipFile(p) as z:
 if z.testzip():raise SystemExit('Template CRC validation failed')
 z.extractall('android/build')
pathlib.Path('android/.gdignore').touch()
pathlib.Path('android/.build_version').write_text('res://downloads/android_source.zip ['+hashlib.md5(p.read_bytes()).hexdigest()+']\n')
print('ANDROID_TEMPLATE_READY',flush=True)
PY
chmod +x android/build/gradlew
if [[ ! -f .cache/android/debug.keystore ]]; then
 "$JAVA_HOME/bin/keytool" -genkeypair -keystore "$POCKET_ROOT/.cache/android/debug.keystore" -storepass android -alias androiddebugkey -keypass android -dname "CN=Android Debug,O=Android,C=US" -keyalg RSA -keysize 2048 -validity 10000
fi
python3 - <<'PY'
from pathlib import Path
p=Path('tools/editor_data/editor_settings-4.7.tres')
s=p.read_text()
line='export/android/debug_keystore = "'+str(Path('.cache/android/debug.keystore').resolve())+'"'
s='\n'.join(x for x in s.splitlines() if not x.startswith('export/android/debug_keystore'))+'\n'+line+'\n'
p.write_text(s)
PY
bash scripts/build-android.sh > logs/android-build.log 2>&1
