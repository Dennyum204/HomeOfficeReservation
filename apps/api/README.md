# Backend .NET

HO-002: API ASP.NET Core/.NET 10 compilável, EF Core/Npgsql/PostgreSQL e metadados públicos. Sem autenticação funcional, calendário ou migrações de negócio; HO-003 implementará Identity, contas e sessões conforme ADR-004.

## Versões e estrutura

.NET SDK **10.0.400** em `global.json`, runtime ASP.NET Core 10.0.11; pacotes Microsoft 10.0.11, Npgsql EF 10.0.3. Restore fechado por `packages.lock.json` em cada projeto.

- Domain: identificadores IANA de planeamento, sem dependências externas.
- Application: consulta de metadados com TimeProvider, sem HTTP/EF.
- Infrastructure: DbContext derivado de IdentityDbContext e health check PostgreSQL. Modelo Identity preparado; não se expõe `/register` nem se cria utilizador.
- Api: composição/DI, endpoints e OpenAPI. Sem framework de repositories, mediator ou microserviços.

## Arranque a partir da raiz do repositório

Instalar o SDK fixado e Docker com Compose v2. Preparar configuração local uma única vez:

```sh
python scripts/init_local.py
docker compose -f infra/compose.yaml up -d --wait
dotnet restore apps/api/HomeOffice.slnx --locked-mode
dotnet run --project apps/api/src/HomeOffice.Api
```

API em **http://localhost:5080**. No Unix pode usar `python3`. `init_local.py` gera uma password aleatória, sem a imprimir, nos dois ficheiros ignorados. Preserva ficheiros existentes. Detalhes de PostgreSQL em [infra](../../infra/README.md).

| Endpoint real | Significado |
|---|---|
| `GET /health/live` | Processo disponível; 200 mesmo sem PostgreSQL |
| `GET /health/ready` | EF consegue ligar ao PostgreSQL; 200 ou 503, sem detalhes sensíveis |
| `GET /api/v1/workspace` | Nome/versão, timestamp UTC atual e zonas Lisbon/Zurich; sem dados pessoais |
| `GET /openapi/v1.json` | Contrato público apenas em Development |

Readiness verifica conectividade, **não a existência de tabelas Identity ou migrações**. Não há migrações nesta entrega: o esquema nasce com os modelos funcionais em HO-003/HO-004. Não se executa `EnsureCreated`/`Migrate` no arranque. A API inicia sem configuração PostgreSQL, mas readiness fica 503; “Serviço ligado” nos clientes confirma API, não prontidão da base.

Configuração: `appsettings.Local.example.json` é seguro; copiar para `appsettings.Local.json` e ajustar quando não usar o script. `ConnectionStrings__Database` tem precedência. O exemplo não contém credenciais reais. Produção ainda não está preparada: HO-003 acrescenta HTTPS/cookies/anti-CSRF, autorização e Data Protection persistente; não usar este scaffold público para dados reais.

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

O teste PostgreSQL faz `SELECT 1` por EF e verifica readiness/modelo Identity; não cria/apaga dados. `smoke_api.py` inicia/termina um Kestrel real na porta 5082. Os testes de falha usam uma porta sem servidor PostgreSQL e confirmam live=200/ready=503. Geração em [contracts](../../contracts/README.md).
