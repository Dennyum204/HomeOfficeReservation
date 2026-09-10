# Arquitetura do projeto

## Decisão

Stack confirmada em HO-000 para [HomeOfficeReservation](https://github.com/Dennyum204/HomeOfficeReservation): ASP.NET Core/.NET 10, PostgreSQL com EF Core, React/TypeScript Web e Flutter Android. iOS foi adiado em HO-005; o código e a evidência anteriores mantêm-se, sem gates atuais nem data de reativação (HO-306). Monorepo com um backend modular; o backend aloja API, autenticação Web e processamento assíncrono durável. Separar o processo worker apenas se houver necessidade operacional.

Esta stack foi confirmada pelo responsável no pedido HO-000. Aproveita a experiência existente em C#, React e Flutter e limita a operação inicial a um serviço e uma base de dados. A direção revista em HO-001 escolhe autenticação própria e calendário interno autoritativo; Outlook fica opcional. O alojamento continua por escolher.

## Componentes e comunicações

| Componente | Comunica com | Responsabilidade |
|---|---|---|
| React Web | Mesmo domínio da API/BFF, por HTTPS | Calendário, pedidos, decisões, tarefas e notificações |
| Flutter | API HTTPS com ASP.NET Core Identity | Fluxos equivalentes, agenda e push |
| API/BFF | Application, identidade e PostgreSQL | Autenticação, autorização, validação e contratos HTTP |
| Application / Domain | Abstrações de persistência e integrações | Regras de negócio e transações |
| Infrastructure | PostgreSQL, serviço push; Graph só no conector opcional | Implementa adaptadores externos |
| Worker durável | Outbox PostgreSQL e serviço push | Retries/notificações core; publicação Graph apenas no marco opcional |
| Microsoft Graph (posterior) | Conector opcional | HO-008 publica dias; apenas HO-009 acrescenta webhooks/importação |

## Módulos do backend

| Módulo | Possui |
|---|---|
| IdentityAndAccess | Contas locais Identity, membros, relações de gestão, papéis e sessões |
| Planning | Padrão base, pedidos, decisões por dia, revisões e disponibilidade |
| Onsite | Compromissos, reconhecimento e resolução de conflitos |
| Tasks | Tarefas simples e ligação aos compromissos |
| Notifications | Caixa interna, preferências e entregas |
| CalendarSync (opcional, posterior) | HO-008: ligação/mapeamento/publicação; HO-009: cursores/divergências/subscrições |
| Audit | Registo mínimo de ações de negócio |

Não separar estes módulos em bases de dados ou serviços de rede na V1. Planning e Onsite partilham transações quando precisam de preservar invariantes. A auditoria e a outbox são escritas na mesma transação das alterações de negócio.

## Organização de código

| Caminho | Conteúdo |
|---|---|
| `apps/api/src/HomeOffice.Domain/` | Entidades, valores e regras puras, organizadas por módulo |
| `apps/api/src/HomeOffice.Application/` | Casos de uso, políticas e interfaces de adaptadores |
| `apps/api/src/HomeOffice.Infrastructure/` | EF Core, Identity, push/email, relógio e worker; Graph opcional posterior |
| `apps/api/src/HomeOffice.Api/` | Endpoints, autenticação, DI e configuração; callbacks/webhooks só nos marcos opcionais |
| `apps/api/tests/` | Testes de domínio, integração e autorização |
| `apps/web/src/features/` | Planning, approvals, onsite, tasks, notifications, settings |
| `apps/mobile/lib/features/` | Mesmas áreas, com views/viewmodels, repositories e services |
| `contracts/` | Especificação e configuração dos clientes gerados |
| `infra/` | Containers, ambiente local, migrações e deploy |

HO-002 criou os projetos compiláveis. HO-003 acrescenta modelos Organization/Member/ReportingLine, migração Identity, autenticação e autorização atual por objeto. Application define contratos, Infrastructure implementa stores/email/provisionamento; API usa handlers Identity. Web e Flutter consomem AuthApi/AccessApi gerados. Sem repositories genéricos, mediator ou serviços separados. [ADR-005](adr/ADR-005-identity-implementation.md) e [setup/evidência](HO-003-AUTHENTICATION.md).

## Identidade e calendário independentes

[ADR-004](adr/ADR-004-independent-core.md) escolhe ASP.NET Core Identity com stores EF Core/PostgreSQL e email/password. React usa cookie Secure/HttpOnly e anti-CSRF; Flutter usa os bearer/refresh tokens opacos do próprio framework por HTTPS, com armazenamento seguro. Estes tokens não são JWT/OAuth nem são construídos pela aplicação. Não se instala um servidor de identidade externo. A API resolve IdentityUserId para membro local ativo e verifica organização/relação/papéis em cada operação.

Admissão de membros controlada pelo administrador; recuperação/ativação por mecanismos Identity, sem escolha livre de papéis. Sem Microsoft, email empresarial ou diretório Entra obrigatórios. Microsoft sign-in é apenas uma possível opção futura, distinta de consentimento de calendário. As limitações de sessão/revogação e os gates HO-003 estão no ADR.

HO-004 implementa o calendário autoritativo e transações Planning/PostgreSQL; [ADR-006](adr/ADR-006-transactional-planning.md) concretiza as decisões. O core não necessita de módulos Graph, credenciais ou endpoints OAuth/webhook. HO-003 implementa autenticação; HO-004 implementa pedidos, decisões, revisões, contrapropostas e leitura de calendário na API. HO-005/006 implementam interfaces Web e presenças/tarefas; HO-007 acrescenta entregas internas.

Quando HO-008 for selecionado, a ação explícita em Definições associa uma conta Microsoft ao MemberId já autenticado, sem exigir igualdade de email ou de IDs entre fornecedores. Estado/nonce/PKCE e callback validado por biblioteca impedem associação a outro membro; confirmar a conta escolhida antes de guardar. Tokens Graph ficam numa cache cifrada no backend. Revogação/desligar afetam apenas publicação. O [estudo anterior](HO-001-MICROSOFT-OUTLOOK-STUDY.md) é referência histórica, não o contrato de login atual.

## Contratos e persistência

HO-013 complementa Identity com comandos de operador para titular administrador/colaborador e auditoria transacional de acesso, sem HTTP novo. Escritas administrativas bloqueiam a organização e revalidam o ator dentro da transação, preservando pelo menos um administrador ativo sob concorrência. A extensão de colaboração não modifica credenciais, calendário ou relações. `AccessAudits` reutiliza a persistência/auditoria mínima, separada das versões de planeamento. [ADR-014](adr/ADR-014-owner-bootstrap.md), [procedimento e recuperação](HO-013-OWNER-BOOTSTRAP.md). Convites/administração Web permanecem HO-014/015; HO-012 não foi incorporada.

- REST em `/api/v1`, OpenAPI gerado de forma reprodutível a partir do backend.
- DTOs explícitos; não expor entidades EF diretamente. Clientes TypeScript/Dart gerados e versionados.
- Datas de planeamento em ISO `YYYY-MM-DD`; instantes em ISO 8601 com offset/UTC e zona guardada separadamente quando relevante.
- Escritas concorrentes com versão esperada/ETag. Respostas 409 para conflitos de negócio e 412 para precondição de versão inválida; UI recupera sem descartar o rascunho do utilizador.
- Paginação e limite de horizonte nas consultas. Problem Details com códigos estáveis, sem stack traces para o cliente.
- Idempotency-Key nas submissões/decisões e operações que originam efeitos externos; chave vinculada a utilizador, operação e hash do pedido.
- EF Core para PostgreSQL, migrações explícitas. Usar base PostgreSQL real nos testes de transações e concorrência.

## Outbox e execução

Uma decisão escreve dados, auditoria e mensagem de outbox na mesma transação. HO-004 implementa esta persistência, sem entregas. Em HO-007, um BackgroundService reclamará mensagens com lease/lock no PostgreSQL, fará entregas idempotentes e registará resultado. A falha do Graph não bloqueia a transação de aprovação.

A fila é durável e suporta mais de uma instância sem duplicar efeitos; não basta uma fila em memória. Ordenar/reconciliar mensagens pela versão atual do planeamento para um evento antigo não repor datas ultrapassadas. Erros permanentes ficam visíveis, com diagnóstico mínimo e recuperação controlada.

## Operação

- Desenvolvimento core: containers locais, PostgreSQL e adaptadores de teste para push/email; sem configuração Microsoft. Conector opcional desativado por defeito.
- Staging e produção com bases, credenciais e contas de teste separadas.
- Hospedagem Linux para API/Web HTTPS e worker de notificações ativo. Callbacks Microsoft só em HO-008; webhooks públicos só em HO-009. Não usar scale-to-zero para este desenho sem separar/agendar o worker.
- Registos estruturados com correlation ID, health/readiness e métricas de atraso/erro de sync.
- Backups automáticos e ensaio de restauro antes do piloto com dados reais.
- Provedor, região, custos, domínio e distribuição mobile são escolhidos em HO-012; nada foi contratado ou publicado.

## Versões e dependências

.NET 10 é a base confirmada; consultar o ciclo de suporte na [Microsoft](https://learn.microsoft.com/en-us/dotnet/core/releases-and-support). HO-002 fixa SDK 10.0.400, pacotes Microsoft 10.0.11/Npgsql EF 10.0.3, Node 24.20.0/npm 11.19.0, React 19.2.8, TypeScript 6.0.3, Flutter 3.47.2/Dart 3.13.2 e OpenAPI Generator 7.25.0. Fontes/versionamento em [HO-002](HO-002-FOUNDATION.md); builds/lockfiles nas áreas. Sem tags latest.

## Concretização Web HO-005

[ADR-007](adr/ADR-007-web-planning-and-active-platforms.md): calendário mês/semana, versões congeladas na confirmação, recuperação explícita de comandos wire/idempotency em sessionStorage sem tokens e leituras canceláveis por ator/colaborador. Extensões de leitura limitadas a sourceRequestId e filtro state antes da paginação; sem migração. Web/Android ativos; iOS adiado HO-306.

## Presenças e tarefas HO-006

[ADR-008](adr/ADR-008-onsite-and-tasks.md) reutiliza o mesmo PlanningProfile/CalendarVersion e transação para OnsiteRequirement, AssignedTask, leitura por revisão e histórico/comentários. Active projeta presença sobre o padrão; NeedsResolution conserva o plano explícito. Aprovações e resoluções revalidam presenças sob o lock. Não existem cópias de PlanDay para restaurar em cancelamentos. Migração aditiva, clientes gerados e Web no [guia HO-006](HO-006-ONSITE-TASKS.md); contratos Android disponíveis, interface Android posterior.

## Notificações implementadas em HO-007

[ADR-009](adr/ADR-009-durable-notifications.md) concretiza worker no mesmo host, leases PostgreSQL, commit conjunto inbox/intenção/outbox, histórico sem alertas e autorização atual. Web/Android usam polling limitado e contratos gerados; FCM usa ADC no backend e recursos nativos privados no Android. [ADR-010](adr/ADR-010-android-fcm-registration.md) substitui apenas o registo Android: APIs FID oficiais numa fila de trabalho Flutter, callbacks na thread principal e filtro de repetições. Provider Disabled mantém core/CI independentes. Processamento interno, simulação, aceitação FCM e recibo do cliente são estados distintos. Entrega real observada no emulador autorizado, com [evidência, limitações e operação](HO-007-NOTIFICATIONS.md).

## Planeamento Android HO-010

[ADR-011](adr/ADR-011-android-planning.md): mês/agenda, pedidos e decisões usam os contratos gerados existentes. Controller separa estado confirmado, input e envelope cifrado da operação incerta; gerações de sessão/consulta descartam resultados atrasados. Notificações resolvem o destino na API e abrem o pedido atual. Contraproposta sobre revisão pendente transporta a aprovação original apenas pela referência e versão explicitamente existentes na revisão; mesma transação/autorização, sem migração nem mudança de contrato. [Guia de utilização e ensaios](HO-010-ANDROID-PLANNING.md).

## Interfaces core HO-011

[ADR-012](adr/ADR-012-core-interfaces.md) estende o controller/journal Android a presenças/tarefas, conservando um colaborador autorizado e uma intenção incerta de cada vez. Gerações separadas protegem leituras/previews; input e comandos são protegidos por conta. Notificações resolvem destinos atuais de pedidos, presenças e tarefas. Não há alteração de contrato, migração ou infraestrutura. [Matriz de aceitação corrente](HO-011-CORE-ACCEPTANCE.md).
