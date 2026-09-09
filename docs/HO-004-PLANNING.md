# HO-004 — Testar pedidos e decisões na API

Planeamento persistente, rascunhos, submissão, decisões parciais, retirada, revisões, contrapropostas, comentários e calendário limitado. Usa as contas Identity de HO-003; sem Microsoft. [ADR-006](adr/ADR-006-transactional-planning.md) define transições, concorrência e limites. Não há ainda calendário ou aprovação nas interfaces.

## Ambiente Windows preparado

Na raiz do repositório, PowerShell; parar a API anterior antes de recompilar/aplicar migrações:

```powershell
. .git/ho002-env.ps1
$private = Split-Path (Get-Content apps/api/src/HomeOffice.Api/appsettings.Local.json -Raw | ConvertFrom-Json).DataProtection.KeyDirectory -Parent
./scripts/start_local_postgres.ps1 -DataDirectory (Join-Path (Split-Path $private -Parent) 'postgres-18')
dotnet restore apps/api/HomeOffice.slnx --locked-mode
dotnet build apps/api/HomeOffice.slnx -c Release --no-restore
$env:ASPNETCORE_ENVIRONMENT = 'Development'
dotnet run --project apps/api/src/HomeOffice.Api -c Release --no-build -- --migrate
dotnet run --project apps/api/src/HomeOffice.Api -c Release --no-build --no-launch-profile --urls http://localhost:5080
```

Noutro PowerShell, na raiz:

```powershell
. .git/ho002-env.ps1
$private = Split-Path (Get-Content apps/api/src/HomeOffice.Api/appsettings.Local.json -Raw | ConvertFrom-Json).DataProtection.KeyDirectory -Parent
python scripts/planning_demo.py --accounts "$private/accounts.json"
```

O script usa apenas `employee`/`manager` sintéticos `@homeoffice.example`, login pelo endpoint Identity e HTTP real em loopback. Seleciona três dias úteis futuros sem plano explícito ou reserva pendente; submete, aprova dois, retira o terceiro, propõe uma revisão do primeiro, confirma que a aprovação original continua efetiva e aprova a revisão. Mostra só as datas da demonstração. Não altera planos anteriores nem elimina dados.

O diário privado `ho004-demo.json`, junto a accounts.json, guarda comandos, chaves idempotentes e recibos antes/depois de enviar. Repetir o comando retoma os mesmos passos sem duplicar efeitos. `--new-run` escolhe datas livres novas e conserva os planos sintéticos anteriores. Se outro utilizador alterar versões durante a demonstração, esta para com HTTP 412/409; não substitui versões silenciosamente. Recuperar o comando pendente com os mesmos dados/versões quando aplicável, ou iniciar conscientemente outra demonstração. Se uma recuperação de conta alterou a password, atualizar o ficheiro privado antes de executar. Não publicar ficheiros privados ou logs de autenticação.

Num clone novo, seguir primeiro [HO-003](HO-003-AUTHENTICATION.md) para PostgreSQL Compose, configuração privada e provisionamento. Não recriar contas/cluster já existentes.

## Migração e recuperação

`TransactionalPlanning` é aditiva: acrescenta zona de planeamento Europe/Zurich às organizações existentes e tabelas/índices de planeamento, sem alterar passwords, membros, relações ou sessões. Migração explícita, aplicada antes do servidor normal; nenhuma migração no startup. Fazer backup e rever o SQL antes de aplicar a outro ambiente:

```powershell
dotnet tool restore
dotnet ef migrations script --idempotent --project apps/api/src/HomeOffice.Infrastructure --startup-project apps/api/src/HomeOffice.Api --configuration Release --output .git/ho004-migrations.sql
```

Repetir `--migrate` é seguro. Não fazer downgrade depois de criar dados de planeamento: Down remove essas tabelas; uma reversão operacional exige backup/restauro coordenado ou migração corretiva, preservando também Identity. Nenhum deployment/restauro de produção realizado nesta entrega. O helper portátil é específico deste Windows e não é requisito de novos clones.

## Contratos e exemplos sintéticos

Prefixo `/api/v1/planning/{employeeId}`; employeeId vem de `/api/v1/me` ou da lista de membros atribuídos. O servidor verifica sempre autoridade atual. Administrador de contas sem relação de gestão não lê nem decide planeamento. Cookie Web exige X-CSRF-TOKEN; bearer Identity válido dispensa apenas CSRF. Nunca passar bearer em query strings.

