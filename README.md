# HomeOfficeReservation

Calendário próprio para planear trabalho remoto em Portugal e presencial na Suíça, com pedidos, aprovações, presenças obrigatórias, tarefas e notificações. **Core V1 completo sem conta Microsoft ou Outlook.**

Stack: ASP.NET Core/.NET 10, EF Core/PostgreSQL, React/TypeScript Web e Flutter Android/iOS. Autenticação própria com ASP.NET Core Identity: cookie na Web e tokens opacos do framework no mobile. Web/mobile partilham backend e calendário autoritativo. [ADR-004](docs/adr/ADR-004-independent-core.md) regista a decisão.

**Estado: HO-004 acrescenta planeamento transacional na API.** [Demonstração HTTP local](docs/HO-004-PLANNING.md): pedidos, decisões parciais, revisões, contrapropostas e calendário efetivo. API, Web e Flutter permitem login, ativação, recuperação e sessão própria de HO-003. Interfaces de calendário/pedidos e tarefas continuam em preparação. [Guia de autenticação e teste local](docs/HO-003-AUTHENTICATION.md). [STATUS.md](STATUS.md) contém evidência de integração e continuidade.

## Outlook opcional

Ligação em Definições, num marco independente após o core. HO-008 publica unidirecionalmente dias explícitos confirmados, `showAs=free` por defeito, apenas eventos próprios e sem convites. HO-009 preserva importação de disponibilidade, delta, webhooks e reconciliação de alterações externas para um marco posterior. Nenhum deles bloqueia login, calendário ou lançamento core.

Estudo/probe Microsoft preservados como referência histórica opcional. Onboarding parado e validação Graph real **adiada, não aprovada**. Não são necessárias credenciais Microsoft para desenvolver este repositório.

## Começar

Pré-requisitos: .NET SDK **10.0.400**, Node **24.20.0**/npm **11.19.0**, Flutter **3.47.2** (Dart 3.13.2), Python 3.10+ e Docker/Compose v2. Java **21.0.12+8** para contratos/Android; Android SDK e emulador para Android; macOS/Xcode para iOS. [Versões/fontes](docs/HO-002-FOUNDATION.md). Sem contas/serviços Microsoft.

O [guia HO-003](docs/HO-003-AUTHENTICATION.md) contém o setup completo: iniciar PostgreSQL, `python scripts/init_auth.py`, restore/build, `--migrate` explícito e `--provision-dev` com o caminho privado impresso pelo script. No Windows já preparado, pode reutilizar PostgreSQL portátil e os SDKs locais; Docker não é necessário nessa alternativa.

Depois de aplicar migrações e provisionar as contas, iniciar a API na porta **5080**:

```sh
dotnet run --project apps/api/src/HomeOffice.Api
```

Não publicar as passwords sintéticas, códigos de email ou ficheiros privados. Pode entrar como colaborador, gestor ou administrador de contas; estas capacidades são verificadas no servidor.

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

`apps/api/`, `apps/web/` e `apps/mobile/` contêm os projetos compiláveis; `contracts/` contém OpenAPI/clientes gerados e ferramentas; `infra/` fornece PostgreSQL local. HO-003 inclui a migração inicial Identity/membros e clientes autenticados; workflows de negócio entram em HO-004 e seguintes. Sem deployment.

[24 issues com IDs estáveis](https://github.com/Dennyum204/HomeOfficeReservation/issues), [labels](https://github.com/Dennyum204/HomeOfficeReservation/labels) e [milestones core/opcionais](https://github.com/Dennyum204/HomeOfficeReservation/milestones). URLs reais e histórico de mudanças de âmbito no backlog canónico. Repositório público; segredos, configuração privada e dados de calendário ficam fora do Git. Lockfiles, migrações e exemplos seguros devem ser versionados quando existirem.

Codex prepara branches, commits, issues e PRs; Fernando revê e faz merge. Sem auto-merge. Não foram escolhidos fornecedor/região/domínio de alojamento, contas de distribuição mobile ou licença de distribuição.
