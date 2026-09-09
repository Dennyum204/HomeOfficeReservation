#!/usr/bin/env python3
"""Run the native iOS test with diagnostic output, excluding private build/auth material."""
import argparse
import base64
import json
from pathlib import Path
import re
import subprocess
import sys
from urllib.parse import quote


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


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--device", required=True)
    parser.add_argument("--defines-file", type=Path, required=True)
    args = parser.parse_args()
    if sys.platform != "darwin":
        raise SystemExit("Native iOS execution requires macOS; it is not skipped as successful.")
    defines_path = args.defines_file.resolve()
    redactor = LogRedactor(json.loads(defines_path.read_text(encoding="utf-8")))
    command = ["flutter", "drive", "--verbose", "--no-dds", "--no-pub",
        "--driver=test_driver/integration_test.dart", "--target=integration_test/app_test.dart",
        "-d", args.device, "--dart-define=API_BASE_URL=http://localhost:5080",
        "--dart-define-from-file=" + str(defines_path)]
    # Only sanitized output reaches Actions. No unredacted log/artifact is written.
    with subprocess.Popen(command, cwd=Path(__file__).resolve().parents[1] / "apps/mobile",
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, errors="replace", bufsize=1) as process:
        for line in process.stdout:
            print(redactor.clean(line), end="", flush=True)
        return process.wait()


if __name__ == "__main__":
    raise SystemExit(main())
