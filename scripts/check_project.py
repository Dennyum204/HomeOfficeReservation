#!/usr/bin/env python3
"""Validate the planning inventory and render its two derived Markdown views."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from urllib.parse import unquote, urlparse


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "docs" / "backlog.json"
STATUSES = {"planned", "ready", "in_progress", "review", "done", "blocked", "parked", "cancelled"}
STATUS_NAMES = {
    "planned": "Planeado", "ready": "Pronto", "in_progress": "Em curso",
    "review": "Em revisão", "done": "Concluído", "blocked": "Bloqueado",
    "parked": "Em espera", "cancelled": "Cancelado",
}
REQUIRED_FILES = (
    "README.md", "PLANO.md", "AGENTS.md", "STATUS.md", "CHANGELOG.md",
    "docs/PRODUCT.md", "docs/ARCHITECTURE.md", "docs/DOMAIN.md",
    "docs/OUTLOOK.md", "docs/UX.md", "docs/DEVELOPMENT.md", "docs/QUALITY.md",
    "docs/CODEX_TASKS.md", "docs/SOURCES.md", "docs/adr/README.md",
    "apps/api/AGENTS.md", "apps/web/AGENTS.md", "apps/mobile/AGENTS.md",
    "contracts/README.md", "infra/README.md", ".github/pull_request_template.md",
    ".github/workflows/project-checks.yml",
)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def index_by_id(rows: list[dict], name: str) -> dict[str, dict]:
    require(isinstance(rows, list) and bool(rows), f"{name}: lista vazia ou inválida")
    result = {}
    for row in rows:
        require(isinstance(row, dict), f"{name}: entrada inválida")
        key = row.get("id")
        require(isinstance(key, str) and bool(key), f"{name}: ID em falta")
        require(key not in result, f"{name}: ID duplicado {key}")
        require(bool(row.get("title")), f"{key}: título em falta")
        require(row.get("status") in STATUSES, f"{key}: estado inválido")
        if row["status"] in {"blocked", "parked", "cancelled"}:
            require(bool(row.get("reason")), f"{key}: estado exige motivo")
        result[key] = row
    return result


def validate(data: dict) -> None:
    require(data.get("schema_version") == 1, "schema_version não suportada")
    releases = index_by_id(data["releases"], "releases")
    features = index_by_id(data["features"], "features")
    work = index_by_id(data["work_items"], "work_items")
    for release in releases.values():
        for field in ("timing", "gate", "review_trigger"):
            require(bool(release.get(field)), f"{release['id']}: {field} em falta")
    coverage = {key: [] for key in features}
    for key, feature in features.items():
        require(re.fullmatch(r"FEAT-\d{3}", key) is not None, f"ID de feature inválido: {key}")
        require(feature.get("release") in releases, f"{key}: release desconhecida")
    for key, item in work.items():
        require(re.fullmatch(r"HO-\d{3}[A-Z]?", key) is not None, f"ID de tarefa inválido: {key}")
        require(item.get("release") in releases, f"{key}: release desconhecida")
        require(bool(item.get("area")) and bool(item.get("owner")), f"{key}: área/responsável em falta")
        require(isinstance(item.get("acceptance"), list) and bool(item["acceptance"]), f"{key}: sem aceitação")
        require(all(isinstance(x, str) and x.strip() for x in item["acceptance"]), f"{key}: critério vazio")
        require(isinstance(item.get("depends_on"), list), f"{key}: dependências inválidas")
        require(len(item["depends_on"]) == len(set(item["depends_on"])), f"{key}: dependência repetida")
        for dep in item["depends_on"]:
            require(dep in work and dep != key, f"{key}: dependência inválida {dep}")
        if item["status"] == "done":
            require(all(work[d]["status"] == "done" for d in item["depends_on"]), f"{key}: concluída com dependências abertas")
            require(bool(item.get("pr_urls")), f"{key}: falta evidência de PR integrado")
        require(isinstance(item.get("features"), list), f"{key}: features inválidas")
        for feature_id in item["features"]:
            require(feature_id in features, f"{key}: feature desconhecida {feature_id}")
            require(features[feature_id]["release"] == item["release"], f"{key}/{feature_id}: releases divergentes")
            if item["status"] != "cancelled":
                coverage[feature_id].append(key)
        urls = ([item["issue_url"]] if item.get("issue_url") else []) + item.get("pr_urls", [])
        for url in urls:
            parsed = urlparse(url)
            require(parsed.scheme == "https" and bool(parsed.netloc), f"{key}: URL remoto inválido")
    for key, ids in coverage.items():
        if features[key]["status"] != "cancelled":
            require(bool(ids), f"{key}: funcionalidade sem tarefa")

    visiting, visited = set(), set()

    def visit(key: str) -> None:
        require(key not in visiting, f"Ciclo de dependências em {key}")
        if key in visited:
            return
        visiting.add(key)
        for dep in work[key]["depends_on"]:
            visit(dep)
        visiting.remove(key)
        visited.add(key)

    for key in work:
        visit(key)
    for filename in REQUIRED_FILES:
        require((ROOT / filename).is_file(), f"Ficheiro obrigatório em falta: {filename}")


def cell(value: object) -> str:
    return str(value).replace("|", "\\|").replace("\n", " ")


def render_roadmap(data: dict) -> str:
    lines = [
        "# Roadmap", "", "Gerado a partir de [docs/backlog.json](docs/backlog.json). Não editar diretamente.",
        "", f"Atualizado: {data['updated_at']}.", "", data["planning_note"], "",
        "Cada funcionalidade tem uma release e pelo menos uma tarefa. Mudanças de âmbito/versão exigem um PR com motivo; ideias canceladas mantêm o ID e o histórico.",
        "", "A sequência detalhada e os critérios estão em [docs/BACKLOG.md](docs/BACKLOG.md).", "",
    ]
    for release in data["releases"]:
        lines.extend([
            f"## {release['id']} — {release['title']}", "",
            f"**Quando:** {release['timing']}", "",
            f"**Gate:** {release['gate']}", "",
            f"**Reavaliar:** {release['review_trigger']}", "",
            "| ID | Funcionalidade | Tarefas |", "|---|---|---|",
        ])
        for feature in data["features"]:
            if feature["release"] != release["id"]:
                continue
            ids = ", ".join(item["id"] for item in data["work_items"] if feature["id"] in item["features"])
            lines.append(f"| {feature['id']} | {cell(feature['title'])} | {ids} |")
        lines.append("")
    lines.extend([
        "## Regra de acompanhamento", "",
        "Rever tarefas abertas no fecho de cada PR, o plano da release semanalmente durante o desenvolvimento e as funcionalidades futuras no marco indicado. Estes são rituais do projeto; não foi criado um lembrete automático fora da aplicação.",
        "", "Uma data de lançamento só passa a compromisso quando acessos, capacidade e âmbito forem confirmados. Defeitos críticos precedem novas funcionalidades.", "",
    ])
    return "\n".join(lines)


def render_backlog(data: dict) -> str:
    lines = [
        "# Backlog de execução", "", "Gerado de [backlog.json](backlog.json). Não editar diretamente.",
        "", "Os IDs HO não são números de issues/PRs. URLs remotos só são preenchidos após criação real.",
        "", "Cada linha é um pacote de trabalho delimitado. Pode ser dividido em novos IDs/PRs antes de implementar, mantendo dependências e critérios; não implica um PR gigante por pacote.",
        "", "| ID | Tarefa | Release | Área | Estado | Depende de |", "|---|---|---|---|---|---|",
    ]
    for item in data["work_items"]:
        dependencies = ", ".join(item["depends_on"]) or "—"
        lines.append(f"| {item['id']} | {cell(item['title'])} | {item['release']} | {item['area']} | {STATUS_NAMES[item['status']]} | {dependencies} |")
    lines.append("")
    for item in data["work_items"]:
        lines.extend([
            f"## {item['id']} — {item['title']}", "",
            f"Release: {item['release']} · Área: {item['area']} · Estado: {STATUS_NAMES[item['status']]}", "",
            f"Responsável pelo trabalho: {item['owner']}.", "",
            "Dependências: " + (", ".join(item["depends_on"]) or "Nenhuma.") + "\n",
            "Funcionalidades: " + (", ".join(item["features"]) or "Preparação/fundação da release.") + "\n",
            "Critérios de aceitação:", "",
        ])
        lines.extend(f"- {criterion}" for criterion in item["acceptance"])
        lines.extend(["", "Issue: " + (item.get("issue_url") or "Ainda não criada."), ""])
        if item.get("pr_urls"):
            lines.extend(f"PR: {url}" for url in item["pr_urls"])
        else:
            lines.append("PR: ainda não criado.")
        if item.get("reason"):
            lines.extend(["", "Motivo: " + item["reason"]])
        lines.append("")
    return "\n".join(lines)


def check_local_links() -> None:
    for path in ROOT.rglob("*.md"):
        if any(part in {".git", "node_modules", "build", "dist", ".dart_tool"} for part in path.parts):
            continue
        contents = re.sub(r"```.*?```", "", path.read_text(encoding="utf-8"), flags=re.S)
        for target in re.findall(r"\[[^\]]+\]\(([^)]+)\)", contents):
            target = target.split("#", 1)[0].strip()
            if not target or ":" in target or target.startswith("/"):
                continue
            destination = path.parent / unquote(target)
            require(destination.exists(), f"{path.relative_to(ROOT)}: ligação local inexistente {target}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true", help="Regenerate derived roadmap and backlog")
    args = parser.parse_args()
    try:
        data = json.loads(SOURCE.read_text(encoding="utf-8"))
        validate(data)
        expected = {
            ROOT / "ROADMAP.md": render_roadmap(data),
            ROOT / "docs" / "BACKLOG.md": render_backlog(data),
        }
        for path, content in expected.items():
            if args.write:
                path.write_text(content, encoding="utf-8")
            else:
                require(path.is_file(), f"Falta {path.relative_to(ROOT)}; executar --write")
                require(path.read_text(encoding="utf-8") == content, f"{path.relative_to(ROOT)} desatualizado; executar --write")
        check_local_links()
    except (OSError, ValueError, KeyError, TypeError) as error:
        print(f"ERRO: {error}", file=sys.stderr)
        return 1
    print(f"OK: {len(data['features'])} funcionalidades, {len(data['work_items'])} tarefas, dependências, cobertura, documentos e ligações locais.")
    print("Validação documental; não compila nem testa a aplicação.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
