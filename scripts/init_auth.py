#!/usr/bin/env python3
"""Prepare private synthetic accounts and encrypted development key persistence; never print credentials."""
import argparse
import json
import os
from pathlib import Path
import secrets
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def private_write(path, data):
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    if os.name != "nt":
        path.chmod(0o600)


def development_certificate(path, password):
    """Standard X.509/PFX tools; macOS CI must not wait for an interactive developer Keychain."""
    try:
        if sys.platform == "darwin":
            openssl = shutil.which("openssl")
            if not openssl:
                raise SystemExit("OpenSSL is required for noninteractive macOS development certificate setup.")
            # This temporary PEM stays in the private 0700 parent and is removed after PFX export.
            with tempfile.TemporaryDirectory(prefix="certificate-", dir=path.parent) as folder:
                key = str(Path(folder) / "key.pem")
                public = str(Path(folder) / "certificate.pem")
                subprocess.run([openssl, "req", "-x509", "-newkey", "rsa:2048", "-sha256", "-days", "365",
                    "-nodes", "-subj", "/CN=HomeOfficeDevelopmentProtection", "-keyout", key, "-out", public],
                    check=True, capture_output=True, timeout=60)
                subprocess.run([openssl, "pkcs12", "-export", "-inkey", key, "-in", public,
                    "-out", str(path), "-passout", "env:HO_DEV_CERT_PASSWORD"],
                    env={**os.environ, "HO_DEV_CERT_PASSWORD": password}, check=True, capture_output=True, timeout=60)
        else:
            subprocess.run(["dotnet", "dev-certs", "https", "--export-path", str(path), "--password", password],
                check=True, capture_output=True, timeout=60)
    except (subprocess.SubprocessError, OSError):
        raise SystemExit("Could not prepare the private development certificate within 60 seconds. Check the local SDK/OpenSSL setup.") from None


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    base = Path(os.environ.get("LOCALAPPDATA", str(Path.home() / ".local/share")))
    parser.add_argument("--private-dir", type=Path, help="Private directory; otherwise reuse the existing configured key directory's parent")
    parser.add_argument("--database-from-env", help="Use this environment variable as the local connection, without displaying it")
    args = parser.parse_args()
    settings = ROOT / "apps/api/src/HomeOffice.Api/appsettings.Local.json"
    if not settings.exists() and not args.database_from_env:
        subprocess.run([sys.executable, str(ROOT / "scripts/init_local.py")], check=True)
    config = json.loads(settings.read_text(encoding="utf-8")) if settings.exists() else {}
    existing_keys = config.get("DataProtection", {}).get("KeyDirectory")
    default_folder = Path(existing_keys).parent if existing_keys else base / "HomeOfficeReservation/identity"
    # Reuse the same credentials even when Codex/MSIX and a normal terminal have different LOCALAPPDATA.
    folder = (args.private_dir or default_folder).resolve()
    if folder.is_relative_to(ROOT):
        raise SystemExit("Private account/key/email material must be outside the repository.")
    folder.mkdir(parents=True, exist_ok=True)
    if os.name != "nt":
        folder.chmod(0o700)
    if args.database_from_env:
        connection = os.environ.get(args.database_from_env)
        if not connection:
            raise SystemExit("Requested database environment variable is missing.")
        config.setdefault("ConnectionStrings", {})["Database"] = connection
    accounts_path = folder / "accounts.json"
    if not accounts_path.exists():
        def account(role, name):
            return {"email": f"{role}@homeoffice.example", "password": "Ho9!" + secrets.token_urlsafe(20), "displayName": name}
        private_write(accounts_path, {"organizationName": "HomeOffice local", "admin": account("admin", "Admin de contas"),
            "manager": account("manager", "Chefia de teste"), "employee": account("employee", "Colaborador de teste")})
    accounts = json.loads(accounts_path.read_text(encoding="utf-8"))
    protection = config.setdefault("DataProtection", {})
    protection.setdefault("KeyDirectory", str(folder / "keys"))
    if not protection.get("CertificatePath"):
        password = secrets.token_urlsafe(32)
        certificate = folder / "development-protection.pfx"
        development_certificate(certificate, password)
        if os.name != "nt":
            certificate.chmod(0o600)
        protection.update(CertificatePath=str(certificate), CertificatePassword=password)
    config.setdefault("Email", {}).setdefault("CaptureDirectory", str(folder / "email"))
    private_write(settings, config)
    private_write(folder / "client-test.json", {"TEST_EMAIL": accounts["employee"]["email"],
        "TEST_PASSWORD": accounts["employee"]["password"], "TEST_MANAGER_EMAIL": accounts["manager"]["email"],
        "TEST_MANAGER_PASSWORD": accounts["manager"]["password"]})
    if os.environ.get("GITHUB_ACTIONS") == "true":
        # Actions consumes these workflow commands and redacts subsequent logs.
        for role in ("employee", "manager", "admin"):
            print("::add-mask::" + accounts[role]["password"])
        print("::add-mask::" + protection["CertificatePassword"])
    print(f"Private development accounts: {accounts_path}")
    print(f"Private email capture: {config['Email']['CaptureDirectory']}")
    print("No credentials printed. Apply migrations and run --provision-dev with the private accounts path. Existing credentials preserved.")


if __name__ == "__main__":
    main()
