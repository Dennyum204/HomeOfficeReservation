#!/usr/bin/env python3
"""Require database readiness through the selected Android emulator's host bridge."""
import argparse
import subprocess
import time
import urllib.error
import urllib.request


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--serial", required=True)
    parser.add_argument("--port", type=int, default=5080)
    args = parser.parse_args()
    if not 1 <= args.port <= 65535 or not args.serial.startswith("emulator-") or not args.serial[9:].isdigit():
        parser.error("Select an emulator serial and valid local API port.")
    # The emulator may report boot complete before its host bridge is usable.
    # Read-only readiness retries never retry account or planning mutations.
    command = (
        "(printf 'GET /health/ready HTTP/1.1\\r\\nHost: 10.0.2.2:"
        + str(args.port)
        + "\\r\\nConnection: close\\r\\n\\r\\n'; sleep 1) | "
        + f"toybox nc -w 3 -W 3 10.0.2.2 {args.port}"
    )
    for attempt in range(10):
        try:
            result = subprocess.run(["adb", "-s", args.serial, "shell", command], capture_output=True, timeout=8)
            if result.returncode == 0 and result.stdout.startswith(b"HTTP/1.1 200 ") and b"Healthy" in result.stdout:
                print("Android host bridge and real PostgreSQL readiness: HTTP 200 Healthy.")
                return
        except subprocess.TimeoutExpired:
            pass
        if attempt < 9:
            time.sleep(1)
    try:
        with urllib.request.urlopen(f"http://127.0.0.1:{args.port}/health/ready", timeout=3) as response:
            status = str(response.status)
    except urllib.error.HTTPError as error:
        status = str(error.code)
    except (OSError, urllib.error.URLError):
        status = "unreachable"
    raise SystemExit(f"Android readiness failed; host readiness={status}. Native tests have not passed. No private API logs printed.")


if __name__ == "__main__":
    main()
