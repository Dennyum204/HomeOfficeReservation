#!/usr/bin/env python3
"""Generate from ASP.NET metadata, then compare or write only generator-owned files."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile
import urllib.request

ROOT = Path(__file__).resolve().parents[1]


def run(*args):
    subprocess.run(args, cwd=ROOT, check=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Fail without modifying tracked files on drift")
    args = parser.parse_args()
    pin = json.loads((ROOT / "contracts/generator.json").read_text())
    cache = Path(os.environ.get("HO_TOOLS_CACHE", str(Path.home() / ".cache/homeoffice-tools")))
    cache.mkdir(parents=True, exist_ok=True)
    jar = cache / f"openapi-generator-cli-{pin['version']}.jar"
    if not jar.exists():
        urllib.request.urlretrieve(
            f"https://repo.maven.apache.org/maven2/org/openapitools/openapi-generator-cli/{pin['version']}/{jar.name}", jar)
    if hashlib.sha256(jar.read_bytes()).hexdigest() != pin["sha256"]:
        raise SystemExit("Generator checksum mismatch; remove cached JAR and investigate.")
    api = ROOT / "apps/api/src/HomeOffice.Api"
    run("dotnet", "build", str(api), "-c", "Release", "--no-restore", "-t:Rebuild")
    # Stable serialization only; the schema itself comes entirely from backend metadata.
    schema = json.loads((api / "obj/homeoffice.json").read_text(encoding="utf-8-sig"))
    expected = {Path("contracts/openapi.json"): json.dumps(schema, indent=2, sort_keys=True) + "\n"}
    with tempfile.TemporaryDirectory(prefix="homeoffice-contracts-") as folder:
        temp = Path(folder)
        spec = temp / "openapi.json"
        spec.write_text(expected[Path("contracts/openapi.json")], encoding="utf-8")
        for language, target in [("typescript-fetch", "typescript"), ("dart", "dart")]:
            out = temp / target
            run("java", "-jar", str(jar), "generate", "-i", str(spec), "-g", language,
                "-o", str(out), "-c", str(ROOT / f"contracts/{target}-config.json"),
                "-t", str(ROOT / f"contracts/templates/{target}"),
                "--global-property", "apiTests=false,modelTests=false,apiDocs=false,modelDocs=false")
            for source in out.rglob("*"):
                if not source.is_file():
                    continue
                rel = source.relative_to(out)
                selected = (target == "typescript" and source.suffix == ".ts") or (
                    target == "dart" and (rel.parts[0] == "lib" or str(rel) in {"pubspec.yaml", "analysis_options.yaml"}))
                if selected:
                    expected[Path("contracts") / target / rel] = "\n".join(
                        line.rstrip() for line in source.read_text(encoding="utf-8").splitlines()).rstrip() + "\n"
    owned = {Path("contracts/openapi.json")}
    for folder in [ROOT / "contracts/typescript", ROOT / "contracts/dart/lib"]:
        if folder.exists():
            owned.update(p.relative_to(ROOT) for p in folder.rglob("*") if p.is_file())
    owned.update(Path("contracts/dart") / p for p in ["pubspec.yaml", "analysis_options.yaml"] if (ROOT / "contracts/dart" / p).exists())
    changed = sorted(str(p) for p, content in expected.items()
                     if not (ROOT / p).exists() or (ROOT / p).read_text(encoding="utf-8") != content)
    obsolete = owned - expected.keys()
    if args.check:
        if changed or obsolete:
            raise SystemExit("Contract drift; run scripts/generate_contracts.py:\n" + "\n".join(changed + sorted(map(str, obsolete))))
        print(f"Contracts match ({len(expected)} generated files).")
        return
    for relative in obsolete:
        path = (ROOT / relative).resolve()
        if not path.is_relative_to((ROOT / "contracts").resolve()):
            raise SystemExit("Refusing deletion outside contracts")
        path.unlink()
    for relative, content in expected.items():
        path = ROOT / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8", newline="\n")
    print(f"Wrote {len(expected)} generated files. Do not edit them manually.")


if __name__ == "__main__":
    main()
