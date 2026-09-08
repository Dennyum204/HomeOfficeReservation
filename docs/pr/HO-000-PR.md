## Problema e resultado

HomeOfficeReservation precisa de uma base versionada e tracking verificável para desenvolvimento incremental. HO-000 integra os ficheiros do starter na raiz do repositório real e confirma ASP.NET Core/.NET 10, PostgreSQL/EF Core, React/TypeScript e Flutter Android/iOS. Outlook permanece obrigatório na V1; conta Microsoft e alojamento continuam por validar.

Closes #1 — [HO-000](https://github.com/Dennyum204/HomeOfficeReservation/issues/1).

## Âmbito

- Documentação de produto, arquitetura, domínio, Outlook, qualidade e continuidade; instruções por área e templates GitHub.
- README com estado real e `.gitignore` para outputs, IDEs, configuração local, segredos e assinatura, preservando lockfiles, migrações e exemplos seguros.
- Backlog de 24 trabalhos e 22 funcionalidades, com aceitação/dependências, 24 issues reais, 12 labels de release/área e milestones v1.0/v1.1/v1.2/v2.0.
- Codex prepara branches, commits, issues e PRs; cada tarefa verifica merge/CI e reconcilia estados antes das dependências. Fernando revê e faz merge; sem auto-merge.
- Aplicação ainda não implementada. Sem alterações de API, migrações, deployment ou acesso a calendários.

## Validação e continuidade

- Validador original: `scripts/check_project.py --write` e `scripts/check_project.py` passam, sem dependências Python externas.
- Workflow documental: `project-docs`. Resultados remotos e proteções só serão registados depois de verificados no GitHub.
- Tracking remoto criado e autenticação Git/gh resolvida. PR, CI e proteções em verificação; ver [STATUS.md](../../STATUS.md).
- Próxima tarefa depois do merge humano: HO-001, Astra reasoning `high`.

## Impacto e recuperação

Alteração documental e de governação; não há dados, contratos implementados ou infraestrutura de aplicação para migrar. A reversão faz-se por PR; issues/milestones/proteções são estado externo e exigem reconciliação explícita, sem eliminar histórico.
