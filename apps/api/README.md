# Backend .NET

HO-003: ASP.NET Core Identity, EF Core/PostgreSQL, migração inicial, sessões Web/mobile e autorização por organização/membro/relação. [Setup completo, credenciais privadas, administração e recuperação](../../docs/HO-003-AUTHENTICATION.md). Independente de Microsoft.

## Versões e estrutura

HO-006: [presenças e tarefas](../../docs/HO-006-ONSITE-TASKS.md), com migração aditiva, autorização, leitura por revisão e resolução de conflitos sob o mesmo lock do planeamento. HO-007 consome a outbox; DeliveredAt legado passa a significar processamento interno, nunca receção Android.

HO-004: [guia HTTP e demonstração repetível](../../docs/HO-004-PLANNING.md), com migração aditiva explícita, calendário por intervalo, rascunhos/submissão, decisões/retirada por dias, revisões, contrapropostas e comentários. Os comandos usam CalendarVersion, versões específicas e Idempotency-Key; concretizados com UI Web/presenças em HO-005/006 e worker em HO-007. [ADR-006](../../docs/adr/ADR-006-transactional-planning.md).

.NET SDK **10.0.400** em `global.json`, runtime ASP.NET Core 10.0.11; pacotes Microsoft 10.0.11, Npgsql EF 10.0.3. Restore fechado por `packages.lock.json` em cada projeto.

- Domain: zonas IANA, organizações/membros/relações e guard de gestão sem dependências externas.
- Application: contratos de membros/contas e consulta de metadados, sem HTTP/EF.
- Infrastructure: stores Identity/DbContext, migração, diretório de membros, provisionamento e email local/SMTP.
- Api: composição/DI, endpoints e OpenAPI. Sem framework de repositories, mediator ou microserviços.

## Arranque a partir da raiz do repositório

Instalar o SDK fixado e preparar PostgreSQL e contas conforme o [guia HO-003](../../docs/HO-003-AUTHENTICATION.md). A sequência é configuração privada → restore/build → migração explícita → provisionamento Development → arranque:

```sh
dotnet run --project apps/api/src/HomeOffice.Api
```

API em **http://localhost:5080**. Windows preparado admite PostgreSQL portátil; clones novos podem usar Compose. Sem SMTP externo em Development.

| Endpoint real | Significado |
|---|---|
| `GET /health/live` | Processo disponível; 200 mesmo sem PostgreSQL |
| `GET /health/ready` | EF consegue ligar ao PostgreSQL; 200 ou 503, sem detalhes sensíveis |
| `GET /api/v1/workspace` | Nome/versão, timestamp UTC atual e zonas Lisbon/Zurich; sem dados pessoais |
| `GET /openapi/v1.json` | Contrato público apenas em Development |

Readiness verifica conectividade, **não existência de tabelas**. Aplicar `--migrate` antes de login. Não se executa `EnsureCreated`/`Migrate` no arranque. Endpoints Identity e administrativos reais constam de OpenAPI e [ADR-005](../../docs/adr/ADR-005-identity-implementation.md); registo público inexistente. Metadados públicos continuam disponíveis mesmo sem PostgreSQL; login e dados privados exigem DB.

`appsettings.Local.json` é ignorado, preparado por `scripts/init_auth.py`; variáveis de ambiente têm precedência. Produção exige chaves persistentes cifradas e SMTP/HTTPS conforme o guia. Não existe deployment nesta tarefa.

Para dispositivos na rede local, apenas em desenvolvimento:

```sh
dotnet run --project apps/api/src/HomeOffice.Api --urls http://0.0.0.0:5080
```

Autorizar a porta 5080 apenas na rede privada quando o SO pedir. Sem alterar o firewall automaticamente. Release não inclui exceções mobile para HTTP.

## Verificação

```sh
dotnet restore apps/api/HomeOffice.slnx --locked-mode
dotnet format apps/api/HomeOffice.slnx --no-restore --verify-no-changes
dotnet build apps/api/HomeOffice.slnx -c Release --no-restore
dotnet test apps/api/tests/HomeOffice.Api.Tests -c Release --no-build
python scripts/smoke_api.py
```

Testes de integração exigem PostgreSQL real; falham se faltar configuração. Definir `HO_TEST_DATABASE` com a ligação da base descartável (pode ler o ficheiro local sem escrever a password no histórico):

```powershell
$env:HO_TEST_DATABASE = (Get-Content apps/api/src/HomeOffice.Api/appsettings.Local.json -Raw | ConvertFrom-Json).ConnectionStrings.Database
dotnet test apps/api/HomeOffice.slnx -c Release --no-build
python scripts/smoke_api.py --database
```

```sh
export HO_TEST_DATABASE="$(python3 -c 'import json; print(json.load(open("apps/api/src/HomeOffice.Api/appsettings.Local.json"))["ConnectionStrings"]["Database"])')"
dotnet test apps/api/HomeOffice.slnx -c Release --no-build
python3 scripts/smoke_api.py --database
```

A suite Identity cria bases descartáveis `ho003_test_*`, aplica a migração duas vezes e verifica sessões, CSRF, ativação/recuperação, isolamento, papéis e chaves persistentes. `HO_TEST_DATABASE` deve permitir criação de bases de teste; não apontar para produção. O teste readiness existente faz `SELECT 1`. `smoke_api.py` inicia/termina Kestrel próprio em 5082 e confirma live=200/ready=503 quando falta DB, ou ready=200 com `--database`. Preparar configuração privada antes de testar, inclusive em Linux.

Contratos e drift: [contracts](../../contracts/README.md). CLI EF Core 10.0.11 fixada em `dotnet-tools.json`; `dotnet tool restore` antes de gerar SQL/migrations. MailKit 4.17.0 fixado em packages.lock.json.

## Notificações HO-007

[Guia e recuperação](../../docs/HO-007-NOTIFICATIONS.md), [ADR-009](../../docs/adr/ADR-009-durable-notifications.md) e [configuração segura](notifications.example.json). Migração aditiva `20260909202903_DurableNotifications`; backup antes de aplicar, sem reprovisionar contas. Worker no mesmo host e fornecedor Disabled por defeito: sem credenciais Firebase no core. Falhas permanentes, leases e contadores por organização estão no guia. Logs não devem expor endereços push ou payloads de calendário.
# Produção preparada em HO-012

[Imagem API + Web, configuração e recuperação](../../infra/pilot/README.md). `HO_CONFIG_FILE` aponta para JSON privado absoluto; `appsettings.Local.json` só é carregado em Development. Produção/Staging requerem origem HTTPS, hostname único, proxies explícitos, SMTP STARTTLS, worker ativo e key ring persistido/cifrado. Health de produção verifica ligação e migrações; não aplica migrações. Caddy bloqueia diagnósticos no acesso público. Nenhuma contratação/deployment foi realizada.
