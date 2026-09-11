# HomeOfficeReservation

**HO-012 retomada — ensaio NAS em preparação, ainda sem instalação:** [stack isolada e comandos](infra/nas/README.md), [proposta atual](docs/HO-012-PILOT.md). DS218+ é candidato por medir; Hetzner não aprovado. PR #37 draft, sem lançamento V1.
**HO-016 — Identidade visual Web/Android:** tema Claude + adaptado, claro/escuro/sistema, secções de formulário e estados separados por rótulos e ícones. [Tema, contraste e revisão visual](docs/HO-016-VISUAL-THEME.md). Sem alteração de API, dados ou permissões.

**HO-015 — Administração Web:** membros, convites, estado de entrega, papéis e chefias com confirmação e recuperação de respostas perdidas. [Guia e teste isolado](docs/HO-015-WEB-ADMINISTRATION.md). O titular mantém a sua conta de colaborador; o chefe associado decide os pedidos.

Calendário próprio para planear trabalho remoto em Portugal e presencial na Suíça, com pedidos, aprovações, presenças obrigatórias, tarefas e notificações. **Core V1 completo sem conta Microsoft ou Outlook.**

Stack: ASP.NET Core/.NET 10, EF Core/PostgreSQL, React/TypeScript Web e Flutter Android. iOS adiado pelo responsável em HO-005, com código/histórico preservados; reativação futura em HO-306, sem data. Autenticação própria com ASP.NET Core Identity: cookie na Web e tokens opacos do framework no mobile. Web/mobile partilham backend e calendário autoritativo. [ADR-004](docs/adr/ADR-004-independent-core.md) regista a decisão.

**HO-005 disponibiliza calendário mês/semana e workflows reais na Web:** rascunhos, seleção de datas, decisões parciais, retirada, revisões/cancelamentos, contrapropostas e disponibilidade manual. [Guia e percurso local](docs/HO-005-WEB.md). O calendário separa plano confirmado de alterações pendentes. A API transacional permanece autoritativa; HO-010 acrescenta o calendário e estes pedidos/decisões no Android. HO-006 acrescenta presenças e tarefas na API/Web; HO-007 acrescenta a caixa de notificações Web/Android. [Guia de autenticação e teste local](docs/HO-003-AUTHENTICATION.md). [STATUS.md](STATUS.md) contém evidência de integração e continuidade.

**HO-006 acrescenta API e Web para presenças e tarefas:** intervalos obrigatórios, leitura por revisão, preview de conflitos, resolução explícita sem apagar aprovações, tarefas ligadas e progresso autorizado. [Setup, migração e percurso de teste](docs/HO-006-ONSITE-TASKS.md). A outbox alimenta o worker de notificações de HO-007.

**HO-007 disponibiliza caixa persistente Web/Android**, com contagem, filtros, estado de leitura e contexto autorizado, worker PostgreSQL durável e adaptador FCM opcional. [Setup, testes com duas contas e recuperação](docs/HO-007-NOTIFICATIONS.md). O core funciona sem credenciais push. Entrega FCM real foi observada no emulador Android autorizado em foreground, background e cold start; o guia separa essa evidência das simulações e regista as limitações. Pedidos/decisões abrem no Android em HO-010; HO-011 completa detalhes de presenças/tarefas no Android e a aceitação entre plataformas.

**HO-010 disponibiliza calendário e pedidos Android para os dois papéis:** mês/agenda, rascunhos, aprovação parcial, retirada, revisões, contrapropostas e disponibilidade manual. Recuperação explícita de envios incertos e input protegido por conta. [Utilização, testes e passagem Web → Android](docs/HO-010-ANDROID-PLANNING.md).

**HO-011 completa presenças/tarefas Android e navegação de notificações:** leitura por revisão, resolução explícita, atribuição/progresso e histórico, com input e recuperação protegidos. A Web distingue pedidos próprios de exigências da chefia e abre o detalhe antes da lista em ecrãs estreitos. [Matriz corrente, comandos e percurso com duas contas](docs/HO-011-CORE-ACCEPTANCE.md). Sem nova API/migração nem deployment.

**HO-013 acrescenta bootstrap explícito do titular com os papéis de administrador e colaborador**, na mesma Identity, e extensão idempotente de um administrador existente pelo operador. [Comandos, migração, recuperação e exemplo sintético](docs/HO-013-OWNER-BOOTSTRAP.md). O chefe distinto continua a exigir relação explícita; autoaprovação e autoedição de papéis pela API são recusadas.

