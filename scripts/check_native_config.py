#!/usr/bin/env python3
"""Fast encoding/transport configuration guard; does not replace Android/iOS builds."""
from pathlib import Path
import plistlib
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1] / "apps/mobile"
import argparse
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--include-ios", action="store_true", help="Optional reference checks for explicitly selected iOS work.")
args = parser.parse_args()
if args.include_ios:
    for path in (ROOT / "ios/Runner").glob("*.plist"):
        plistlib.loads(path.read_bytes())
    release = plistlib.loads((ROOT / "ios/Runner/Info.plist").read_bytes())
    debug = plistlib.loads((ROOT / "ios/Runner/Info-Debug.plist").read_bytes())
    assert not release.get("NSAppTransportSecurity", {}).get("NSAllowsArbitraryLoads", False)
    assert debug["NSAppTransportSecurity"]["NSAllowsArbitraryLoads"] is True
android = "{http://schemas.android.com/apk/res/android}"
main = ET.parse(ROOT / "android/app/src/main/AndroidManifest.xml").getroot()
development = ET.parse(ROOT / "android/app/src/debug/AndroidManifest.xml").getroot()
assert main.find("application").get(android + "usesCleartextTraffic") == "false"
assert development.find("application").get(android + "usesCleartextTraffic") == "true"
assert any(p.get(android + "name") == "android.permission.INTERNET" for p in main.findall("uses-permission"))
print("Active native configuration parses correctly; HTTP exceptions are debug-only.")
