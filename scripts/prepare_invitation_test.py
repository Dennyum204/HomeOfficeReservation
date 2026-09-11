#!/usr/bin/env python3
"""Create one synthetic pending invitation on a loopback API and save native-test input privately."""
import argparse
import json
import os
from pathlib import Path
import secrets
import time
import urllib.error
import urllib.parse
import urllib.request
import uuid

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base-url", required=True)
    parser.add_argument("--accounts", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    url = urllib.parse.urlparse(args.base_url)
    if url.scheme not in {"http", "https"} or url.hostname not in {"127.0.0.1", "localhost", "::1"}:
        raise SystemExit("Synthetic preparation is loopback-only.")
    if args.output.resolve().is_relative_to(ROOT):
        raise SystemExit("Test credentials/codes must stay outside Git.")
    accounts = json.loads(args.accounts.read_text(encoding="utf-8-sig"))
    config = json.loads((ROOT / "apps/api/src/HomeOffice.Api/appsettings.Local.json").read_text(encoding="utf-8-sig"))
    if config.get("Email", {}).get("Transport", "Capture") != "Capture":
        raise SystemExit("This CI helper requires private file capture, never external email.")
    capture = Path(config["Email"]["CaptureDirectory"])

    def post(path, body, token=None):
        headers = {"Content-Type": "application/json"}
        if token:
            headers["Authorization"] = "Bearer " + token
        req = urllib.request.Request(args.base_url.rstrip("/") + path, data=json.dumps(body).encode(), headers=headers)
        try:
            with urllib.request.urlopen(req, timeout=30) as response:
                raw = response.read()
                return json.loads(raw) if raw else None
        except urllib.error.HTTPError as error:
            raise SystemExit(f"Synthetic setup failed with HTTP {error.code}; no private response printed.") from None

    token = post("/api/v1/auth/token/login", {"email": accounts["admin"]["email"], "password": accounts["admin"]["password"]})["accessToken"]
    address = "native-ho014-" + uuid.uuid4().hex + "@homeoffice.example"
    password = "Ho9!" + secrets.token_urlsafe(24)
    post("/api/v1/admin/members", {"email": address, "displayName": "Convite Android sintético", "isEmployee": True, "isManager": False, "isAccountAdministrator": False}, token)
    code = None
    for _ in range(30):
        for file in capture.glob("*.json"):
            message = json.loads(file.read_text(encoding="utf-8-sig"))
            if message.get("email") == address and message.get("purpose") == "activate":
                code = message["code"]
        if code:
            break
        time.sleep(1)
    if not code:
        raise SystemExit("No local activation capture found; invitation remains pending for inspection.")
    output = json.loads(args.output.read_text(encoding="utf-8")) if args.output.exists() else {}
    output.update(TEST_INVITE_EMAIL=address, TEST_INVITE_PASSWORD=password, TEST_INVITE_CODE=code)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(output, indent=2) + "\n", encoding="utf-8")
    if os.name != "nt":
        args.output.chmod(0o600)
    if os.environ.get("GITHUB_ACTIONS") == "true":
        print("::add-mask::" + password)
        print("::add-mask::" + code)
    print("Synthetic invitation pending; native-test input saved privately. No real email or account activated.")


if __name__ == "__main__":
    main()
