## Problema e resultado

> Notas históricas do PR #25 integrado. O âmbito Outlook obrigatório foi posteriormente substituído em HO-001/[ADR-004](../adr/ADR-004-independent-core.md); estas notas preservam a entrega original.

HomeOfficeReservation precisa de uma base versionada e tracking verificável para desenvolvimento incremental. HO-000 integra os ficheiros do starter na raiz do repositório real e confirma ASP.NET Core/.NET 10, PostgreSQL/EF Core, React/TypeScript e Flutter Android/iOS. Outlook permanece obrigatório na V1; conta Microsoft e alojamento continuam por validar.

Closes #1 — [HO-000](https://github.com/Dennyum204/HomeOfficeReservation/issues/1).

## Âmbito

- Documentação de produto, arquitetura, domínio, Outlook, qualidade e continuidade; instruções por área e templates GitHub.
- README com estado real e `.gitignore` para outputs, IDEs, configuração local, segredos e assinatura, preservando lockfiles, migrações e exemplos seguros.
- Backlog de 24 trabalhos e 22 funcionalidades, com aceitação/dependências, 24 issues reais, 12 labels de release/área e milestones v1.0/v1.1/v1.2/v2.0.
- Codex prepara branches, commits, issues e PRs; cada tarefa verifica merge/CI e reconcilia estados antes das dependências. Fernando revê e faz merge; sem auto-merge.
- Aplicação ainda não implementada. Sem alterações de API, migrações, deployment ou acesso a calendários.

## Validação e continuidade

- `python scripts/check_project.py --write` e `python scripts/check_project.py`: passam, 22 funcionalidades e 24 tarefas; validador original sem dependências externas.
- `git diff --check`: passa; regras de ignore verificadas para outputs/segredos e preservação de lockfiles, migrações e exemplos.
- GitHub API: 24 issues únicas verificadas contra IDs, títulos, aceitação, dependências ligadas, labels, milestones e URLs do JSON. Quatro milestones sem datas artificiais.
- `project-docs` passou no [primeiro run](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34263607655). O [PR #25](https://github.com/Dennyum204/HomeOfficeReservation/pull/25) regista a evidência do último SHA; retirar draft apenas depois de verificar CI final verde e ausência de conflitos.
- Proteções de `main` aplicadas e relidas: PR obrigatório, check `project-docs` associado ao GitHub Actions, base atualizada, conversas resolvidas, histórico linear, enforcement para admins e zero aprovações independentes. Force-push/eliminação de main bloqueados; squash apenas; auto-merge desativado.
- Bootstrap vazio publicado em `main`; branch e commit preexistente `d17b150` preservados. Autenticação Git/gh resolvida; visibilidade pública preservada.
- HO-000 em `review` até ao merge humano. Próxima tarefa depois do merge: HO-001, Astra reasoning `high`; não iniciada nesta entrega.

## Impacto e recuperação

Alteração documental e de governação; não há dados, contratos implementados ou infraestrutura de aplicação para migrar. A reversão faz-se por PR; issues/milestones/proteções são estado externo e exigem reconciliação explícita, sem eliminar histórico.
