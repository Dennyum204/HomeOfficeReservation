#!/usr/bin/env python3
"""Compile native FCM wiring with invented configuration; never install or send."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def main():
    flutter = shutil.which("flutter")
    if not flutter:
        raise SystemExit("The pinned Flutter SDK is required.")
    # No real project, API key, service account, device address or user session.
    config = {
        "project_info": {"project_number": "123456789012", "project_id": "homeoffice-synthetic-invalid"},
        "client": [{
            "client_info": {
                "mobilesdk_app_id": "1:123456789012:android:0123456789abcdef012345",
                "android_client_info": {"package_name": "dev.homeoffice.homeoffice_mobile"},
            },
            "api_key": [{"current_key": "AIzaSySYNTHETIC_NOT_A_REAL_KEY_12345678901"}],
        }],
        "configuration_version": "1",
    }
    with tempfile.TemporaryDirectory(prefix="ho007-synthetic-fcm-") as temporary:
        folder = Path(temporary).resolve()
        if folder.is_relative_to(ROOT) or folder.parent != Path(tempfile.gettempdir()).resolve():
            raise SystemExit("Use the system temporary directory outside the repository.")
        path = folder / "google-services.json"
        path.write_text(json.dumps(config), encoding="utf-8")
        environment = {**os.environ, "HO_FIREBASE_ANDROID_CONFIG": str(path)}
        subprocess.run([flutter, "build", "apk", "--debug", "--dart-define=API_BASE_URL=http://10.0.2.2:5080",
                        "--dart-define=FCM_ENABLED=true"], cwd=ROOT / "apps/mobile", env=environment, check=True)
    print("Synthetic FCM native configuration compiled. NOT installed; NO real FCM delivery verified.")


if __name__ == "__main__":
    main()
