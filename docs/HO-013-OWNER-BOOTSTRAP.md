# HO-013 — Titular administrador e colaborador

Procedimento de operador, [PR #42](https://github.com/Dennyum204/HomeOfficeReservation/pull/42), [issue #38](https://github.com/Dennyum204/HomeOfficeReservation/issues/38), [ADR-014](adr/ADR-014-owner-bootstrap.md). Autenticação existente, sem registo público. O titular administra contas e planeia como colaborador; o chefe é uma pessoa/conta distinta, com relação explícita. Administração não permite autoaprovação.

## Preparar um ensaio isolado

Usar um clone/worktree próprio e uma base PostgreSQL descartável; **não executar o exemplo sobre as contas locais habituais**. SDKs/arranque no [guia backend](../apps/api/README.md). Em worktrees Windows preparados, o helper de SDK pertence à pasta Git comum: `. (Join-Path (git rev-parse --git-common-dir) 'ho002-env.ps1')`. É apenas uma conveniência local, não um ficheiro versionado.

Preparar fora do Git um ficheiro `database-connection` com a ligação à base isolada, que já deve existir. A conta de testes precisa de criar/apagar bases descartáveis; não reutilizar uma conta de produção. Com PowerShell, na raiz do novo worktree:

```powershell
$private = Join-Path $env:LOCALAPPDATA 'HomeOfficeReservation/ho013-demo'
New-Item -ItemType Directory -Force $private | Out-Null
# Preparar localmente $private/database-connection; nunca publicar o seu conteúdo.
$env:HO_TEST_DATABASE = [IO.File]::ReadAllText((Join-Path $private 'database-connection'))
python scripts/init_auth.py --private-dir "$private/identity" --database-from-env HO_TEST_DATABASE
# Usar o caminho efetivo impresso por init_auth.py se o Windows o redirecionar.
dotnet restore apps/api/HomeOffice.slnx --locked-mode
dotnet build apps/api/HomeOffice.slnx -c Release --no-restore
$env:ASPNETCORE_ENVIRONMENT = 'Development'
dotnet run --project apps/api/src/HomeOffice.Api -c Release --no-build -- --migrate
```

O ficheiro ignorado `appsettings.Local.json` só deste worktree aponta à base isolada e à captura de email privada. Development não envia email real. Nenhuma chave Firebase, Outlook ou conta externa é necessária. Não alterar a configuração de outra cópia do projeto.

## Criar um titular novo

Guardar o exemplo sintético em `$private/owner.json`, fora do repositório:

```json
{
  "organizationName": "HO-013 demonstração isolada",
  "email": "titular@homeoffice.example",
  "displayName": "Titular de teste"
}
```

```powershell
dotnet run --project apps/api/src/HomeOffice.Api -c Release --no-build -- --bootstrap-owner "$private/owner.json"
dotnet run --project apps/api/src/HomeOffice.Api -c Release --no-build -- --bootstrap-owner "$private/owner.json"
```

A primeira chamada devolve `provisioned`, UUIDs da organização/membro e auditoria. A segunda devolve `already_provisioned` com os mesmos IDs, sem duplicação, novo email ou mudança de password. Papéis iniciais: administrador **e** colaborador; gestor falso. O membro é ativo mas a Identity aguarda ativação e não tem password. Uma organização já existente de outro bootstrap é recusada; não se faz migração implícita de papéis.

Iniciar API/Web pelos comandos normais, em portas livres (5080/5173 por defeito), e abrir o formulário «Ainda não ativei a conta». Ler localmente a mensagem da pasta de captura indicada por `init_auth.py`, usar o código e escolher a password. Não partilhar códigos/passwords. Se a entrega falhar depois da criação, reparar o canal e usar o pedido de novo código nesse formulário; a conta/auditoria já estão guardadas e o replay não reenvia. Fora de Development exige configuração válida e canal de ativação autorizado; esta tarefa não autorizou envios reais.

## Acrescentar colaboração a um administrador existente

O comando antigo continua válido e cria **só administrador**:

```powershell
dotnet run --project apps/api/src/HomeOffice.Api -c Release --no-build -- --bootstrap-admin "$private/admin.json"
```

`admin.json` usa os mesmos três campos, para outra organização nova. Repeti-lo continua a recusar organização existente. Não usar `--provision-dev` para corrigir papéis; preserva os existentes e é exclusivo de Development.

Confirmar os UUIDs com o recibo de bootstrap, `GET /api/v1/me` autenticado ou listagem administrativa `GET /api/v1/members`. Validar organização, membro e identidade de destino; não selecionar apenas por nome/email. Sem sessão disponível, o operador pode consultar estas três tabelas em modo leitura, na base já confirmada, para validar IDs conhecidos:

```sql
SELECT o."Id" AS "OrganizationId", o."Name", m."Id" AS "MemberId",
       m."IdentityUserId", m."DisplayName", m."Active",
       m."IsAccountAdministrator", m."IsEmployee"
FROM "Organizations" o JOIN "Members" m ON m."OrganizationId" = o."Id"
JOIN "AspNetUsers" u ON u."Id" = m."IdentityUserId"
WHERE o."Id" = '11111111-1111-1111-1111-111111111111'
  AND m."Id" = '22222222-2222-2222-2222-222222222222';
```

Os UUIDs acima são placeholders sintéticos. Guardar os UUIDs **confirmados** e um motivo sem dados sensíveis em `$private/enable-employee.json`:

```json
{
  "organizationId": "11111111-1111-1111-1111-111111111111",
  "memberId": "22222222-2222-2222-2222-222222222222",
  "reason": "HO-013: titular autorizado a planear como colaborador"
}
```

```powershell
dotnet run --project apps/api/src/HomeOffice.Api -c Release --no-build -- --enable-admin-employee "$private/enable-employee.json"
dotnet run --project apps/api/src/HomeOffice.Api -c Release --no-build -- --enable-admin-employee "$private/enable-employee.json"
```

Primeira alteração: `employee_enabled` e ID de auditoria; repetição: `already_employee`, sem novo registo de alteração. Só aceita membro ativo/administrador com Identity válida na organização indicada. IDs vazios/trocados, motivo vazio/maior que 500 caracteres, campos inesperados, membro não administrador ou inativo são recusados. Preserva Identity, passwords/stamps, ativação pendente, sessões, nome, outros papéis, calendário, relações e dados. Reabrir/atualizar a sessão na interface para voltar a consultar o perfil; não exige password nova. Nenhum comando abre uma API de promoção.

## Criar o chefe e associá-lo

A interface administrativa ainda pertence a **[HO-015, issue #40](https://github.com/Dennyum204/HomeOfficeReservation/issues/40)**. Usar os endpoints administrativos existentes com a conta do titular. Guardar **apenas localmente**, em `$private/owner-login.json`, o email sintético e a password escolhida na ativação; não usar transcript/logging de respostas:

```powershell
$origin = 'http://localhost:5080'
$login = Get-Content "$private/owner-login.json" -Raw
$session = Invoke-RestMethod "$origin/api/v1/auth/token/login" -Method Post -ContentType 'application/json' -Body $login
$headers = @{ Authorization = "Bearer $($session.accessToken)" }
$owner = Invoke-RestMethod "$origin/api/v1/me" -Headers $headers
$chief = @{ email='chefe@homeoffice.example'; displayName='Chefe de teste'; isEmployee=$false; isManager=$true; isAccountAdministrator=$false } | ConvertTo-Json
Invoke-RestMethod "$origin/api/v1/admin/members" -Method Post -Headers $headers -ContentType 'application/json' -Body $chief
$members = (Invoke-RestMethod "$origin/api/v1/members" -Headers $headers).members
$manager = @($members | Where-Object email -eq 'chefe@homeoffice.example')
if ($manager.Count -ne 1 -or $manager[0].memberId -eq $owner.memberId) { throw 'Confirmar chefe distinto.' }
$body = @{ managerId=$manager[0].memberId } | ConvertTo-Json
Invoke-RestMethod "$origin/api/v1/admin/members/$($owner.memberId)/manager" -Method Put -Headers $headers -ContentType 'application/json' -Body $body
Remove-Variable session,headers,login
```

Ativar `chefe@homeoffice.example` pelo mesmo canal privado antes de testar login. Criação repetida é recusada com `account_exists`; atribuir a mesma relação é idempotente. O chefe só vê/decide para colaboradores explicitamente associados. A API continua a recusar `PUT /admin/members/{próprioId}` para edição geral dos próprios papéis. Invites de instalação Firebase não concedem acesso; ciclo de convites de aplicação continua em [HO-014, issue #39](https://github.com/Dennyum204/HomeOfficeReservation/issues/39).

## Auditoria, concorrência e recuperação

Migration `20260910214756_AccessAudit` acrescenta somente `AccessAudits`. Bootstrap, extensão de papel, alterações administrativas e associação efetiva registam o estado mínimo na transação; não incrementam versões de calendário. Não se faz backfill que atribua autoria a alterações antigas. No-ops/recusas não criam falsa auditoria de alteração. UUID, origem, ação e motivo permitem verificar a operação; conservar o registo privado de qual operador a executou. Restringir ficheiros, acesso ao host e credenciais de manutenção ao operador autorizado.

Papéis/estado, criação administrativa e relações são serializados por organização. A autoridade é relida depois de obter o lock; dois administradores que tentem retirar mutuamente acesso não conseguem deixar zero administradores ativos. Administração nunca substitui a regra de gestão nem autoriza autoaprovação, mesmo com os três papéis. SQL direto privilegiado não faz parte do contrato da aplicação.

Antes de aplicar em dados existentes: backup validado, rever SQL idempotente e ensaiar numa cópia conforme [HO-003](HO-003-AUTHENTICATION.md). Não remover contas, reaplicar seeds por cima dos dados ou executar `Down` da auditoria usada. Em falha transacional, nenhuma alteração parcial persiste; repetir com os mesmos IDs. Em erro de seleção, corrigir o ficheiro após verificação, sem tentar outros membros por adivinhação. Uma organização já sem administrador ativo não é recuperada automaticamente: investigar com o operador e restaurar backup validado; não promover via endpoint nem fabricar uma segunda identidade. Reverter o código mantendo a tabela aditiva preserva o registo.

## Verificar e testar manualmente

```powershell
dotnet test apps/api/tests/HomeOffice.IntegrationTests -c Release --no-build --filter FullyQualifiedName~OwnerBootstrapTests
dotnet test apps/api/HomeOffice.slnx -c Release --no-build
python scripts/generate_contracts.py --check
python scripts/check_project.py
```

Os testes exigem `HO_TEST_DATABASE`, criam/apagam apenas bases aleatórias nesse servidor isolado e aplicam migrations duas vezes. Oito casos novos cobrem bootstrap concorrente, replay, legado e ativação, preservação de credenciais/calendário/relações/sessões, falha simulada de email e recuperação, negações, isolamento e duas variantes de administração concorrente com espera comprovada no PostgreSQL. Cookie/bearer reais são exercitados pelo TestServer; não são uma interface nativa. CI Web/browser e Android/emulador reutiliza os percursos reais de login, expiração, logout, planeamento e autorização; resultados finais e SHA estão no PR/STATUS. Email é capturado/simulado; não houve SMTP real, entrega FCM nova, iOS, Outlook ou deployment nesta tarefa.

Percurso curto após preparar as duas contas: entrar na Web como titular → confirmar «Colaborador» e «Administrador» no perfil → criar/submeter um pedido próprio → entrar no Android como chefe e selecionar o titular → decidir o pedido → atualizar a Web e confirmar o plano. O titular não deve ter autoridade de chefia sem papel **e relação**, nem conseguir aprovar o próprio pedido. Repetir a extensão de colaborador conserva conta/dados; um administrador antigo mantém a mesma password. Use uma API/emulador de teste dedicado se não quiser alterar sessões locais habituais.

HO-012 continua incompleta/draft no [PR #37](https://github.com/Dennyum204/HomeOfficeReservation/pull/37), com alojamento por decidir. Apenas o registo documental HO-013 foi trazido desse PR. HO-014/015/016 mantêm IDs e histórico próprios; não foram implementados aqui.
