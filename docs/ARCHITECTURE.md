# Arquitetura do projeto

## Decisão

Stack confirmada em HO-000 para [HomeOfficeReservation](https://github.com/Dennyum204/HomeOfficeReservation): ASP.NET Core/.NET 10, PostgreSQL com EF Core, React/TypeScript Web e Flutter Android/iOS. Monorepo com um backend modular; o backend aloja API, autenticação Web e processamento assíncrono durável. Separar o processo worker apenas se houver necessidade operacional.

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

HO-002 cria projetos compiláveis nas quatro fronteiras backend, React e Flutter Android/iOS. Cada fronteira backend tem utilização concreta na consulta pública de metadados ou persistência/health checks; não há repositories genéricos, módulos de negócio vazios ou serviços separados. Domain contém apenas as zonas suportadas; os modelos funcionais entram nas suas tarefas. O DbContext herda IdentityDbContext, sem criação de contas, migrations ou endpoints Identity nesta fase. Guias de execução nas áreas; versões/lockfiles fixados e CI por stack.

## Identidade e calendário independentes

[ADR-004](adr/ADR-004-independent-core.md) escolhe ASP.NET Core Identity com stores EF Core/PostgreSQL e email/password. React usa cookie Secure/HttpOnly e anti-CSRF; Flutter usa os bearer/refresh tokens opacos do próprio framework por HTTPS, com armazenamento seguro. Estes tokens não são JWT/OAuth nem são construídos pela aplicação. Não se instala um servidor de identidade externo. A API resolve IdentityUserId para membro local ativo e verifica organização/relação/papéis em cada operação.

Admissão de membros controlada pelo administrador; recuperação/ativação por mecanismos Identity, sem escolha livre de papéis. Sem Microsoft, email empresarial ou diretório Entra obrigatórios. Microsoft sign-in é apenas uma possível opção futura, distinta de consentimento de calendário. As limitações de sessão/revogação e os gates HO-003 estão no ADR.

Planning/PostgreSQL possuirá o calendário e conflitos. O core não necessita de módulos Graph, credenciais ou endpoints OAuth/webhook. HO-002 cria somente o scaffold executável e a ligação API; HO-003 implementará autenticação e os itens seguintes acrescentarão regras/calendário.

Quando HO-008 for selecionado, a ação explícita em Definições associa uma conta Microsoft ao MemberId já autenticado, sem exigir igualdade de email ou de IDs entre fornecedores. Estado/nonce/PKCE e callback validado por biblioteca impedem associação a outro membro; confirmar a conta escolhida antes de guardar. Tokens Graph ficam numa cache cifrada no backend. Revogação/desligar afetam apenas publicação. O [estudo anterior](HO-001-MICROSOFT-OUTLOOK-STUDY.md) é referência histórica, não o contrato de login atual.

## Contratos e persistência

- REST em `/api/v1`, OpenAPI gerado de forma reprodutível a partir do backend.
- DTOs explícitos; não expor entidades EF diretamente. Clientes TypeScript/Dart gerados e versionados.
- Datas de planeamento em ISO `YYYY-MM-DD`; instantes em ISO 8601 com offset/UTC e zona guardada separadamente quando relevante.
- Escritas concorrentes com versão esperada/ETag. Respostas 409 para conflitos de negócio e 412 para precondição de versão inválida; UI recupera sem descartar o rascunho do utilizador.
- Paginação e limite de horizonte nas consultas. Problem Details com códigos estáveis, sem stack traces para o cliente.
- Idempotency-Key nas submissões/decisões e operações que originam efeitos externos; chave vinculada a utilizador, operação e hash do pedido.
- EF Core para PostgreSQL, migrações explícitas. Usar base PostgreSQL real nos testes de transações e concorrência.

## Outbox e execução

Uma decisão escreve dados, auditoria e mensagem de outbox na mesma transação. Um BackgroundService reclama mensagens com lease/lock no PostgreSQL, faz entregas idempotentes e regista resultado. A falha do Graph não bloqueia a transação de aprovação.

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
