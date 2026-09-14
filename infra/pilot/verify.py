#!/usr/bin/env python3
"""Real isolated Linux production-container acceptance. No external mail, FCM, deployment or APK upload."""
import http.cookiejar
import json
import os
from pathlib import Path
import re
import secrets
import shutil
import ssl
import smtplib
import subprocess
import tempfile
import time
import urllib.error
import urllib.request
import uuid
from datetime import datetime, timedelta, timezone
from operations import Operations, ROOT

STAGE = "initialization"


def command(args, **kwargs):
    result = subprocess.run(args, capture_output=True, timeout=900, **kwargs)
    if result.returncode:
        # All inputs in this harness are synthetic; keep raw diagnostic output private nonetheless.
        raise RuntimeError("Local command failed: " + args[0])
    return result.stdout


def main():
    global STAGE
    if os.name != "posix" or os.geteuid() != 0:
        raise RuntimeError("Run with sudo on an isolated Linux Docker host; no changes to a developer database.")
    image = "homeoffice:ho012-" + uuid.uuid4().hex[:12]
    STAGE = "production image build"
    subprocess.run(["docker", "build", "-f", str(Path(__file__).with_name("Dockerfile")), "-t", image, str(ROOT)], check=True)
    with tempfile.TemporaryDirectory(prefix="ho012-production-") as temporary:
        folder = Path(temporary)
        private = folder / "private"
        private.mkdir(mode=0o755)
        (private / "keys").mkdir()
        os.chown(private / "keys", 1654, 1654)
        password = "Ho9!" + secrets.token_hex(24)
        day = datetime.now(timezone.utc).date() + timedelta(days=30)
        planned_date = (day + timedelta(days=(7 - day.weekday()) % 7)).isoformat()
        def write(name, value):
            (private / name).write_text(value, encoding="utf-8")
        write("postgres-password", secrets.token_hex(32))
        write("database-password", password)
        write("smtp-auth", "pilot:" + password + "\n")
        write("firebase-admin.json", "{}\n")
        STAGE = "ephemeral TLS and protected keys"
        # Trust this self-signed endpoint explicitly in this disposable environment only.
        # Do not disable MailKit certificate/revocation validation or install trust on the developer PC.
        command(["openssl", "req", "-x509", "-newkey", "rsa:3072", "-nodes", "-days", "2", "-subj", "/CN=localhost",
                 "-addext", "subjectAltName=DNS:localhost,DNS:mailpit", "-addext", "basicConstraints=critical,CA:TRUE",
                 "-addext", "keyUsage=digitalSignature,keyEncipherment,keyCertSign", "-addext", "extendedKeyUsage=serverAuth",
                 "-keyout", str(private / "server.key"), "-out", str(private / "server.pem")])
        shutil.copyfile(private / "server.pem", private / "ca.pem")
        command(["openssl", "pkcs12", "-export", "-inkey", str(private / "server.key"), "-in", str(private / "server.pem"),
                 "-out", str(private / "protection.pfx"), "-passout", "env:HO_PFX_PASSWORD"], env={**os.environ, "HO_PFX_PASSWORD": password})
        for path in private.iterdir():
            if path.is_file():
                path.chmod(0o644)  # Synthetic only; the enclosing temporary directory is root-only 0700.
        config = {
            "AllowedHosts": "localhost", "Hosting": {"PublicOrigin": "https://localhost:18443", "KnownProxies": "10.77.0.2"},
            "ConnectionStrings": {"Database": "Host=database;Database=homeoffice;Username=homeoffice;Password=" + password},
            "DataProtection": {"KeyDirectory": "/var/lib/homeoffice/keys", "CertificatePath": "/run/config/protection.pfx", "CertificatePassword": password},
            "Email": {"Host": "mailpit", "Port": 1025, "From": "sender@pilot.example", "Username": "pilot", "Password": password},
            "Notifications": {"WorkerEnabled": True, "PushProvider": "Disabled"},
            "Logging": {"LogLevel": {"Default": "Warning"}}
        }
        write("application.json", json.dumps(config))
        write("bootstrap.json", json.dumps({"organizationName": "HO012 synthetic recovery", "email": "admin@pilot.example", "displayName": "Pilot test admin"}))
        env_file = folder / "pilot.env"
        env_file.write_text(f"HO_PROJECT=ho012-check-{uuid.uuid4().hex[:8]}\nHO_ENVIRONMENT=Production\nHO_PUBLIC_HOST=localhost\nHO_PRIVATE_DIR={private}\nHO_IMAGE={image}\n")
        # Same production compose and Caddy routing; only local ports, CA and SMTP sink differ.
        caddy = Path(__file__).with_name("Caddyfile").read_text().replace("{$HO_PUBLIC_HOST} {", "https://localhost {\n    tls /run/config/server.pem /run/config/server.key")
        write("Caddyfile", caddy)
        override = folder / "verify.yaml"
        override.write_text(json.dumps({"services": {
            "edge": {"ports": [], "volumes": [str(private / "Caddyfile") + ":/etc/caddy/Caddyfile:ro", str(private) + ":/run/config:ro"]},
            "app": {"environment": {"SSL_CERT_FILE": "/run/config/ca.pem"}, "volumes": [str(private / "ca.pem") + ":/run/config/ca.pem:ro"]},
            "mailpit": {"image": "axllent/mailpit:v1.31.1", "networks": ["pilot"], "ports": ["127.0.0.1:18025:8025", "127.0.0.1:11025:1025"],
                        "volumes": [str(private) + ":/run/config:ro"], "environment": {
                            "MP_SMTP_TLS_CERT": "/run/config/server.pem", "MP_SMTP_TLS_KEY": "/run/config/server.key",
                            "MP_SMTP_REQUIRE_STARTTLS": "true", "MP_SMTP_AUTH_FILE": "/run/config/smtp-auth"}}
        }}))
        # Compose merge requires !override to remove production published ports.
        ports = folder / "ports.yaml"
        ports.write_text('services:\n  edge:\n    ports: !override ["127.0.0.1:18443:443"]\n')
        ops = Operations(env_file, ("-f", str(override), "-f", str(ports)))
        effective = json.loads(ops.run("config", "--format", "json"))
        assert effective["services"]["app"]["tmpfs"] == ["/tmp:uid=1654,gid=1654,mode=700"]
        assert not effective["services"]["app"].get("ports") and not effective["services"]["database"].get("ports")
        assert effective["networks"]["pilot"]["ipam"]["config"][0]["ip_range"] == "10.77.0.128/25"
        context = ssl.create_default_context(cafile=str(private / "ca.pem"))
        jar = http.cookiejar.CookieJar()
        browser = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(jar), urllib.request.HTTPSHandler(context=context))
        def request(path, data=None, token=None, csrf=False, expected=200, method=None):
            headers = {"Content-Type": "application/json"}
            if token:
                headers["Authorization"] = "Bearer " + token
            if csrf:
                headers["X-CSRF-TOKEN"] = request("/api/v1/auth/csrf")["requestToken"]
            if method and method != "GET":
                headers["Idempotency-Key"] = str(uuid.uuid4())
            req = urllib.request.Request("https://localhost:18443" + path, None if data is None else json.dumps(data).encode(), headers, method=method)
            try:
                response = browser.open(req, timeout=15)
            except urllib.error.HTTPError as error:
                response = error
            body = response.read()
            assert response.status == expected, f"HTTP status {response.status}, expected {expected}"
            return json.loads(body) if body and "application/json" in response.headers.get("Content-Type", "") else body
        def ready():
            for _ in range(60):
                try:
                    ops.run("exec", "-T", "app", "bash", "/app/healthcheck.sh")
                    request("/api/v1/workspace")
                    return
                except (RuntimeError, OSError, urllib.error.URLError):
                    time.sleep(1)
            raise RuntimeError("Production readiness timeout")
        def email_code():
            for _ in range(30):
                messages = json.load(urllib.request.urlopen("http://127.0.0.1:18025/api/v1/messages"))
                if messages["messages"]:
                    message = json.load(urllib.request.urlopen("http://127.0.0.1:18025/api/v1/message/" + messages["messages"][0]["ID"]))
                    return message["Text"].replace("\r\n", "\n").split("\n\n")[1].strip()
                time.sleep(1)
            raise RuntimeError("STARTTLS capture timeout")
        def clear_mail():
            urllib.request.urlopen(urllib.request.Request("http://127.0.0.1:18025/api/v1/messages", method="DELETE")).close()
        def activate(email):
            code = email_code()
            request("/api/v1/auth/activation/complete", {"email": email, "code": code, "password": password}, expected=204)
            clear_mail()
        started = time.monotonic()
        try:
            STAGE = "isolated database initialization and migrations"
            ops.run("up", "-d", "--wait", "database", "mailpit")
            ops.run("run", "--rm", "--no-deps", "app", "--migrate")
            ops.run("run", "--rm", "--no-deps", "app", "--migrate")
            assert ops.sql('SELECT count(*) FROM "Members"') == "0", "Production must not seed accounts"
            ops.run("up", "-d", "app", "edge")
            ready()
            STAGE = "same-origin routing and protected endpoints"
            for route in ("/", "/calendar", "/requests", "/tasks", "/settings"):
                assert b'<div id="root">' in request(route)
            for route in ("/health/ready", "/health/live", "/openapi/v1.json", "/api/not-a-route"):
                request(route, expected=404)
            request("/api/v1/me", expected=401)
            request("/api/v1/auth/web/login", {"email": "admin@pilot.example", "password": password}, expected=400)
            STAGE = "proxy spoofing and production configuration rejection"
            direct = ops.run("exec", "-T", "database", "bash", "-c",
                "exec 3<>/dev/tcp/app/8080; printf 'GET /api/v1/workspace HTTP/1.1\\r\\nHost: localhost\\r\\nX-Forwarded-Proto: https\\r\\nConnection: close\\r\\n\\r\\n' >&3; IFS= read -r status <&3; printf '%s' \"$status\"")
            assert b" 400 " in direct, "Untrusted proxy spoof was accepted"
            ops.run("exec", "-T", "app", "bash", "-c", "test ! -e /run/config/postgres-password")
            for section, key, value in (("Hosting", "PublicOrigin", "http://localhost"), ("Hosting", "KnownProxies", ""), ("Notifications", "WorkerEnabled", False)):
                original = config[section][key]
                config[section][key] = value
                write("application.json", json.dumps(config))
                try:
                    ops.run("run", "--rm", "--no-deps", "app", timeout=30)
                except RuntimeError as rejected:
                    assert "OptionsValidationException" in str(rejected), "Unexpected configuration failure"
                else:
                    raise RuntimeError("Unsafe production configuration was accepted")
                finally:
                    config[section][key] = original
                    write("application.json", json.dumps(config))
            STAGE = "real production SMTP adapter against isolated STARTTLS sink"
            try:
                with smtplib.SMTP("localhost", 11025, timeout=10) as smtp:
                    smtp.starttls(context=ssl.create_default_context())
            except ssl.SSLError:
                pass
            else:
                raise RuntimeError("The isolated certificate was trusted without the explicit test trust store")
            with smtplib.SMTP("localhost", 11025, timeout=10) as smtp:
                smtp.starttls(context=context)
                try:
                    smtp.login("pilot", "deliberately-invalid")
                except smtplib.SMTPAuthenticationError:
                    pass
                else:
                    raise RuntimeError("SMTP fixture accepted an invalid password")
                smtp.login("pilot", password)
            ops.run("run", "--rm", "--no-deps", "app", "--bootstrap-admin", "/run/config/bootstrap.json")
            STAGE = "activation and secure browser session"
            activate("admin@pilot.example")
            request("/api/v1/auth/web/login", {"email": "admin@pilot.example", "password": password}, csrf=True, expected=204)
            # Cookie attributes are case-insensitive; CookieJar preserves the server's spelling.
            assert any(c.name == "HomeOffice.Session" and c.secure and
                       (c.has_nonstandard_attr("httponly") or c.has_nonstandard_attr("HttpOnly")) for c in jar), "Secure HttpOnly session cookie missing"
            key_files = list((private / "keys").glob("key-*.xml"))
            assert key_files and all("encryptedSecret" in p.read_text() for p in key_files), "Runtime key ring is not encrypted"
            admin = request("/api/v1/me")
            STAGE = "synthetic account activation and reporting relationship"
            for name, manager in (("manager", True), ("employee", False)):
                request("/api/v1/admin/members", {"email": name + "@pilot.example", "displayName": "Synthetic " + name,
                        "isEmployee": True, "isManager": manager, "isAccountAdministrator": False}, csrf=True, expected=204)
                activate(name + "@pilot.example")
            employee_tokens = request("/api/v1/auth/token/login", {"email": "employee@pilot.example", "password": password})
            manager_tokens = request("/api/v1/auth/token/login", {"email": "manager@pilot.example", "password": password})
            employee = request("/api/v1/me", token=employee_tokens["accessToken"])
            manager = request("/api/v1/me", token=manager_tokens["accessToken"])
            request(f'/api/v1/admin/members/{employee["memberId"]}/manager', {"managerId": manager["memberId"]}, csrf=True, expected=204, method="PUT")
            STAGE = "application planning and durable worker"
            base = '/api/v1/planning/' + employee["memberId"]
            draft = request(base + "/requests", {"expectedCalendarVersion": 0, "expectedRequestVersion": None, "parentRevisionId": None,
                "note": "Synthetic production recovery", "days": [{"localDate": planned_date, "location": "RemotePortugal", "availability": "Working"}]},
                token=employee_tokens["accessToken"], method="POST")
            request(base + '/requests/' + draft["contextId"] + '/submit', {"expectedCalendarVersion": draft["calendarVersion"], "expectedRequestVersion": draft["version"]},
                    token=employee_tokens["accessToken"], method="POST")
            for _ in range(30):
                if int(ops.sql('SELECT count(*) FROM "InboxNotification"')) > 0:
                    break
                time.sleep(1)
            else:
                raise RuntimeError("Durable worker did not materialize the notification")
            ops.sql(Path(__file__).with_name("queues.sql").read_text())
            STAGE = "restart preserves data and protected sessions"
            ops.run("restart", "app", "database")
            ready()
            assert request("/api/v1/me")["memberId"] == admin["memberId"]
            assert request("/api/v1/me", token=employee_tokens["accessToken"])["memberId"] == employee["memberId"]
            STAGE = "snapshot and new database restore"
            backup = folder / "backup"
            ops.snapshot(backup)
            STAGE = "encrypted restic backup and recovery"
            write("restic-password", secrets.token_hex(32))
            encrypted = folder / "encrypted"
            recovered = folder / "recovered"
            encrypted.mkdir()
            recovered.mkdir()
            def restic(*arguments):
                return command(["docker", "run", "--rm", "--network", "none",
                    "-e", "RESTIC_PASSWORD_FILE=/run/password", "-e", "RESTIC_REPOSITORY=/repository",
                    "-v", str(private / "restic-password") + ":/run/password:ro",
                    "-v", str(encrypted) + ":/repository", "-v", str(backup) + ":/source:ro",
                    "-v", str(recovered) + ":/restore", "restic/restic:0.19.1", *arguments])
            restic("init")
            restic("backup", "/source", "--tag", "isolated-validation")
            restic("check")
            restic("restore", "latest", "--target", "/restore")
            backup = recovered / "source"
            STAGE = "new database restored from encrypted backup"
            restored = "ho012_restore_" + uuid.uuid4().hex[:12]
            restore_started = time.monotonic()
            ops.restore(backup, restored)
            # Also exercise the refusal to overwrite an existing restore database.
            try:
                ops.restore(backup, restored)
            except RuntimeError:
                pass
            else:
                raise RuntimeError("Restore overwrote an existing database")
            ops.run("stop", "app")
            config["ConnectionStrings"]["Database"] = config["ConnectionStrings"]["Database"].replace("Database=homeoffice;", "Database=" + restored + ";")
            write("application.json", json.dumps(config))
            shutil.rmtree(private / "keys")  # This harness owns this new temporary directory only.
            shutil.copytree(backup / "keys", private / "keys")
            (private / "protection.pfx").unlink()
            shutil.copyfile(backup / "protection.pfx", private / "protection.pfx")
            os.chown(private / "protection.pfx", 1654, 1654)
            (private / "protection.pfx").chmod(0o600)
            for path in [private / "keys", *(private / "keys").rglob("*")]:
                os.chown(path, 1654, 1654)
            ops.run("up", "-d", "--force-recreate", "app")
            ready()
            assert request("/api/v1/me")["memberId"] == admin["memberId"]
            refreshed = request("/api/v1/auth/token/refresh", {"refreshToken": employee_tokens["refreshToken"]})
            assert request("/api/v1/me", token=refreshed["accessToken"])["memberId"] == employee["memberId"]
            recovered_request = request(base + '/requests/' + draft["contextId"], token=refreshed["accessToken"])
            assert recovered_request["note"] == "Synthetic production recovery"
            assert recovered_request["days"][0]["localDate"] == planned_date
            STAGE = "recovery email after restoration"
            request("/api/v1/auth/recovery/request", {"email": "employee@pilot.example"}, expected=202)
            request("/api/v1/auth/recovery/complete", {"email": "employee@pilot.example", "code": email_code(), "password": password + "New"}, expected=204)
            STAGE = "subsequent backups follow the selected restored database"
            env_file.write_text(env_file.read_text() + f"HO_DATABASE_NAME={restored}\n")
            recovered_ops = Operations(env_file, ("-f", str(override), "-f", str(ports)))
            # A disposable marker distinguishes this DB from the pre-recovery source.
            recovered_ops.sql('CREATE TABLE "HO012RecoveryMarker" (id integer PRIMARY KEY); INSERT INTO "HO012RecoveryMarker" VALUES (1);')
            next_backup = recovered_ops.snapshot(folder / "backup-after-recovery")
            assert next_backup["database"] == restored
            assert next_backup["counts"] == recovered_ops.counts(restored)
            recovered_ops.restore(folder / "backup-after-recovery", "ho012_restore_second_" + uuid.uuid4().hex[:8])
            evidence = {"production_container": "passed", "smtp": "isolated STARTTLS/authenticated sink; no external delivery", "push": "disabled; not live FCM",
                        "restart": "passed", "restic_encrypted_roundtrip": "passed", "restore_data_cookie_refresh": "passed", "existing_restore_refused": True,
                        "restore_seconds": round(time.monotonic() - restore_started, 1), "total_seconds": round(time.monotonic() - started, 1)}
            (ROOT / "ho012-production-evidence.json").write_text(json.dumps(evidence, indent=2) + "\n")
            print(json.dumps(evidence))
        except Exception:
            # Before any account/token exists, expose bounded, redacted startup diagnostics only.
            # Later authentication/calendar stages never print application logs or responses.
            if STAGE == "isolated database initialization and migrations":
                output = (private / "operation-error.log").read_text(errors="replace") if (private / "operation-error.log").exists() else ""
                output += ops.run("logs", "--no-color", "--tail", "15", "database", "mailpit").decode(errors="replace")
                for value in (password, (private / "postgres-password").read_text(), str(private)):
                    output = output.replace(value, "[redacted]")
                print(output[-5000:])
            raise
        finally:
            ops.run("down", "--volumes", "--remove-orphans")
            command(["docker", "image", "rm", image])


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        print("HO-012 isolated acceptance failed at " + STAGE + ": " + type(error).__name__ + ". No private payload logged.", flush=True)
        if isinstance(error, (RuntimeError, AssertionError)):
            print(str(error))  # These exceptions above contain only controlled stage/status text.
        raise SystemExit(1) from None