**HO-014 acrescenta convites recuperáveis:** estados administrativos, validade separada do convite, reenvio/cancelamento, entrega durável protegida e recuperação de respostas perdidas. [Migração, endpoints e teste sintético](docs/HO-014-INVITATIONS.md). Web/Android aceitam o código Identity no ecrã existente, incluindo «Já tenho um código». Interface administrativa continua para HO-015; SMTP externo e piloto continuam dependentes da preparação operacional HO-012.

## Outlook opcional

Ligação em Definições, num marco independente após o core. HO-008 publica unidirecionalmente dias explícitos confirmados, `showAs=free` por defeito, apenas eventos próprios e sem convites. HO-009 preserva importação de disponibilidade, delta, webhooks e reconciliação de alterações externas para um marco posterior. Nenhum deles bloqueia login, calendário ou lançamento core.

Estudo/probe Microsoft preservados como referência histórica opcional. Onboarding parado e validação Graph real **adiada, não aprovada**. Não são necessárias credenciais Microsoft para desenvolver este repositório.

## Começar

Pré-requisitos: .NET SDK **10.0.400**, Node **24.20.0**/npm **11.19.0**, Flutter **3.47.2** (Dart 3.13.2), Python 3.10+ e Docker/Compose v2. Java **21.0.12+8** para contratos/Android; Android SDK e emulador para Android. iOS não é pré-requisito do desenvolvimento atual. [Versões/fontes](docs/HO-002-FOUNDATION.md). Sem contas/serviços Microsoft.

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

Comandos iOS no guia mobile são referência opcional adiada. IDs vêm de `flutter devices`; ligação de dispositivos físicos e requisitos de assinatura no [guia mobile](apps/mobile/README.md). Guias completos: [backend](apps/api/README.md), [Web](apps/web/README.md), [PostgreSQL](infra/README.md), [contratos](contracts/README.md).

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

CI normal: `project-docs`, `backend-contracts`, `web`, `flutter-android`. iOS só em workflow manual de referência, fora do core. Inclui geração/diff, PostgreSQL real, build/test por stack, browser desktop/estreito e emulador Android. Os comandos exatos constam dos guias de área. Contratos: `python scripts/generate_contracts.py --check`. Estado dos checks do último commit registado no PR.

O workflow documental permite `outlook-probe-tests` apenas manualmente com `run_outlook_reference=true`; são testes sintéticos opcionais, sem chamadas Microsoft. O [probe](scripts/outlook_probe/README.md) não é setup obrigatório.

## Estrutura e tracking

`apps/api/`, `apps/web/` e `apps/mobile/` contêm os projetos compiláveis; `contracts/` contém OpenAPI/clientes gerados e ferramentas; `infra/` fornece PostgreSQL local. HO-003 inclui a migração inicial Identity/membros e clientes autenticados; workflows de negócio entram em HO-004 e seguintes. Sem deployment.

[Issues com IDs estáveis](https://github.com/Dennyum204/HomeOfficeReservation/issues), [labels](https://github.com/Dennyum204/HomeOfficeReservation/labels) e [milestones core/opcionais](https://github.com/Dennyum204/HomeOfficeReservation/milestones). URLs reais e histórico de mudanças de âmbito no backlog canónico. Repositório público; segredos, configuração privada e dados de calendário ficam fora do Git. Lockfiles, migrações e exemplos seguros devem ser versionados quando existirem.

Codex prepara branches, commits, issues e PRs; Fernando revê e faz merge. Sem auto-merge. HO-013/014/015/016 integrados com [evidência de merge/CI](docs/HO-012-INTEGRATION.md). HO-012 continua no [PR draft #37](https://github.com/Dennyum204/HomeOfficeReservation/pull/37), issue #13 aberta.

Domínio existente **ferbatech.com**, nomes futuros homeoffice.ferbatech.com e staging.homeoffice.ferbatech.com. Nenhum DNS/email alterado, domínio comprado ou alojamento contratado. NAS apenas candidato; conectividade Cloudflare reportada não prova instalação/desempenho. [Acesso privado já implementado e gates operacionais restantes](docs/HO-012-PRIVATE-ACCESS.md). Convites Firebase não concedem acesso à aplicação. Dados/emuladores privados preservados; iOS/Outlook adiados.
