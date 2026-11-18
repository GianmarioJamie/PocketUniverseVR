#!/usr/bin/env python3
"""Check the exported binary, rather than trusting editor settings."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parent.parent
BUILD_TOOLS = ROOT / 'tools/android-sdk/build-tools/36.1.0'
parser = argparse.ArgumentParser()
parser.add_argument('apk', type=Path)
parser.add_argument('--release', action='store_true')
parser.add_argument('--expect-journey', action='store_true')
parser.add_argument('--report', type=Path)
args = parser.parse_args()
apk = args.apk.resolve()

def run(tool, *arguments):
    return subprocess.check_output([str(BUILD_TOOLS / tool), *map(str, arguments)], text=True)

def require(condition, message):
    if not condition:
        raise SystemExit('APK_CHECK_FAILED: ' + message)

tree = run('aapt', 'dump', 'xmltree', apk, 'AndroidManifest.xml')
badging = run('aapt', 'dump', 'badging', apk)
nodes, stack = [], []
for line in tree.splitlines():
    depth = len(line) - len(line.lstrip())
    element = re.match(r'\s*E: (\S+)', line)
    if element:
        while stack and stack[-1]['depth'] >= depth:
            stack.pop()
        node = {'tag': element[1], 'depth': depth, 'attributes': {}, 'parent': stack[-1] if stack else None}
        stack.append(node)
        nodes.append(node)
    elif stack:
        attribute = re.match(r'\s*A: ([^=(]+)(?:\([^)]*\))?=(.*)', line)
        if attribute:
            value = attribute[2]
            quoted = re.match(r'"([^"]*)"', value)
            typed = re.match(r'\(type 0x[0-9a-f]+\)(0x[0-9a-f]+)', value)
            stack[-1]['attributes'][attribute[1]] = quoted[1] if quoted else int(typed[1], 16) if typed else value

def find(tag, name=None):
    return [node for node in nodes if node['tag'] == tag and (name is None or node['attributes'].get('android:name') == name)]

manifest = find('manifest')[0]['attributes']
sdk = find('uses-sdk')[0]['attributes']
app = find('application')[0]['attributes']
require(manifest['package'] == 'com.jamiejoe.pocketuniverse', 'unexpected package')
require(sdk.get('android:targetSdkVersion') == 34, 'Meta immersive target SDK must be 34')
require(sdk.get('android:minSdkVersion') == 29, 'unexpected minimum SDK')
require(manifest.get('android:installLocation') == 0, 'installation must be auto')
head = find('uses-feature', 'android.hardware.vr.headtracking')
require(len(head) == 1 and head[0]['attributes'].get('android:required') == 0xffffffff and head[0]['attributes'].get('android:version') == 1, 'required 6DoF missing')
hands = find('uses-feature', 'oculus.software.handtracking')
require(len(hands) == 1 and hands[0]['attributes'].get('android:required') == 0xffffffff, 'required hand tracking missing')
require(find('uses-permission', 'com.oculus.permission.HAND_TRACKING'), 'hand permission missing')
require(not find('uses-permission', 'com.oculus.permission.EYE_TRACKING'), 'unused eye permission')
require(not find('uses-permission', 'android.permission.INTERNET'), 'unexpected network permission')
devices = find('meta-data', 'com.oculus.supportedDevices')[0]['attributes']['android:value'].split('|')
require(set(devices) == {'quest2', 'quest3', 'quest3s', 'questpro'}, 'device declaration changed')
require(find('category', 'com.oculus.intent.category.VR'), 'Meta immersive category missing')
require(find('category', 'org.khronos.openxr.intent.category.IMMERSIVE_HMD'), 'OpenXR category missing')
activities = [n for n in find('activity') if n['attributes'].get('android:name', '').endswith('.GodotApp')]
require(len(activities) == 1 and activities[0]['attributes'].get('android:excludeFromRecents') == 0xffffffff, 'immersive activity must be excluded from recents')
signature = run('apksigner', 'verify', '--verbose', '--print-certs', apk)
require('Verified using v2 scheme (APK Signature Scheme v2): true' in signature, 'v2 signature missing')
if args.release:
    require(app.get('android:debuggable', 0) == 0, 'release is debuggable')
    require('CN=Android Debug' not in signature, 'release uses debug certificate')
run('zipalign', '-c', '-P', '16', '4', apk)
with zipfile.ZipFile(apk) as archive:
    require(archive.testzip() is None, 'ZIP CRC failure')
    if args.expect_journey:
        require('assets/src/guided_journey.gdc' in archive.namelist(), 'guided journey module missing')
    libraries = [name for name in archive.namelist() if name.startswith('lib/') and name.endswith('.so')]
    require(libraries and all(name.startswith('lib/arm64-v8a/') for name in libraries), 'unexpected native architecture')
    for name in libraries:
        elf = archive.read(name)
        require(elf[:6] == b'\x7fELF\x02\x01', 'expected little-endian ELF64: ' + name)
        phoff = struct.unpack_from('<Q', elf, 32)[0]
        phsize, phcount = struct.unpack_from('<HH', elf, 54)
        for i in range(phcount):
            segment = struct.unpack_from('<IIQQQQQQ', elf, phoff + i * phsize)
            if segment[0] == 1:
                require(segment[7] >= 16384 and (segment[3] - segment[2]) % 16384 == 0, 'ELF 16KB alignment: ' + name)
    for notice in ['GODOT_LICENSE.txt', 'GODOT_THIRD_PARTY.json', 'GODOT_OPENXR_VENDORS.txt', 'META_LICENSE-SDK.txt', 'META_LICENSE-LOADER.txt']:
        require('assets/assets/licenses/' + notice in archive.namelist(), 'missing notice: ' + notice)
    require(not any('signing/' in name or name.endswith('.keystore') or name.endswith('release.env') for name in archive.namelist()), 'private signing material in APK')

report = {
    'apk': apk.name, 'version': manifest['android:versionName'], 'version_code': manifest['android:versionCode'],
    'build_type': 'release' if args.release else 'debug', 'bytes': apk.stat().st_size,
    'sha256': hashlib.sha256(apk.read_bytes()).hexdigest(), 'target_sdk': sdk['android:targetSdkVersion'],
    'min_sdk': sdk['android:minSdkVersion'], 'devices_declared': devices,
    'checks': ['required 6DoF and hands', 'Meta/OpenXR launch categories', 'exclude from recents',
               'no eye or internet permission', 'ARM64 only', 'signature v2', 'ZIP integrity',
               'ZIP/ELF 16KB alignment', 'license notices packaged', 'no signing secrets packaged'],
    'hardware_validation': 'Earlier version confirmed by user on Quest 2. Current version needs functional headset retest; Quest 3/3S/Pro not physically tested.',
    'submission_status': 'Not uploaded; Competition channel and invite URL, video, Devpost completion, dashboard policy fields and measured performance pending.'
}
if args.report:
    if args.expect_journey:
        report['checks'].append('guided journey module packaged')
    args.report.write_text(json.dumps(report, indent=2) + '\n')
print('APK_CHECK_PASS: ' + apk.name)
print(json.dumps(report, indent=2))
