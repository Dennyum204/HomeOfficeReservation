# HomeOfficeReservation

Calendário próprio para planear trabalho remoto em Portugal e presencial na Suíça, com pedidos, aprovações, presenças obrigatórias, tarefas e notificações. **Core V1 completo sem conta Microsoft ou Outlook.**

Stack: ASP.NET Core/.NET 10, EF Core/PostgreSQL, React/TypeScript Web e Flutter Android/iOS. Autenticação própria com ASP.NET Core Identity: cookie na Web e tokens opacos do framework no mobile. Web/mobile partilham backend e calendário autoritativo. [ADR-004](docs/adr/ADR-004-independent-core.md) regista a decisão.

**Estado: documentação e desenho; aplicação ainda não implementada.** HO-000 integrado pelo [PR #25](https://github.com/Dennyum204/HomeOfficeReservation/pull/25). HO-001 reformula o produto no [PR #27](https://github.com/Dennyum204/HomeOfficeReservation/pull/27). Próximo trabalho de implementação: HO-002 scaffolding, após revisão/merge humano. [STATUS.md](STATUS.md) contém evidência e continuidade.

## Outlook opcional

Ligação em Definições, num marco independente após o core. HO-008 publica unidirecionalmente dias explícitos confirmados, `showAs=free` por defeito, apenas eventos próprios e sem convites. HO-009 preserva importação de disponibilidade, delta, webhooks e reconciliação de alterações externas para um marco posterior. Nenhum deles bloqueia login, calendário ou lançamento core.

Estudo/probe Microsoft preservados como referência histórica opcional. Onboarding parado e validação Graph real **adiada, não aprovada**. Não são necessárias credenciais Microsoft para desenvolver este repositório.

## Começar

1. Ler [AGENTS.md](AGENTS.md), [STATUS.md](STATUS.md) e [PLANO.md](PLANO.md).
2. Consultar [ROADMAP.md](ROADMAP.md), [backlog gerado](docs/BACKLOG.md) e [DEVELOPMENT.md](docs/DEVELOPMENT.md).
3. Seguir o item selecionado; não iniciar toda a aplicação a partir deste documento. [GIT_IMPORT.md](docs/GIT_IMPORT.md) preserva instruções históricas de importação.

## Documentação

| Documento | Responsabilidade |
|---|---|
| [Produto](docs/PRODUCT.md) | Core V1 e aceitação sem Microsoft |
| [Arquitetura](docs/ARCHITECTURE.md) / [ADRs](docs/adr/README.md) | Stack, Identity e fronteiras |
| [Domínio](docs/DOMAIN.md) / [UX](docs/UX.md) | Regras, calendário e clientes |
| [Qualidade](docs/QUALITY.md) | Gates core e gates opcionais separados |
| [Outlook](docs/OUTLOOK.md) | Publicação opcional e sincronização posterior |
| [Estudo histórico](docs/HO-001-MICROSOFT-OUTLOOK-STUDY.md) | Fontes/pesquisa Microsoft; Graph real adiado |
| [Tarefas Codex](docs/CODEX_TASKS.md) / [Fontes](docs/SOURCES.md) | Continuidade e referências |

## Checks disponíveis

Python 3.10+ sem pacotes externos para a validação normal:

```bash
python3 scripts/check_project.py
python3 scripts/check_project.py --write
```

No Windows, usar o executável Python instalado com os mesmos argumentos. `--write` regenera ROADMAP.md e docs/BACKLOG.md a partir de docs/backlog.json. O validador verifica IDs, dependências, cobertura, documentos e ligações locais; não compila a aplicação.

CI normal: `project-docs`. O workflow permite executar `outlook-probe-tests` apenas manualmente, com `run_outlook_reference=true`; são testes sintéticos opcionais, sem chamadas Microsoft. O [guia do probe](scripts/outlook_probe/README.md) não é setup obrigatório. HO-002 acrescentará comandos reais de build/test e versões/lockfiles para projetos que ainda não existem.

## Estrutura e tracking

`apps/api/`, `apps/web/`, `apps/mobile/`, `contracts/` e `infra/` contêm instruções de trabalho futuro. Nenhum projeto compilável, migração ou deployment criado neste PR.

[24 issues com IDs estáveis](https://github.com/Dennyum204/HomeOfficeReservation/issues), [labels](https://github.com/Dennyum204/HomeOfficeReservation/labels) e [milestones core/opcionais](https://github.com/Dennyum204/HomeOfficeReservation/milestones). URLs reais e histórico de mudanças de âmbito no backlog canónico. Repositório público; segredos, configuração privada e dados de calendário ficam fora do Git. Lockfiles, migrações e exemplos seguros devem ser versionados quando existirem.

Codex prepara branches, commits, issues e PRs; Fernando revê e faz merge. Sem auto-merge. Não foram escolhidos fornecedor/região/domínio de alojamento, contas de distribuição mobile ou licença de distribuição.
