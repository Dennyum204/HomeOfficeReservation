#!/usr/bin/env python3
"""Explicit local/SSH-host operations. Never purchases, deploys remotely or prints secrets."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
from datetime import datetime, timezone

ROOT = Path(__file__).resolve().parents[2]
COMPOSE = Path(__file__).with_name("compose.yaml")


def private_path(value):
    path = Path(value).resolve()
    if not Path(value).is_absolute() or path.is_relative_to(ROOT):
        raise ValueError("Use an absolute private path outside the repository.")
    return path


class Operations:
    def __init__(self, env_file, extra=()):
        self.env_file = private_path(env_file)
        self.values = dict(line.split("=", 1) for line in self.env_file.read_text().splitlines()
                           if line.strip() and not line.startswith("#"))
        self.private = private_path(self.values["HO_PRIVATE_DIR"])
        self.command = ["docker", "compose", "--env-file", str(self.env_file), "-f", str(COMPOSE), *extra]

    def run(self, *args, input=None, timeout=240):
        result = subprocess.run([*self.command, *args], input=input, capture_output=True, timeout=timeout)
        if result.returncode:
            # Docker and PostgreSQL errors can echo configuration or data. Keep operator output private.
            (self.private / "operation-error.log").write_bytes(result.stdout + result.stderr)
            codes = sorted(set(re.findall(r"\b[A-Za-z.]+Exception\b", (result.stdout + result.stderr).decode(errors="replace"))))
            raise RuntimeError("Operation failed (exit " + str(result.returncode) + ", exception types " + ",".join(codes) + "); inspect private operation-error.log.")
        return result.stdout

    def sql(self, query, database="homeoffice"):
        return self.run("exec", "-T", "database", "psql", "-X", "-qAt", "-v", "ON_ERROR_STOP=1",
                        "-U", "postgres", "-d", database, input=query.encode()).decode().strip()

    def counts(self, database="homeoffice"):
        tables = self.sql("SELECT tablename FROM pg_tables WHERE schemaname='public' ORDER BY tablename;", database).splitlines()
        return {table: int(self.sql('SELECT count(*) FROM "' + table.replace('"', '""') + '";', database)) for table in tables}

    def snapshot(self, destination):
        target = private_path(destination)
        target.mkdir(mode=0o700, parents=True, exist_ok=False)
        # A brief maintenance window gives the DB/key ring a consistent recovery point.
        self.run("stop", "app")
        try:
            dump = self.run("exec", "-T", "database", "pg_dump", "-U", "postgres", "-d", "homeoffice", "-Fc", "--no-owner")
            (target / "database.dump").write_bytes(dump)
            shutil.copytree(self.private / "keys", target / "keys")
            shutil.copyfile(self.private / "protection.pfx", target / "protection.pfx")
            manifest = {"utc": datetime.now(timezone.utc).isoformat(), "environment": self.values["HO_ENVIRONMENT"],
                        "image": self.values["HO_IMAGE"], "counts": self.counts()}
            manifest["sha256"] = {str(p.relative_to(target)): hashlib.sha256(p.read_bytes()).hexdigest()
                                  for p in target.rglob("*") if p.is_file()}
            (target / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
            if os.name != "nt":
                for p in target.rglob("*"):
                    p.chmod(0o700 if p.is_dir() else 0o600)
        finally:
            self.run("start", "app")
        return manifest

    def restore(self, source, database):
        source = private_path(source)
        # CREATE refuses existing targets. No --clean, DROP, overwrite or working DB destination.
        if not re.fullmatch(r"ho012_restore_[a-z0-9_]{1,32}", database):
            raise ValueError("Restore target must be a new ho012_restore_<suffix> database.")
        manifest = json.loads((source / "manifest.json").read_text())
        for name, checksum in manifest["sha256"].items():
            path = (source / name).resolve()
            if not path.is_relative_to(source) or hashlib.sha256(path.read_bytes()).hexdigest() != checksum:
                raise ValueError("Backup integrity verification failed.")
        self.sql(f'CREATE DATABASE "{database}" OWNER homeoffice;', "postgres")
        self.run("exec", "-T", "database", "pg_restore", "-U", "postgres", "--role=homeoffice", "-d", database,
                 "--exit-on-error", "--no-owner", "--no-privileges", input=(source / "database.dump").read_bytes())
        if self.counts(database) != manifest["counts"]:
            raise RuntimeError("Restored application table counts differ; keep target isolated for diagnosis.")
        return manifest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--env-file", required=True)
    sub = parser.add_subparsers(dest="operation", required=True)
    sub.add_parser("migrate")
    sub.add_parser("queues")
    sub.add_parser("snapshot").add_argument("destination")
    restore = sub.add_parser("restore")
    restore.add_argument("source")
    restore.add_argument("database")
    args = parser.parse_args()
    ops = Operations(args.env_file)
    if args.operation == "migrate":
        ops.run("run", "--rm", "--no-deps", "app", "--migrate")
        print("Explicit migrations applied; no accounts seeded.")
    elif args.operation == "snapshot":
        ops.snapshot(args.destination)
        print("Private snapshot prepared. Off-host upload and restore verification remain separate operations.")
    elif args.operation == "restore":
        ops.restore(args.source, args.database)
        print("Separate database restored; application table counts match. Perform the authenticated recovery check before use.")
    else:
        print(ops.sql(Path(__file__).with_name("queues.sql").read_text()))


if __name__ == "__main__":
    main()
