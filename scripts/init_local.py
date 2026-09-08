#!/usr/bin/env python3
"""Create ignored local PostgreSQL/API configuration without displaying its password."""
import json
from pathlib import Path
import secrets
import sys

root = Path(__file__).resolve().parents[1]
env = root / "infra/.env"
settings = root / "apps/api/src/HomeOffice.Api/appsettings.Local.json"
if env.exists() and settings.exists():
    print("Existing local configuration preserved; no files changed.")
    sys.exit(0)
if env.exists() or settings.exists():
    raise SystemExit("Existing local configuration preserved. See infra/README.md to align both files manually.")
password = secrets.token_hex(24)
env.write_text(f"POSTGRES_PASSWORD={password}\n", encoding="utf-8")
settings.write_text(json.dumps({"ConnectionStrings": {"Database":
    f"Host=localhost;Port=5432;Database=homeoffice;Username=homeoffice;Password={password};Timeout=3;Command Timeout=5"
}}, indent=2) + "\n", encoding="utf-8")
print("Created ignored infra/.env and API appsettings.Local.json. No credentials printed.")
