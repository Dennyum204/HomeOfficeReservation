# HO-014 — Convites de acesso

Implementação selecionada para [issue #39](https://github.com/Dennyum204/HomeOfficeReservation/issues/39), branch `feat/ho-014-access-invitations`, [PR #43](https://github.com/Dennyum204/HomeOfficeReservation/pull/43). [ADR-015](adr/ADR-015-access-invitations.md) documenta decisão, concorrência, limites e evidência. A interface de administração Web será HO-015; os convites Firebase de instalação do APK continuam independentes.

## Aplicar e iniciar

Usar os SDKs fixados, PostgreSQL e configuração privada dos [guias Identity](HO-003-AUTHENTICATION.md) e [titular](HO-013-OWNER-BOOTSTRAP.md). Antes da versão nova, aplicar explicitamente `20260910230508_AccessInvitations`:

```sh
dotnet restore apps/api/HomeOffice.slnx --locked-mode
dotnet build apps/api/HomeOffice.slnx -c Release --no-restore
dotnet run --project apps/api/src/HomeOffice.Api -c Release --no-build -- --migrate
dotnet run --project apps/api/src/HomeOffice.Api -c Release --no-build
npm --prefix apps/web ci
npm --prefix apps/web run dev
```

Não executar `--provision-dev` em contas já usadas para as recriar. Novos titulares usam `--bootstrap-owner` com JSON privado; administradores legados mantêm `--bootstrap-admin`/`--enable-admin-employee`. Bootstrap passa a persistir convite e a tentar uma entrega após commit. Um recibo `provisioned` confirma criação, não leitura ou envio externo. Repetir bootstrap não reenvia; reparar o canal e usar reenvio/worker.

`Notifications:WorkerEnabled=true` mantém a recuperação de convites e notificações ativa no mesmo host. Sem worker, a tentativa imediata continua a existir, mas falhas aguardam reativação. Development normal captura emails no `Email:CaptureDirectory` privado. Não necessita de SMTP, Microsoft ou Firebase reais.

O adaptador SMTP pode ser ensaiado localmente, explicitamente em Development/Testing, com estes campos no ficheiro **privado**:

```json
{
  "Email": {
    "Transport": "LocalSmtp",
    "Host": "127.0.0.1",
    "Port": 2526,
    "From": "homeoffice@local.example"
  }
}
```

Iniciar a captura numa consola separada, com diretório privado fora do repositório:

```sh
python scripts/local_smtp_capture.py --directory /private/ho014/email --port 2526 --fail-file /private/ho014/SMTP-FAIL.flag
```

Criar esse ficheiro de controlo simula SMTP 451; removê-lo permite ao worker recuperar. O servidor guarda `.eml` apenas localmente e nunca faz relay. Só endereços `.example`/`.invalid` e IP loopback são aceites neste modo. Produção conserva STARTTLS autenticado e exige configuração operacional. Não usar credenciais de pessoas reais. O modo Capture grava ficheiros de email privados; não os publicar, anexar à issue nem servir por HTTP.

## Operações para a futura administração

Todas as rotas abaixo têm prefixo `/api/v1`; exigem sessão de administrador ativo, mesma organização e CSRF quando usam cookie. Bearer válido dispensa apenas CSRF, não autorização.

| Operação | Contrato e recuperação |
|---|---|
| POST `/admin/members` | Corpo atual com email, displayName e três flags de papel. 204; repetir exatamente a intenção original, pelo mesmo administrador, não cria nem reenvia. Corpo diferente para email existente é recusado. |
| GET `/admin/invitations?limit=50&after=<UUID>` | Página de 1–100 membros, `nextAfter`; inclui email/nome/papéis, Active, EmailConfirmed, Pending/Accepted/Cancelled, versão, entrega, tentativas/erro mínimo, validade do código, instantes e `resendAvailableAt`. Não inclui código, token ou ciphertext. |
| POST `/admin/members/{id}/invitation/resend` | `{ "commandId": "UUID novo", "expectedVersion": 1 }`; guardar corpo/chave para retry incerto. Invalida código anterior, persiste novo envio. |
| POST `/admin/members/{id}/invitation/cancel` | Mesmo envelope. Cancela convite pendente, invalida código, desativa membro; não cancela conta já aceite. |
| PUT `/admin/members/{id}` | Alterações administrativas existentes; desativar pendente cancela o convite. Reativar não reabre convite cancelado. Próprios papéis e remoção do último administrador continuam protegidos. |
| PUT `/admin/members/{employeeId}/manager` | `{ "managerId": "UUID de gestor distinto" }`, mecanismo existente. Listagem informa ManagerId e ManagerRelationshipValid, inclusive relação que perdeu validade após mudança de papéis. |

Repetição exata de reenvio/cancelamento retorna 204. `stale_invitation`/`idempotency_conflict`: 409; recarregar antes de criar outra intenção. `resend_limited`/`invitation_limit`: 429; respeitar instante/limite. Demais recusas usam códigos Problem Details, sem detalhe SMTP. A criação limita 20/hora/organização; emissão limita cinco/24h/convite e 60s de intervalo. Cancelamento é terminal: corrigir um convite cancelado não consiste em reativá-lo por SQL ou pedir código anónimo.

## Teste manual sintético

Preparar uma **base nova**, chaves/captura privadas e portas diferentes. Não reutilizar ou apagar bases/emuladores habituais. O ambiente que Codex deixar disponível é identificado no ficheiro privado `LER-PRIMEIRO.md`; os endereços e caminhos reais são entregues na conversa, nunca passwords/códigos no GitHub.

1. Administrador cria um colaborador e um chefe distintos pela API. Consultar lista: Pending/Sent, código válido uma hora; associar chefe ao colaborador. Guardar credenciais escolhidas e emails apenas no diretório privado.
2. Na Web, **Ainda não ativei a conta → Já tenho um código**. Introduzir email, código capturado e password válida. Entrar como colaborador e submeter pedido.
3. Android: mesmo percurso de aceitação para o chefe, na mesma instância de teste. Entrar, abrir pedido atribuído e decidir. Confirmar aprovação na Web. Ser administrador nunca autoriza autoaprovação.
4. Para reenvio/cancelamento, usar um terceiro convite ainda pendente. Esperar 60s, reenviar com versão/chave guardadas, repetir o corpo para confirmar no-op. O código anterior falha. Cancelar com versão atual e confirmar que ambos os códigos falham e que pedir ativação anonimamente não envia nada.

Aceitação não inicia sessão automaticamente. Código expirado não remove Pending; pedir novo código ou reenvio administrativo recupera-o, respeitando limites. Se já recebeu um código, o atalho permite usá-lo sem gerar outro. Mensagens SMTP em trânsito não podem ser recolhidas; o servidor recusa os códigos revogados.

## Checks reproduzíveis

Definir `HO_TEST_DATABASE` com PostgreSQL **de teste** que permita criar bases descartáveis; ler ligação privada sem imprimir a password. A suite cria/remove apenas `ho003_test_*` próprios, não a base indicada nem os dados habituais.

```sh
dotnet test apps/api/HomeOffice.slnx -c Release
python scripts/generate_contracts.py --check
python scripts/check_project.py
```

`InvitationTests`: lifecycle/limites/estado, criação concorrente/resposta perdida, replay, expiração Identity e guarda temporal, cancelamento/desativação, isolamento/chefia, leases concorrentes/abandonados, esgotamento e SMTP real loopback com 451/ack perdido. `OwnerBootstrapTests` mantém bootstrap legado/titular, preservação de credenciais/dados/sessões, chefe distinto, autoaprovação negada e proteção concorrente do último administrador.

Web: `npm run test:e2e:auth` e `npm run test:e2e` em `apps/web`, com `HO_DEV_ACCOUNTS` privado. Acrescenta aceitação real por cookie nos ecrãs desktop/estreito, usando os clientes gerados e email capturado.

Android: preparar API local descartável como documentado nos testes nativos (access=5s, refresh=30s) e acrescentar convite privado antes de executar o entrypoint de autenticação:

```sh
python scripts/prepare_invitation_test.py --base-url http://localhost:5080 --accounts /private/accounts.json --output /private/client-test.json
python scripts/wait_android_api.py --serial <emulador-descartavel> --port 5080
cd apps/mobile
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart --no-dds -d <emulador-descartavel> --dart-define=API_BASE_URL=http://10.0.2.2:5080 --dart-define-from-file=/private/client-test.json
```

O helper é loopback-only, cria uma conta sintética única e **não a ativa**. Códigos/passwords ficam no ficheiro privado, apenas consumido pelo entrypoint de teste; nunca compilar esse input para a app que se distribui. Repetir a suite exige novo convite, pois aceitação é consumível. O CI executa esta preparação e mantém os quatro checks obrigatórios.

`wait_android_api.py` exige HTTP 200 Healthy através de `10.0.2.2`, além da verificação anterior no host: boot completo não garante que a rede do emulador já esteja pronta. Retenta apenas esta leitura por prazo limitado e falha se continuar indisponível; não dispensa testes nativos nem repete mutations. O teste do formulário com HTTP simulado e o ensaio nativo são evidências distintas. No nativo, aguardar o foco/teclado após a transição de definição de password para login evita que uma atualização tardia de IME sobreponha o texto introduzido pelo teste.

A CI revelou também um Future de metadados sem consumidor enquanto Definições não estava montado. Fechar o cliente no logout podia completar esse pedido com erro não tratado. O resultado agora é capturado imediatamente, incluindo após dispose; falha renderiza offline e permite retry, nunca «Serviço ligado». `workspace_connection_test.dart` reproduziu os dois casos antes da correção e verifica recuperação sem perder sessão/calendário. Os testes de ligação real continuam a exigir dados válidos da API.

## Recuperação, limitações e operação futura

Corrigir SMTP/worker e aguardar retry, ou reenviar explicitamente se Failed/expirado. Não apagar conta para recuperar uma entrega. Sent é aceitação pelo adaptador, não prova de leitura; Captured/SMTP local não prova SMTP externo. Uma resposta SMTP perdida pode causar email duplicado com o **mesmo** código. O código fica cifrado apenas até envio confirmado/falha terminal/aceitação/cancelamento. Não há códigos em filas de planeamento, logs ou tracking.

A migração só acrescenta tabelas/índices e amplia a constraint de origem de auditoria. Aplicar antes da nova versão; backup/restauro operacional continuam HO-012. Reverter código mantendo as tabelas é possível; não executar Down após uso, pois removeria recibos e a constraint antiga não aceita auditoria anónima nova. Não reprocessar históricos nem reprovisionar identidades.

SMTP externo, HTTPS/Production, convites autorizados, administração autónoma HO-015 e piloto continuam por validar/entregar. PR #37 permanece draft. O proprietário reportou apenas conectividade Cloudflare Tunnel no Synology DS218+ (Celeron J3355, 2 GB, Docker), túnel `nas-connectivity-test`, sem hostname/rotas, ensaio terminado e sem alterações no router. HomeOffice não foi instalado/medido no NAS; nenhum alojamento pago foi escolhido/contratado. [Evidência reportada na issue operacional](https://github.com/Dennyum204/HomeOfficeReservation/issues/13#issuecomment-5626390006). Nenhum deployment/DNS/compra/email real/distribuição foi autorizado neste trabalho. iOS e Outlook continuam adiados.