| Método / sufixo | Ação |
|---|---|
| GET `/calendar?from=YYYY-MM-DD&to=YYYY-MM-DD` | Calendário efetivo e pendente separados, CalendarVersion |
| GET `/requests?offset=0&limit=25` e `/requests/{id}` | Lista/detalhe; rascunhos privados |
| POST `/requests` / PUT `/requests/{id}/draft` | Criar/editar rascunho |
| POST `/requests/{id}/submit` | Congelar revisão e reservar dias |
| POST `/requests/{id}/decide` | Decisão atómica do subconjunto |
| POST `/requests/{id}/withdraw` | Retirar somente Pending |
| GET/POST `/requests/{id}/proposals` | Listar/criar contraproposta com razão |
| PUT `/requests/{id}/proposals/{proposalId}` | Nova revisão de contraproposta; invalida reconhecimento antigo |
| POST `/proposals/{proposalId}/accept` | Reconhecer revisão exata e criar Submitted |
| GET/POST `/requests/{id}/comments` | Comentários contextuais, sem edição silenciosa |
| GET/POST `/patterns` | Histórico/configuração do padrão por vigência |

Preview autenticado separado: `GET /api/v1/planning/date-preview?from=2027-03-26&to=2027-03-29&includeWeekends=false` devolve sexta/segunda, cada entrada com LocalDate/IsWeekend. Arrays explícitos podem selecionar sábado/domingo. Os exemplos usam datas sintéticas; escolher datas futuras dentro do horizonte no momento do teste.

Todos os POST/PUT exigem `Idempotency-Key: <UUID novo para cada comando>` e versões do último GET/recibo. Retry do mesmo comando mantém chave e payload exatos. Exemplo de rascunho:

```json
{
  "expectedCalendarVersion": 0,
  "expectedRequestVersion": null,
  "parentRevisionId": null,
  "note": "Exemplo sintético",
  "days": [{"localDate": "2027-03-29", "location": "RemotePortugal", "availability": "Working"}]
}
```

O recibo devolve `contextId`, `version`, `calendarVersion`, `eventId`. Submeter com `{"expectedCalendarVersion":1,"expectedRequestVersion":1}` apenas se forem as versões recebidas. Para decidir, usar IDs/versões dos dias do detalhe:

```json
{
  "expectedCalendarVersion": 2,
  "expectedRequestVersion": 2,
  "days": [{"dayId":"11111111-1111-4111-8111-111111111111","expectedVersion":1}],
  "approve": false,
  "reason": "Motivo sintético da rejeição"
}
```

O UUID acima é ilustrativo e deve ser substituído pelo ID real do dia criado. Rejeição/contraproposta exigem razão; aprovação aceita comentário opcional. Uma versão ausente dá 428; antiga dá 412; conflito de negócio/idempotência dá 409; dados inválidos dão 400. CalendarVersion não substitui ExpectedRequestVersion/versão de cada dia.

Revisão de aprovado: novo rascunho com ParentRevisionId do pedido que originou o PlanDay, e BaseDayId/ BasePlanVersion do calendário efetivo. `cancel:true`, Location=Unplanned, Availability=Working cancela só após aprovação. Leave/Unavailable usam Unplanned e `cancel:false`; não são remoção do plano. Decisões originais e ligações entre revisões permanecem no histórico. As restrições completas, incluindo vigência do padrão e edição de contrapropostas já parcialmente resolvidas, constam do ADR.

## Verificação

```powershell
$env:HO_TEST_DATABASE = (Get-Content apps/api/src/HomeOffice.Api/appsettings.Local.json -Raw | ConvertFrom-Json).ConnectionStrings.Database
dotnet test apps/api/HomeOffice.slnx -c Release --no-build
python scripts/generate_contracts.py --check
python scripts/check_project.py
```

Testes usam bases PostgreSQL descartáveis próprias, migração duas vezes e conexões distintas com PIDs PostgreSQL diferentes nas corridas. Não apontar para produção. Testes incluem concorrência de submissões/decisões, chave repetida, seleção inválida, falha real de insert da outbox por trigger sintético, rollback de saves intermédios, preservação de aprovados e autorização/CSRF por HTTP. O relógio controlado permite DST/janelas reprodutíveis; não é evidência Graph.

Testes dos clientes gerados verificam body/query/response de datas sem UTC, com transporte HTTP simulado e sem implementar interfaces de calendário. TypeScript usa os helpers originais do gerador; Dart usa o template ajustado em contracts/templates/dart/api.mustache. Números JSON estritos evitam esquemas numéricos ambíguos. CI mantém os cinco gates, autenticação Web/Android/iOS e builds reais. Resultados executados e SHA final ficam no PR e STATUS.

Outbox apenas persistida, nunca entregue. Sem presenças obrigatórias, tarefas, notificações, UI de calendário, Outlook ou deployment. Próximo item após revisão/merge/integração: **HO-005 — calendário Web e aprovação**.
