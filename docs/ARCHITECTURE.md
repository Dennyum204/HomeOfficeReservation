# Arquitetura do projeto

## Decisão

Stack confirmada em HO-000 para [HomeOfficeReservation](https://github.com/Dennyum204/HomeOfficeReservation): ASP.NET Core/.NET 10, PostgreSQL com EF Core, React/TypeScript Web e Flutter Android/iOS. Monorepo com um backend modular; o backend aloja API, autenticação Web e processamento assíncrono durável. Separar o processo worker apenas se houver necessidade operacional.

Esta stack foi confirmada pelo responsável no pedido HO-000. Aproveita a experiência existente em C#, React e Flutter e limita a operação inicial a um serviço e uma base de dados. Os pressupostos de identidade Microsoft e alojamento continuam por validar; a confirmação da stack não os resolve.

## Componentes e comunicações

| Componente | Comunica com | Responsabilidade |
|---|---|---|
| React Web | Mesmo domínio da API/BFF, por HTTPS | Calendário, pedidos, decisões, tarefas e notificações |
| Flutter | API HTTPS e fornecedor OIDC pelo browser do sistema | Fluxos equivalentes, agenda e push |
| API/BFF | Application, identidade e PostgreSQL | Autenticação, autorização, validação e contratos HTTP |
| Application / Domain | Abstrações de persistência e integrações | Regras de negócio e transações |
| Infrastructure | PostgreSQL, Microsoft Graph, serviço push | Implementa adaptadores externos |
| Worker durável | Outbox PostgreSQL, Graph e serviço push | Retries, notificações, reconciliação e renovação de subscrições |
| Microsoft Graph | Endpoint público de webhooks | Sinaliza alterações; o worker lê os dados necessários |

## Módulos do backend

| Módulo | Possui |
|---|---|
| IdentityAndAccess | Membros, relações de gestão, papéis e consentimentos |
| Planning | Padrão base, pedidos, decisões por dia, revisões e disponibilidade |
| Onsite | Compromissos, reconhecimento e resolução de conflitos |
| Tasks | Tarefas simples e ligação aos compromissos |
| Notifications | Caixa interna, preferências e entregas |
| CalendarSync | Ligações, eventos mapeados, cursores, divergências e subscrições |
| Audit | Registo mínimo de ações de negócio |

Não separar estes módulos em bases de dados ou serviços de rede na V1. Planning e Onsite partilham transações quando precisam de preservar invariantes. A auditoria e a outbox são escritas na mesma transação das alterações de negócio.

## Organização prevista de código

| Caminho previsto | Conteúdo |
|---|---|
| `apps/api/src/HomeOffice.Domain/` | Entidades, valores e regras puras, organizadas por módulo |
| `apps/api/src/HomeOffice.Application/` | Casos de uso, políticas e interfaces de adaptadores |
| `apps/api/src/HomeOffice.Infrastructure/` | EF Core, Graph, tokens, push, relógio e worker |
| `apps/api/src/HomeOffice.Api/` | Endpoints, autenticação/BFF, DI, webhook e configuração |
| `apps/api/tests/` | Testes de domínio, integração e autorização |
| `apps/web/src/features/` | Planning, approvals, onsite, tasks, notifications, settings |
| `apps/mobile/lib/features/` | Mesmas áreas, com views/viewmodels, repositories e services |
| `contracts/` | Especificação e configuração dos clientes gerados |
| `infra/` | Containers, ambiente local, migrações e deploy |

Não estão criados projetos vazios que aparentem uma aplicação funcional. HO-002 cria os projetos compiláveis, versões fixadas e pipelines correspondentes.

## Identidade

Alvo confirmado por Fernando em HO-001: Outlook.com pessoal (MSA), substituindo a hipótese empresarial. O [estudo](HO-001-MICROSOFT-OUTLOOK-STUDY.md) detalha três registos propostos (API/BFF, Flutter público e conector confidencial), audiência pessoal/authority consumers, consentimento e recuperação. O probe e os testes simulados estão preparados; registo, consentimento e Graph real continuam por validar, conforme [ADR-002](adr/ADR-002-outlook.md). Admissão de membros e papéis são controlados pela aplicação; o tenant consumer comum a todos os MSA não concede acesso. A conta do gestor permanece por confirmar.

- Web: login OIDC pelo backend; cookie Secure/HttpOnly, proteção CSRF e origem única para UI/API. Tokens Microsoft não ficam em localStorage.
- Mobile: OIDC authorization code + PKCE no browser do sistema, proposto com Flutter AppAuth. Token de acesso destinado à nossa API, guardado pelo mecanismo seguro da plataforma. Não enviar ID token nem token Graph como se fosse token da API. Políticas broker/Intune exigem avaliar integração nativa MSAL; ainda não foram identificadas nem testadas.
- API: valida assinatura, emissor, audiência, expiração, scopes e tenant permitido; mapeia identidade para membro ativo. A autorização ao objeto/relação é verificada em cada caso de uso.
- Ligação Outlook: consentimento delegado separado, iniciado pelo backend e associado à sessão/utilizador através de estado verificável. O mobile abre esse fluxo autenticado no browser e recebe apenas um resultado/link, nunca um segredo no URL.
- O worker usa uma cache MSAL persistida e cifrada no servidor, com chaves fora do banco. Revogação de consentimento suspende sincronização e solicita reconexão.
- Bootstrap do administrador por configuração de implantação; não existe auto-registo com escolha livre de papel.

Microsoft recomenda o fluxo de código com PKCE/OIDC e bibliotecas de autenticação estabelecidas. [Documentação oficial](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow).

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

- Desenvolvimento: containers locais, PostgreSQL e adaptadores de teste para Graph/push.
- Staging e produção com bases, credenciais e contas de teste separadas.
- Hospedagem Linux que mantenha o worker ativo e aceite webhooks HTTPS públicos. Não usar scale-to-zero para este desenho sem separar/agendar o worker.
- Registos estruturados com correlation ID, health/readiness e métricas de atraso/erro de sync.
- Backups automáticos e ensaio de restauro antes do piloto com dados reais.
- Provedor, região, custos, domínio e distribuição mobile são escolhidos em HO-012; nada foi contratado ou publicado.

## Versões e dependências

.NET 10 é a base confirmada; consultar o ciclo de suporte na [Microsoft](https://learn.microsoft.com/en-us/dotnet/core/releases-and-support). HO-002 fixa o patch SDK efetivamente instalado, versões compatíveis de EF/Npgsql, Node, React, Flutter e ferramentas geradoras em ficheiros e lockfiles. Não usar tags `latest` em produção nem inventar versões de pacotes nesta fase.
