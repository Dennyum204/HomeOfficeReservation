#!/usr/bin/env python3
"""Start real Kestrel, check liveness/readiness, optionally run the generated Dart client."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time
import urllib.error
import urllib.request

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--database", action="store_true", help="Require HO_TEST_DATABASE and readiness 200")
    parser.add_argument("--dart-client", action="store_true")
    parser.add_argument("--port", type=int, default=5082)
    args = parser.parse_args()
    connection = os.environ.get("HO_TEST_DATABASE") if args.database else "Host=127.0.0.1;Port=1;Database=unavailable;Username=test;Password=synthetic;Timeout=1"
    if not connection:
        raise SystemExit("--database requires HO_TEST_DATABASE; never skips database verification.")
    origin = f"http://127.0.0.1:{args.port}"
    env = {**os.environ, "ASPNETCORE_ENVIRONMENT": "Development", "ConnectionStrings__Database": connection}
    with tempfile.TemporaryFile() as log:
        process = subprocess.Popen(["dotnet", "run", "--project", str(ROOT / "apps/api/src/HomeOffice.Api"),
            "-c", "Release", "--no-build", "--no-launch-profile", "--urls", origin], cwd=ROOT, env=env, stdout=log, stderr=log)
        try:
            for _ in range(80):
                if process.poll() is not None:
                    raise SystemExit("API exited before startup. Run the documented API command to diagnose locally.")
                try:
                    with urllib.request.urlopen(origin + "/health/live", timeout=2) as response:
                        assert response.status == 200
                    break
                except (urllib.error.URLError, TimeoutError):
                    time.sleep(.25)
            else:
                raise SystemExit("API startup timed out")
            try:
                with urllib.request.urlopen(origin + "/health/ready", timeout=10) as response:
                    status = response.status
            except urllib.error.HTTPError as error:
                status = error.code
            assert status == (200 if args.database else 503), f"Unexpected readiness status {status}"
            with urllib.request.urlopen(origin + "/api/v1/workspace", timeout=5) as response:
                data = json.load(response)
            assert data["apiVersion"] == "v1" and data["planningTimeZones"] == ["Europe/Lisbon", "Europe/Zurich"]
            if args.dart_client:
                dart = shutil.which("dart")
                if not dart:
                    raise SystemExit("Dart SDK is required for --dart-client")
                subprocess.run([dart, "run", "tool/smoke_api.dart", origin], cwd=ROOT / "apps/mobile", check=True)
            print(f"Real API startup, workspace and readiness ({status}) verified.")
        finally:
            process.terminate()
            try:
                process.wait(timeout=10)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait(timeout=5)


if __name__ == "__main__":
    main()
