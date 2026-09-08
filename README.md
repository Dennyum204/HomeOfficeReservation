# HomeOfficeReservation

Calendário próprio para planear trabalho remoto em Portugal e presencial na Suíça, com pedidos, aprovações, presenças obrigatórias, tarefas e notificações. **Core V1 completo sem conta Microsoft ou Outlook.**

Stack: ASP.NET Core/.NET 10, EF Core/PostgreSQL, React/TypeScript Web e Flutter Android/iOS. Autenticação própria com ASP.NET Core Identity: cookie na Web e tokens opacos do framework no mobile. Web/mobile partilham backend e calendário autoritativo. [ADR-004](docs/adr/ADR-004-independent-core.md) regista a decisão.

**Estado: fundações executáveis de HO-002.** API, shell Web e Flutter ligados por clientes gerados; calendário, autenticação, pedidos e tarefas ainda em preparação. HO-000/HO-001 integrados pelos [PR #25](https://github.com/Dennyum204/HomeOfficeReservation/pull/25) e [PR #27](https://github.com/Dennyum204/HomeOfficeReservation/pull/27), com merge/CI verificados. [STATUS.md](STATUS.md) contém evidência e continuidade.

## Outlook opcional

Ligação em Definições, num marco independente após o core. HO-008 publica unidirecionalmente dias explícitos confirmados, `showAs=free` por defeito, apenas eventos próprios e sem convites. HO-009 preserva importação de disponibilidade, delta, webhooks e reconciliação de alterações externas para um marco posterior. Nenhum deles bloqueia login, calendário ou lançamento core.

Estudo/probe Microsoft preservados como referência histórica opcional. Onboarding parado e validação Graph real **adiada, não aprovada**. Não são necessárias credenciais Microsoft para desenvolver este repositório.

## Começar

Pré-requisitos: .NET SDK **10.0.400**, Node **24.20.0**/npm **11.19.0**, Flutter **3.47.2** (Dart 3.13.2), Python 3.10+ e Docker/Compose v2. Java **21.0.12.1+1** para contratos/Android; Android SDK e emulador para Android; macOS/Xcode para iOS. [Versões/fontes](docs/HO-002-FOUNDATION.md). Sem contas/serviços Microsoft.

Na raiz, configuração inicial e backend:

```sh
python scripts/init_local.py
docker compose -f infra/compose.yaml up -d --wait
dotnet restore apps/api/HomeOffice.slnx --locked-mode
dotnet run --project apps/api/src/HomeOffice.Api
```

API: **http://localhost:5080**. O script cria configuração ignorada e uma password apenas local, sem imprimir nem sobrescrever ficheiros existentes. Pode usar `python3` em Unix.

Noutro terminal, Web:

```sh
npm --prefix apps/web ci
npm --prefix apps/web run dev
```

Abrir **http://127.0.0.1:5173**. Vite faz proxy de `/api` para a API.

Mobile, com emulador/dispositivo disponível:

```sh
cd apps/mobile
flutter pub get --enforce-lockfile
flutter devices
flutter run -d <device-id> --dart-define=API_BASE_URL=http://10.0.2.2:5080
```

No iOS Simulator usar `http://localhost:5080`. IDs vêm de `flutter devices`; ligação de dispositivos físicos e requisitos de assinatura no [guia mobile](apps/mobile/README.md). Guias completos: [backend](apps/api/README.md), [Web](apps/web/README.md), [PostgreSQL](infra/README.md), [contratos](contracts/README.md).

Para trabalhar no projeto: ler [AGENTS.md](AGENTS.md), [STATUS.md](STATUS.md), [PLANO.md](PLANO.md) e os critérios do item selecionado no [backlog](docs/BACKLOG.md). Não iniciar outra tarefa sem autorização.

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

CI normal: `project-docs`, `backend-contracts`, `web`, `flutter-android`, `flutter-ios`. Inclui geração/diff, PostgreSQL real, build/test por stack, browser e emuladores/simulador. Os comandos exatos constam dos guias de área. Contratos: `python scripts/generate_contracts.py --check`. Estado dos checks do último commit registado no PR.

O workflow documental permite `outlook-probe-tests` apenas manualmente com `run_outlook_reference=true`; são testes sintéticos opcionais, sem chamadas Microsoft. O [probe](scripts/outlook_probe/README.md) não é setup obrigatório.

## Estrutura e tracking

`apps/api/`, `apps/web/` e `apps/mobile/` contêm os projetos compiláveis; `contracts/` contém OpenAPI/clientes gerados e ferramentas; `infra/` fornece PostgreSQL local. HO-002 não implementa workflows, autenticação funcional ou migrações de negócio e não faz deployment.

[24 issues com IDs estáveis](https://github.com/Dennyum204/HomeOfficeReservation/issues), [labels](https://github.com/Dennyum204/HomeOfficeReservation/labels) e [milestones core/opcionais](https://github.com/Dennyum204/HomeOfficeReservation/milestones). URLs reais e histórico de mudanças de âmbito no backlog canónico. Repositório público; segredos, configuração privada e dados de calendário ficam fora do Git. Lockfiles, migrações e exemplos seguros devem ser versionados quando existirem.

Codex prepara branches, commits, issues e PRs; Fernando revê e faz merge. Sem auto-merge. Não foram escolhidos fornecedor/região/domínio de alojamento, contas de distribuição mobile ou licença de distribuição.
