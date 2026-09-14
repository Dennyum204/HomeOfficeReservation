#!/usr/bin/env python3
"""Compile and verify an APK with a disposable validation key. Never install or distribute it."""
import hashlib
import json
import os
from pathlib import Path
import secrets
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def main():
    with tempfile.TemporaryDirectory(prefix="ho012-signing-") as folder:
        private = Path(folder)
        password = secrets.token_hex(32)
        env = {**os.environ, "HO_VALIDATION_KEY_PASSWORD": password}
        env.pop("HO_FIREBASE_ANDROID_CONFIG", None)
        env["HO_ANDROID_SIGNING_PROPERTIES"] = str(private / "signing.properties")
        keytool = shutil.which("keytool")
        flutter = shutil.which("flutter")
        sdk = Path(os.environ.get("ANDROID_HOME", os.environ.get("ANDROID_SDK_ROOT", "")))
        apksigner = next(iter(sorted(sdk.glob("build-tools/*/apksigner.bat" if os.name == "nt" else "build-tools/*/apksigner"), reverse=True)), None)
        if not keytool or not flutter or not apksigner:
            raise SystemExit("Prepared Java/Flutter/Android build tools are required.")
        subprocess.run([keytool, "-genkeypair", "-noprompt", "-alias", "validation", "-keyalg", "RSA", "-keysize", "3072", "-validity", "2",
                        "-dname", "CN=HO012 disposable validation", "-keystore", str(private / "validation.jks"),
                        "-storepass:env", "HO_VALIDATION_KEY_PASSWORD", "-keypass:env", "HO_VALIDATION_KEY_PASSWORD"], env=env, check=True, capture_output=True)
        (private / "signing.properties").write_text("storeFile=" + (private / "validation.jks").as_posix() +
            "\nstorePassword=" + password + "\nkeyAlias=validation\nkeyPassword=" + password + "\n")
        subprocess.run([flutter, "build", "apk", "--release", "--dart-define=API_BASE_URL=https://pilot.example.invalid"],
                       cwd=ROOT / "apps/mobile", env=env, check=True)
        apk = ROOT / "apps/mobile/build/app/outputs/flutter-apk/app-release.apk"
        subprocess.run([str(apksigner), "verify", "--verbose", str(apk)], check=True)
        evidence = {"apk": "compiled and signature verified with disposable validation key", "sha256": hashlib.sha256(apk.read_bytes()).hexdigest(),
                    "installed": False, "distributed": False, "live_push": False, "pilot_signing_key": "not created"}
        (ROOT / "ho012-android-evidence.json").write_text(json.dumps(evidence, indent=2) + "\n")
        print(json.dumps(evidence))


if __name__ == "__main__":
    main()
