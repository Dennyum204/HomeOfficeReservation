# Prompt HO-000 recebido

Fornecido pelo responsável em 2026-09-08. Este ficheiro conserva o pedido desta entrega; não foi fornecido um novo guia completo com prompts para os 24 trabalhos. Os exemplos do starter continuam em [CODEX_TASKS.md](CODEX_TASKS.md).

---

You are setting up HomeOfficeReservation for incremental development. Complete HO-000 only.

Repository: https://github.com/Dennyum204/HomeOfficeReservation.git

Input: the extracted HomeOfficeReservation architecture starter, or the attached starter ZIP. Read the files; do not rely on earlier chat history.

The agreed stack is ASP.NET Core/.NET 10, PostgreSQL with EF Core, React/TypeScript Web, and Flutter Android/iOS. Outlook synchronization is required in V1.

## Prompt HO-000 — Repository, documentation and GitHub tracking

1. Inspect the workspace, Git status, remote, GitHub access, and existing repository contents. Read AGENTS.md, README.md, STATUS.md, docs/PRODUCT.md, docs/ARCHITECTURE.md, docs/DEVELOPMENT.md, and docs/backlog.json. Preserve existing work.
2. If GitHub still has no commits, create and push one empty bootstrap commit on main to establish a PR base. Otherwise use the existing history. Create docs/ho-000-project-foundation from the current base. Do not import the bundled Git history over the real repository.
3. Integrate the starter files at the repository root. Create or improve README.md and .gitignore for .NET, React/Node, Flutter, local IDE files, build outputs, secrets, and signing keys. Keep lockfiles, migrations, and safe configuration examples tracked. Document the real setup state; do not invent build commands for projects that do not exist yet.
4. Update stale documentation to reference this repository and the confirmed backend decision. Preserve unresolved Microsoft account and hosting assumptions. If the new prompt guide is supplied, save it as docs/CODEX_PROMPTS.md.
5. Create or reuse one GitHub issue for each of the 24 HO work items in docs/backlog.json, including future releases. Use stable HO IDs, acceptance criteria, dependencies, and release/area labels. Create release milestones where supported. Store actual issue URLs in the JSON. Search before creating to avoid duplicates. Issues, labels, and milestones provide the required tracking; a Project board is optional.
6. Add this standing GitHub workflow to AGENTS.md: Codex owns branches, commits, issue updates, and PR preparation; each task checks verified merge evidence and reconciles stale backlog statuses before checking dependencies; every change uses a scoped branch; PRs link real issues; completed implementation leaves an undrafted PR with relevant CI green and no merge conflicts; incomplete work remains clearly marked. I review and merge. Do not merge or enable auto-merge.
7. Run the existing documentation validator and regenerate derived documents when needed. Open the PR, record its real URL, push the final updates, and check CI on its latest commit. Configure the documented main-branch protections where permissions permit, using actual check names. Avoid requiring an independent approving reviewer if I am the sole maintainer.

You are authorized to create branches, commits, issues, labels, milestones, and PRs in this repository. Proceed without repeated confirmation for these actions. Use synthetic examples and keep secrets or private calendar data out of this public repository. Do not change repository visibility.

Finish with the branch, PR link, tracking links, checks actually run, any concrete blocker, and the next task with its Astra reasoning setting. The application implementation starts in later tasks.
