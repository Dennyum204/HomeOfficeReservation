# HO-003 — Contas, sessões e autorização

Implementação de 2026-09-09, issue [#4](https://github.com/Dennyum204/HomeOfficeReservation/issues/4). Concretiza ADR-004; [ADR-005](adr/ADR-005-identity-implementation.md) preserva os detalhes e limites decididos. Calendário, aprovações, tarefas e notificações continuam fora deste âmbito. Nenhuma conta Microsoft, consentimento ou validação Graph faz parte deste setup.

## Testar neste Windows, com o ambiente já preparado

Na raiz do repositório, PowerShell:

```powershell
. .git/ho002-env.ps1
python scripts/init_auth.py
$private = Split-Path (Get-Content apps/api/src/HomeOffice.Api/appsettings.Local.json -Raw | ConvertFrom-Json).DataProtection.KeyDirectory -Parent
./scripts/start_local_postgres.ps1 -DataDirectory (Join-Path (Split-Path $private -Parent) 'postgres-18')
dotnet restore apps/api/HomeOffice.slnx --locked-mode
dotnet build apps/api/HomeOffice.slnx -c Release --no-restore
$env:ASPNETCORE_ENVIRONMENT = 'Development'
dotnet run --project apps/api/src/HomeOffice.Api -c Release --no-build -- --migrate
dotnet run --project apps/api/src/HomeOffice.Api -c Release --no-build -- --provision-dev "$private/accounts.json"
dotnet run --project apps/api/src/HomeOffice.Api -c Release --no-build --no-launch-profile --urls http://localhost:5080
```

O script imprime o caminho efetivo dos ficheiros privados, **sem credenciais**. No terminal integrado do Codex, o Windows pode apresentar esse caminho sob `Packages/OpenAI.Codex_…/LocalCache/Local`; nesse caso use exatamente o caminho impresso em `$private`. O helper de SDK `.git/ho002-env.ps1` e o PostgreSQL portátil existem apenas neste computador; não são pré-requisitos de outros clones.

Foi preparado PostgreSQL **18.6** portátil em `%USERPROFILE%/.cache/ho003-tools/pgsql`, dados em `%LOCALAPPDATA%/HomeOfficeReservation/postgres-18`, limitado a `127.0.0.1:5432`, com SCRAM e password local gerada. Não é um serviço Windows; o helper retoma o mesmo cluster, sem reinstalar nem apagar dados. Docker continua ausente neste computador. Não confundir esta base real com fixtures em memória. O utilizador local do cluster pode criar bases para os testes descartáveis; **não usar esta permissão como conta de runtime em produção**.

Noutro PowerShell, na raiz, Web:

```powershell
. .git/ho002-env.ps1
npm.cmd --prefix apps/web ci
npm.cmd --prefix apps/web run dev
```

Abrir [Web local](http://127.0.0.1:5173). Para consultar as credenciais, abrir **localmente** o `accounts.json` cujo caminho foi impresso, por exemplo com `notepad "$private/accounts.json"`. Usar a entrada `employee` ou `manager` (a entrada `admin` gere contas, não aprova pedidos). Não copiar passwords para chat, issues ou PRs. O ficheiro contém apenas contas sintéticas `@homeoffice.example`; não há password publicada por defeito.

Android, noutro terminal:

```powershell
. .git/ho002-env.ps1
cd apps/mobile
flutter.bat pub get --enforce-lockfile
flutter.bat devices
flutter.bat run -d emulator-5554 --no-dds --dart-define=API_BASE_URL=http://10.0.2.2:5080
```

Entrar com as mesmas credenciais privadas. Pode testar login, logout, restauro da sessão ao reabrir, recuperação/ativação e navegação do shell. “Verificar sessão” consulta `/me` autenticado; “Serviço ligado” verifica apenas metadados públicos. Não existem decisões de calendário ou aprovações nesta versão.

## Clone novo / PostgreSQL Compose

Instalar SDKs fixados nos guias de área, Python e Docker Compose v2. Não precisa do helper Windows acima:

```sh
python3 scripts/init_local.py
docker compose -f infra/compose.yaml up -d --wait
dotnet restore apps/api/HomeOffice.slnx --locked-mode
dotnet build apps/api/HomeOffice.slnx -c Release --no-restore
python3 scripts/init_auth.py --private-dir "$HOME/.local/share/HomeOfficeReservation/identity"
export ASPNETCORE_ENVIRONMENT=Development
dotnet run --project apps/api/src/HomeOffice.Api -c Release --no-build -- --migrate
dotnet run --project apps/api/src/HomeOffice.Api -c Release --no-build -- --provision-dev "$HOME/.local/share/HomeOfficeReservation/identity/accounts.json"
dotnet run --project apps/api/src/HomeOffice.Api -c Release --no-build --no-launch-profile --urls http://localhost:5080
```

`init_auth.py` recusa guardar chaves/contas dentro do repositório. Gera certificado de desenvolvimento privado, configuração ignorada, três passwords aleatórias e ficheiro privado para testes nativos. Preserva credenciais existentes. O provisionamento é explícito, exclusivo de Development, transacional e repetível: não repõe passwords, papéis ou contas existentes. Se alterar uma password pela recuperação, o ficheiro original passa a ser apenas o registo da credencial inicial; use a nova password, não repita setup para a repor.

No macOS, `init_auth.py` usa OpenSSL para criar um PFX privado sem interação com o Keychain de certificados HTTPS de desenvolvimento; OpenSSL vem do sistema/Homebrew (também dependência de PostgreSQL). Windows/Linux usam `dotnet dev-certs`, sem pedir confiança ao browser. As operações têm timeout e o material PEM temporário macOS fica num diretório privado que é removido após exportação. Não instala certificados de confiança nem altera o Keychain do utilizador. [req](https://docs.openssl.org/3.6/man1/openssl-req/) / [pkcs12](https://docs.openssl.org/3.6/man1/openssl-pkcs12/), documentação oficial consultada em 2026-09-09.

## Ativação e recuperação sem serviço de email

Em Development, as mensagens são JSON privados no diretório `email` impresso pelo script; não há inbox HTTP, envio externo nem códigos em URLs/logs. No Web ou Flutter, escolher “Ainda não ativei a conta” ou “Esqueci-me da palavra-passe”, pedir código, abrir a mensagem local mais recente para esse email/finalidade e introduzir o seu `code` no formulário. O código expira em uma hora; uma operação bem-sucedida impede reutilização. Passwords exigem 12 caracteres, maiúscula, minúscula, número e símbolo. Respostas de pedido são iguais para contas desconhecidas, inativas e elegíveis.

As três contas sintéticas de setup já estão ativadas exclusivamente pelo comando Development. Para ensaiar ativação completa, provisionar uma quarta conta pelo administrador conforme abaixo. Nenhuma password segue por email. Produção usa MailKit **4.17.0**, SMTP com **STARTTLS obrigatório**, autenticação e validação de certificado normal; não há fallback para captura local. Entrega por um fornecedor real/domínio próprio e recuperação no piloto permanecem validação operacional posterior, **não realizadas nesta entrega**.

## Administração controlada

Não há registo público ou bootstrap HTTP. Para uma organização nova fora de Development, o operador copia o [exemplo de bootstrap](../scripts/bootstrap-admin.example.json) para fora do repositório e prepara um JSON privado com `organizationName`, `email` e `displayName`, aplica migrações e executa `dotnet run --project apps/api/src/HomeOffice.Api -c Release --no-build -- --bootstrap-admin /caminho/privado/admin.json`. Exige configuração de produção válida, recusa organização existente e envia ativação; não recebe password inicial. Não usar `--provision-dev` em produção.

Depois da ativação, os endpoints administrativos exigem um membro ativo com **IsAccountAdministrator**. Exemplo PowerShell para o ambiente sintético, sem password/token no histórico nem na saída:

```powershell
$accounts = Get-Content "$private/accounts.json" -Raw | ConvertFrom-Json
$origin = 'http://localhost:5080'
$login = @{ email = $accounts.admin.email; password = $accounts.admin.password } | ConvertTo-Json
$session = Invoke-RestMethod "$origin/api/v1/auth/token/login" -Method Post -ContentType 'application/json' -Body $login
$headers = @{ Authorization = "Bearer $($session.accessToken)" }
$newMember = @{ email = 'invited@homeoffice.example'; displayName = 'Conta de ativação'; isEmployee = $true; isManager = $false; isAccountAdministrator = $false } | ConvertTo-Json
Invoke-RestMethod "$origin/api/v1/admin/members" -Method Post -Headers $headers -ContentType 'application/json' -Body $newMember
$members = (Invoke-RestMethod "$origin/api/v1/members" -Headers $headers).members
$employee = $members | Where-Object email -eq 'invited@homeoffice.example'
$manager = $members | Where-Object email -eq 'manager@homeoffice.example'
$relationship = @{ managerId = $manager.memberId } | ConvertTo-Json
Invoke-RestMethod "$origin/api/v1/admin/members/$($employee.memberId)/manager" -Method Put -Headers $headers -ContentType 'application/json' -Body $relationship
```

Repetir a atribuição atualiza a mesma relação. Repetir a criação devolve `account_exists`, sem duplicar o membro; pode pedir novo código de ativação no formulário. A criação fica guardada mesmo se a entrega SMTP falhar: recuperar o envio pelo pedido de ativação, sem criar outra conta. A listagem inicial limita-se a 100 membros visíveis; paginação/administração de grandes organizações não é implementada no piloto.

`PUT /api/v1/admin/members/{memberId}` aceita `active`, `isEmployee`, `isManager`, `isAccountAdministrator` de um administrador autorizado da mesma organização. Não aceita OrganizationId. O administrador não altera os seus próprios privilégios por esta operação. Um gestor só vê o próprio perfil e colaboradores ativos explicitamente atribuídos. A relação usa FKs compostas por organização e impede autogestão. `GET /members/{id}/management-access` é apenas um guard de leitura testável; **não executa aprovações**. Privilégios administrativos não conferem autoridade de gestão.

## Migrações, chaves e recuperação operacional

- Migração inicial `20260908215727_InitialIdentityAndMembership` cria tabelas Identity, organizações, membros e relações. Não há `EnsureCreated`, migração ou criação de contas no arranque normal. `/health/ready` verifica conectividade, não esquema: aplicar migrations explicitamente antes de login.
- Para um ambiente existente: cópia de segurança PostgreSQL, revisão do SQL (`dotnet tool restore`; `dotnet ef migrations script --idempotent --project apps/api/src/HomeOffice.Infrastructure --startup-project apps/api/src/HomeOffice.Api -o /caminho/privado/migration.sql`), ensaio numa cópia e execução pelo operador. Separar credenciais de migration e runtime no alojamento. Não executar rollback destrutivo das tabelas de contas; restaurar backup validado se necessário. Política automatizada de backup pertence ao alojamento.
- Data Protection persiste em `DataProtection:KeyDirectory`, nome `HomeOfficeReservation.<Environment>`. Certificado PFX e password por configuração privada; chaves cifradas com o certificado. DPAPI é alternativa apenas Windows Development/Testing. Produção/Linux falha startup sem cifragem configurada; produção também exige diretório explícito e SMTP.
- Limitar ACL/permissões do diretório, certificado e configuração à identidade do processo; não guardar keyring no volume efémero do contentor. Conservar keyring e certificados antigos em backup separado e protegido. Repor **ambos** para manter sessões/códigos após recuperação. Perder/substituir chaves invalida tickets; não recupera passwords. Não apagar chaves antigas para uma rotação normal. Mudança de certificado exige capacidade de desencriptar as chaves antigas antes do rollout; não há rotação automática de certificados implementada.
- [Exemplo de configuração de produção](../apps/api/src/HomeOffice.Api/appsettings.Production.example.json): apenas estrutura e placeholders; não é carregado automaticamente. Fornecer os valores reais por configuração privada/variáveis de ambiente.
- Produção: HTTPS para API e Web na mesma origem, cookie HttpOnly/Secure/SameSite=Lax, CSRF antes de cada mutação de cookie, incluindo login/logout. Terminação TLS/proxy confiável, certificados e entrega SMTP reais têm de ser configurados e ensaiados no alojamento; não foram publicados nesta tarefa. HTTP local só Development e builds mobile debug.

## Sessões e limites demonstrados

| Mecanismo | Duração / comportamento |
|---|---|
| Cookie Web | 8 h, persistente, sem sliding; stamp verificado em cada pedido |
| Access mobile | 15 min, opaco, só memória; framework não consulta stamp em cada validação |
| Refresh mobile | 7 dias, valida stamp e membro ativo; armazenado por origem API no secure storage |
| Password reset | Invalida cookie e renovação pelo stamp; bearer copiado ainda vale até aos 15 min |
| Logout | Web remove cookie; mobile remove credenciais e dados locais mesmo offline; não é logout global |
| Membro desativado / papel retirado | DB consultada em cada operação protegida; token antigo não mantém autoridade |
| Refresh copiado | Não é de utilização única; pode ser reutilizado até expirar ou o stamp invalidar |
| Tentativas | 5 passwords incorretas bloqueiam 15 min; endpoints de conta 30 pedidos/min por IP, sem fila |

Renovar emite novo refresh com prazo de sete dias; não há limite absoluto independente para sessões renovadas. Sem lista/revogação por dispositivo, MFA ou SSO nesta entrega. Não alegar que logout invalida cópias de cookies/tokens roubados. A revogação imediata garantida é da autorização de membro ativo, por verificação no servidor.

Web limpa vistas privadas quando não consegue verificar a sessão; não guarda tokens em localStorage. Apenas a verificação mais recente atualiza a conta; terminar logout também invalida leituras iniciadas enquanto o pedido de saída estava em curso. Duas regressões simuladas cobrem essas respostas fora de ordem. Flutter tenta renovar uma vez e repetir uma leitura idempotente uma vez, nunca mutations; falhas eliminam estado/credenciais, podendo exigir novo login após indisponibilidade de rede. Operações antigas não repõem a conta após logout. `flutter_secure_storage` **11.0.0**, Android Keystore/cifragem do plugin, backup desativado; iOS Keychain com acessibilidade `unlocked_this_device` e entitlements declarados. Não exige biometria nem implementa criptografia própria. Keychain pode sobreviver à desinstalação no iOS; logout explícito remove a entrada, validade continua limitada pelo servidor.

Rate limit é por processo/IP, adequado ao host inicial único; proxy deve preservar IP apenas de proxies confiáveis. Respostas de recuperação não enumeram por corpo/status; latência de entrega pode diferir, não se promete igualdade temporal. Entrega em fila/distribuição do limiter requer decisão de alojamento posterior.

## Verificação reproduzível

Preparar configuração privada e PostgreSQL antes dos testes. `HO_TEST_DATABASE` exige uma base descartável e utilizador capaz de criar/apagar bases de teste; as suites criam nomes aleatórios `ho003_test_*`, aplicam a migração duas vezes e eliminam só essas bases. Nunca apontar testes para produção.

```powershell
$env:HO_TEST_DATABASE = (Get-Content apps/api/src/HomeOffice.Api/appsettings.Local.json -Raw | ConvertFrom-Json).ConnectionStrings.Database
dotnet test apps/api/HomeOffice.slnx -c Release --no-build
$env:HO_DEV_ACCOUNTS = "$private/accounts.json"
npm.cmd --prefix apps/web run test:e2e
```

Playwright inicia API própria na porta 5083 e Vite na 5174, com cookie Development de 4 segundos; verifica expiração real, não relógio simulado. Os servidores normais 5080/5173 podem continuar abertos. Não grava traces/HAR; CI publica apenas screenshots do shell, nunca snapshots de formulários/relatórios que possam incluir passwords.

Para o teste nativo, iniciar **uma API de teste** com `Auth__AccessTokenSeconds=5`, `Auth__RefreshTokenSeconds=30`, `Auth__RequestsPerMinute=300` e ambiente Development. Depois:

```powershell
cd apps/mobile
flutter.bat drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart --no-dds -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:5080 --dart-define-from-file="$private/client-test.json"
```

O ficheiro `client-test.json` contém credenciais sintéticas privadas, **só para o entrypoint de testes**. Não o passar a builds normais/release, não publicar APK/test bundle/logs de diagnóstico. O teste confirma ligação ao endpoint público através do cliente gerado, usa API/PG e secure storage reais, restaura a sessão, espera 31 segundos e exige sessão expirada, troca de conta e limpeza. Os 30 segundos de refresh permitem concluir login/restauro em emuladores lentos; a expiração continua a ser real. Reiniciar a API normal sem essas variáveis após o ensaio. As durações curtas são ignoradas fora de Development/Testing. CI exige `/health/ready` HTTP 200 antes de arrancar cada ensaio nativo.

CI mantém os cinco gates existentes. Linux usa Compose; macOS usa PostgreSQL Homebrew com versão 18.6 verificada, builds Simulator/device sem assinatura e ensaio no Simulator. API TestServer + PostgreSQL usa relógio controlado para tickets de sessão, mais teste de expiração real de código Identity; não equivale a browser/dispositivo. Testes unitários/widget com respostas simuladas são identificados como tal. Resultados efetivos, SHA e eventuais limitações ficam em STATUS e no PR.

CI iOS seleciona explicitamente **macos-15-intel / iPhone 16 / iOS 18.6 / Xcode 26.3**, em vez do primeiro simulador disponível. O runner consta da [lista oficial de runners suportados](https://docs.github.com/en/actions/how-tos/write-workflows/choose-where-workflows-run/choose-the-runner-for-a-job), e o alvo/SDK da [imagem oficial macOS 15 Intel](https://github.com/actions/runner-images/blob/main/images/macos/macos-15-Readme.md), consultadas em 2026-09-09. O build device continua ARM64. Nos ensaios ARM64 com iPhone 17/iOS 26.2, a app compilou/instalou/lançou, mas não expôs o VM Service dentro do prazo, tanto pelos unified logs como pela consola; a causa não ficou demonstrada. A comparação Intel não transforma essas tentativas em sucesso.

`scripts/run_ios_integration.py` compila/instala o entrypoint real, lança-o com `simctl --console` e passa o endereço loopback ao mesmo `flutter drive --use-existing-app` / `integrationDriver`. Não altera o SDK, o protocolo da aplicação, as asserções ou o código de autenticação do debugger. A publicação mDNS continua desativada, como no drive normal. A opção é suportada no [CLI oficial do SDK 3.47.2](https://github.com/flutter/flutter/blob/3.47.2/packages/flutter_tools/lib/src/commands/drive.dart), consultado em 2026-09-09. Cada fase tem prazo e uma falha não é convertida em sucesso.

O wrapper filtra output antes de o enviar ao log: remove credenciais, Dart defines codificados, campos de tokens e URLs privadas do debugger. Não guarda o log original nem resolve packages novamente após o restore com lockfile. Quatro testes verificam filtragem, preservação de erros/etapas e rejeição de endereços de debugger que não sejam loopback; **não são simulação de um teste iOS aprovado**.
