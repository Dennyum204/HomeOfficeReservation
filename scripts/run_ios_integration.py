#!/usr/bin/env python3
"""Run the native iOS test with diagnostic output, excluding private build/auth material."""
import argparse
import base64
import json
import os
from pathlib import Path
import plistlib
import queue
import re
import signal
import subprocess
import sys
import threading
from urllib.parse import quote, urlparse


class LogRedactor:
    def __init__(self, defines):
        variants = set()
        for key, value in defines.items():
            value = str(value)
            if not value:
                continue
            for text in (value, f"{key}={value}"):
                variants.update((text, quote(text, safe=""), base64.b64encode(text.encode()).decode()))
        self.variants = sorted(variants, key=len, reverse=True)

    def clean(self, line):
        # Flutter verbose builds include encoded Dart defines, not covered by GitHub's plain-text masks.
        if re.search(r"DART_DEFINES|dart-defines|TEST_(?:MANAGER_)?PASSWORD|access_?token|refresh_?token|Authorization|Bearer ", line, re.I):
            return "[private build/auth detail omitted]\n"
        for value in self.variants:
            line = line.replace(value, "[redacted]")
        # Debugger capability URLs are private too, even though this CI server is loopback-only.
        return re.sub(r"(https?|wss?)://(127\.0\.0\.1|localhost|\[::1\]):(\d+)/[^\s'\"\)]+", r"\1://\2:\3/[debug-session]", line)


def service_uri(line):
    if not re.search(r"Dart VM service.*listening", line, re.I):
        return None
    match = re.search(r"https?://[^\s'\"]+", line)
    if match and urlparse(match[0]).hostname in ("localhost", "127.0.0.1", "::1"):
        return match[0]
    return None


def streamed(command, folder, redactor, timeout):
    with subprocess.Popen(command, cwd=folder, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
        text=True, errors="replace", bufsize=1, start_new_session=True) as process:
        expired = threading.Event()
        def stop():
            expired.set()
            if process.poll() is None:
                os.killpg(process.pid, signal.SIGTERM)
        timer = threading.Timer(timeout, stop)
        timer.daemon = True
        timer.start()
        try:
            for line in process.stdout:
                print(redactor.clean(line), end="", flush=True)
            result = process.wait()
            if expired.is_set() or result:
                raise RuntimeError("Native command failed or exceeded its deadline; see sanitized output above.")
        finally:
            timer.cancel()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--device", required=True)
    parser.add_argument("--defines-file", type=Path, required=True)
    args = parser.parse_args()
    if sys.platform != "darwin":
        raise SystemExit("Native iOS execution requires macOS; it is not skipped as successful.")
    defines_path = args.defines_file.resolve()
    redactor = LogRedactor(json.loads(defines_path.read_text(encoding="utf-8")))
    folder = Path(__file__).resolve().parents[1] / "apps/mobile"
    print("Build the real native test entrypoint.", flush=True)
    # Build before booting the simulator and avoid thousands of verbose Xcode settings.
    # Both consume substantial resources on hosted runners; errors still pass the redactor.
    streamed(["flutter", "build", "ios", "--simulator", "--debug", "--no-pub",
        "--target=integration_test/app_test.dart", "--dart-define=API_BASE_URL=http://localhost:5080",
        "--dart-define-from-file=" + str(defines_path)], folder, redactor, 600)
    bundle = folder / "build/ios/iphonesimulator/Runner.app"
    with (bundle / "Info.plist").open("rb") as source:
        bundle_id = plistlib.load(source)["CFBundleIdentifier"]
    print("Boot only the selected simulator after compilation.", flush=True)
    devices = json.loads(subprocess.check_output(["xcrun", "simctl", "list", "devices", "available", "-j"],
        text=True, timeout=30))["devices"]
    selected = next(device for group in devices.values() for device in group if device["udid"] == args.device)
    if selected["state"] != "Booted":
        streamed(["xcrun", "simctl", "boot", args.device], folder, redactor, 60)
    streamed(["xcrun", "simctl", "bootstatus", args.device, "-b"], folder, redactor, 300)
    print("Install the test bundle in the selected simulator.", flush=True)
    streamed(["xcrun", "simctl", "install", args.device, str(bundle)], folder, redactor, 90)
    # Read the app's attached console instead of relying on macOS unified-log discovery.
    # Keep the debugger auth code and disabled mDNS publication used by flutter drive.
    print("Launch paused and read the authenticated debugger URI from its private console.", flush=True)
    with subprocess.Popen(["xcrun", "simctl", "launch", "--console", "--terminate-running-process",
        args.device, bundle_id, "--enable-dart-profiling", "--disable-vm-service-publication",
        "--start-paused", "--enable-checked-mode", "--verify-entry-points"],
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, errors="replace", bufsize=1) as console:
        addresses = queue.Queue()
        def read_console():
            for line in console.stdout:
                uri = service_uri(line)
                if uri:
                    addresses.put(uri)
                print(redactor.clean(line), end="", flush=True)
            addresses.put(None)
        reader = threading.Thread(target=read_console, daemon=True)
        reader.start()
        try:
            try:
                uri = addresses.get(timeout=90)
            except queue.Empty:
                uri = None
            if not uri:
                raise RuntimeError("The native app did not expose a loopback Dart VM service within 90 seconds.")
            print("Run the unchanged integration driver against the launched native app.", flush=True)
            streamed(["flutter", "drive", "--verbose", "--no-dds", "--no-pub",
                "--driver=test_driver/integration_test.dart", "--target=integration_test/app_test.dart",
                "-d", args.device, "--use-existing-app=" + uri], folder, redactor, 180)
        finally:
            try:
                subprocess.run(["xcrun", "simctl", "terminate", args.device, bundle_id],
                    capture_output=True, timeout=15)
            finally:
                if console.poll() is None:
                    console.terminate()
                reader.join(timeout=5)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (RuntimeError, OSError, subprocess.SubprocessError) as error:
        detail = str(error) if isinstance(error, RuntimeError) else type(error).__name__
        print("Native iOS execution failed: " + detail + ". See sanitized stage output.", flush=True)
        raise SystemExit(1) from None
