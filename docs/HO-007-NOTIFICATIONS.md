# HO-007 — Caixa de notificações e infraestrutura push Android

[Issue #8](https://github.com/Dennyum204/HomeOfficeReservation/issues/8) · [ADR-009](adr/ADR-009-durable-notifications.md) · [ADR-010](adr/ADR-010-android-fcm-registration.md). Web/Android; iOS, Outlook e lembretes/digests por email excluídos. A implementação interna funciona sem Firebase. **Entrega FCM real verificada no emulador Android**, com evidência e limites abaixo; [STATUS](../STATUS.md).

## Arranque e migração

Reutilizar os SDKs, PostgreSQL e contas privadas existentes conforme [HO-003](HO-003-AUTHENTICATION.md). Não voltar a provisionar nem apagar a base para este item. Fazer backup PostgreSQL antes de aplicar `20260909202903_DurableNotifications` com o comando explícito:

```sh
dotnet restore apps/api/HomeOffice.slnx --locked-mode
dotnet build apps/api/HomeOffice.slnx -c Release --no-restore
dotnet run --project apps/api/src/HomeOffice.Api -c Release --no-build -- --migrate
dotnet run --project apps/api/src/HomeOffice.Api --urls http://localhost:5080
npm --prefix apps/web run dev
```

Em terminal separado:

```sh
cd apps/mobile
flutter pub get --enforce-lockfile
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:5080
```

A API já carrega `appsettings.Local.json` privado. O [exemplo seguro](../apps/api/notifications.example.json) não é carregado automaticamente: serve para acrescentar a secção `Notifications` ao ficheiro privado, sem substituir a configuração Identity/DB. O default é worker ativo e fornecedor `Disabled`. Sem DB, readiness falha; o worker tenta recuperar e não anuncia entrega. Sem credenciais push, o core e a caixa continuam disponíveis.

## Eventos e destinatários

| Evento | Destinatário do servidor | Contexto atual |
|---|---|---|
| `planning.submitted` (inclui revisão) | Chefia atribuída no momento da submissão | Pedido submetido |
| `planning.withdrawn` | Chefia atribuída | Pedido retirado |
| `planning.decided` | Colaborador | Pedido com decisão atual |
| `planning.counterproposed` (inclui nova revisão) | Colaborador | Pedido e UUID da contraproposta |
| `planning.counterproposal-accepted` | Chefia atribuída | Novo pedido resultante, ainda sujeito a decisão |
| `onsite.created`, `onsite.edited`, `onsite.cancelled` | Colaborador | Presença atual, incluindo cancelada |
| `task.assigned`, `task.updated` | Colaborador | Tarefa atual |

Não notificar o próprio ator. Guardar destinatário na outbox (schema 2), resolver relações exclusivamente no backend e revalidar acesso no consumo/envio/leitura. Rascunhos, padrões, comentários, reconhecimento de presença e progresso de tarefa não geram alertas adicionais neste âmbito; a outbox regista processamento ignorado. Não existe seleção de destinatário no DTO.

## Caixa e duas contas

1. Na Web `http://127.0.0.1:5173`, entrar com o colaborador sintético privado. Submeter um pedido numa data livre. Noutro perfil/janela privada, entrar com a chefia atribuída e abrir **Notificações**. Aguardar até 15 segundos ou atualizar.
2. A chefia abre o contexto e decide os dias pretendidos. O colaborador recebe a decisão na sua caixa. **Marcar como lida** altera apenas o estado de leitura/badge; abrir não aprova nem marca automaticamente como lida.
3. A chefia cria uma presença ou atribui uma tarefa. O colaborador pode abrir o contexto atual pela caixa Web. Ler o aviso de presença não executa **Confirmar leitura** da presença.
4. No Android, entrar com uma destas contas e abrir **Notificações**. Filtrar, atualizar, abrir detalhe e marcar como lida/não lida. O detalhe conserva tipo/empregado/recurso/proposta no modelo; mostra referência e informa que o tratamento completo ainda se faz na Web (HO-010/011). Trocar de conta limpa a caixa anterior.
5. Em **Definições → Alertas no Android**, a versão normal explica que push não está configurado. Isto não é uma falha da caixa. Quando existir uma configuração real, a ação **Ativar alertas neste dispositivo** pede permissão Android. Recusar não impede nenhum fluxo interno.

Web e Android usam OpenAPI gerado, páginas de 20 (API máximo 100), filtros atuais/não lidas/arquivo, contagem separada e polling de 15 s sem pedidos sobrepostos, pausado quando ocultos. Rede indisponível mostra erro; Android preserva dados visíveis assinalados como possivelmente desatualizados. Sessão expirada exige novo login; respostas de uma conta anterior não repovoam o estado. A contagem é atual, não um contador de mensagens FCM.

## API

Base autenticada `/api/v1/notifications`. Cookies Web exigem CSRF nas escritas; Android usa bearer Identity. Parâmetros/contextos são verificados no servidor:

- `GET /?offset=0&limit=20&unreadOnly=false&historical=false`, `GET /unread-count`, `GET /{id}`.
- `PUT /{id}/read` com `{ "read": true }`, idempotente, sem transição de negócio.
- `GET /capabilities` retorna `Disabled`, `Local` ou `Fcm`.
- `PUT /devices`: `installationId` aleatório local, `provider`, `address`, `expectedVersion` na rotação. Propriedade por organização/membro, endereço cifrado por Data Protection, índice único de hash para endereços ativos. Não registar valores em logs.
- `DELETE /devices/{installationId}`: remoção repetível e sem enumeração entre contas. Grava tombstone mesmo quando o registo inicial ainda não chegou; UUID revogado nunca é reativado. Reconectar usa UUID novo.
- `PUT /{id}/device-receipt` com UUID da instalação: recibo autenticado, não marca leitura. Recibo observado em foreground ou abertura; Android em background não executa um handler de telemetria para afirmar receção antes de o utilizador abrir.
- `GET /operations` e `POST /operations/retry` são apenas para administrador de contas da organização. Retry recebe `{ "id": "<UUID real da falha>", "push": false }`; `true` seleciona entrega push. Só aceita linhas em falha permanente, preserva o histórico e volta a verificar contexto/idade/permissões.

## Histórico, leases e recuperação

Migração aditiva: novas tabelas `InboxNotification`, `PushDevice`, `PushDelivery` e colunas de processamento na `PlanningOutbox`. Contas, planos, auditoria e outbox anteriores mantêm-se. O backup local anterior à migração fica fora de Git. Não usar `Down` como rollback operacional: apagaria notificações novas. Recuperação preferida: parar worker, corrigir e avançar; restauro só mediante decisão explícita e backup, pois perderia alterações posteriores.

Na migração, **todos os eventos existentes** ficam históricos. Os não entregues passam pelo worker para arquivo sem push nem badge; schema 1 continua sempre arquivo mesmo se reprocessado. Eventos desconhecidos ficam `Ignored/event_not_notifiable`; destinatário ou contexto removido fica `Ignored/recipient_unavailable` ou `context_unavailable`. JSON inválido fica `Failed/invalid_event`. Não apagar nem reenviar em massa eventos antigos. Contextos eliminados após entrega deixam apenas aviso genérico/sem destino. Datas de criação do evento e estado histórico não são alterados num retry.

Valores default: lote 20, polling worker 3 s, lease 120 s, 5 tentativas. Claims usam locks PostgreSQL e dono de lease; workers concorrentes obtêm linhas distintas. Notificação + intenções + conclusão interna partilham commit. Falhas transitórias tentam novamente com atraso limitado; cinco crashes/tentativas esgotam a linha. Um administrador identifica e corrige a causa antes de repetir uma **linha específica**. O lease deve exceder o timeout externo de 15 s. O worker só reclama um envio imediatamente antes de o tentar.

`ProcessingState`: Pending=0, Leased=1, Processed=2, Ignored=3, Failed=4. `PushState`: Pending=0, Leased=1, ProviderAccepted=2, Simulated=3, Suppressed=4, Failed=5. `DeliveredAt` legado é preenchido juntamente com `ProcessedAt`, significando processamento interno, nunca receção Android. Não apagar uma notificação porque o fornecedor falhou. Push só para eventos atuais com idade até uma hora e dispositivos já registados quando o evento ocorreu; sem replay para dispositivos novos. TTL Android de uma hora e tag=UUID interno reduzem avisos antigos/duplicados, sem garantia de exatamente uma entrega.

Observar os contadores `/operations` e códigos de falha. Para obter IDs concretos num acesso operacional autorizado, consultas mínimas por organização (substituir parâmetro num cliente SQL, não publicar resultados privados):

```sql
SELECT "Id", "Type", "State", "Attempts", "LastError", "LeaseUntil"
FROM "PlanningOutbox" WHERE "OrganizationId" = :organization_id AND "State" = 4;
SELECT "Id", "State", "Attempts", "LastError", "LeaseUntil"
FROM "PushDelivery" WHERE "OrganizationId" = :organization_id AND "State" = 5;
```

Não selecionar Payload, ProtectedAddress, AddressHash, emails ou credenciais para diagnóstico público. `Notifications__WorkerEnabled=false` permite pausa operacional mantendo API/caixa. Reativar após corrigir DB/configuração/chaves. Conservar Data Protection keys: perder essas chaves exige voltar a registar dispositivos e também afeta Identity. Se o fornecedor indicar `Unregistered`, o dispositivo é desativado; reconectar em Definições. Falha de credencial/projeto exige corrigir configuração privada; retry não cria permissões no fornecedor.

## Adaptador local, explicitamente simulado

Definir `Notifications__PushProvider=Local` apenas em Development/Testing. Registar por API autenticada um endereço sintético `local:` seguido de UUID aleatório; executar novo evento de negócio. O worker grava `Simulated`, sem rede externa, sem `ProviderAcceptedAt` e sem prova de receção. Os testes PostgreSQL fazem este percurso automaticamente e injetam falhas/crashes do fornecedor. O adaptador local não apresenta avisos Android falsos nem substitui a integração FCM.

## FCM real — preparação separada e privada

Não é um requisito de arranque ou CI normal. Não existe projeto Firebase, credencial ou consentimento presumido. O ensaio externo requer estas ações, guiadas uma de cada vez quando a implementação/testes estiverem prontos:

1. Confirmar acesso a [Firebase Console](https://console.firebase.google.com/) e escolher/criar **um projeto de teste autorizado**. Não é preciso uma conta Microsoft. Não habilitar Analytics, Authentication, Firestore ou outros serviços para esta tarefa.
2. Em **Project settings → General → Your apps → Add app → Android**, package **`dev.homeoffice.homeoffice_mobile`**, nickname livre (por exemplo `HomeOffice Android Test`). FCM não requer SHA de assinatura para este fluxo. Guardar `google-services.json` **fora do repositório**; não colar o conteúdo no chat. Usamos recursos nativos para cold start/background; não executar um `flutterfire configure` que escreva configuração real no repo.
3. Confirmar **Project settings → Cloud Messaging → Firebase Cloud Messaging API (V1)** enabled. Servidor usa ADC; preferir credencial de ambiente/identidade federada quando disponível. Para teste local, uma service account autorizada com `Firebase Cloud Messaging API Admin` (`roles/firebasecloudmessaging.admin`) no projeto pode fornecer JSON privado externo se a política permitir. Não pedir Owner amplo nem assumir que download/criação de chaves é permitido. Não colocar credenciais no APK.
4. Terminal API privado: definir `GOOGLE_APPLICATION_CREDENTIALS` para esse ficheiro, `Notifications__FirebaseProjectId` para o Project ID real e `Notifications__PushProvider=Fcm`, preservando toda a configuração Identity/PostgreSQL. Reiniciar apenas a instância API existente.
5. Terminal Flutter privado: definir `HO_FIREBASE_ANDROID_CONFIG` com caminho absoluto externo do `google-services.json`. Compilar/instalar com `--dart-define=FCM_ENABLED=true` e a origem API correta. O plugin Google Services 4.5.0 lê diretamente esse ficheiro; rejeita caminhos dentro do repo. Sem variável/define, a compilação core continua normal.
6. Android com Google Play services, Internet e API alcançável (emulador Google APIs ou dispositivo autorizado). Entrar na conta sintética selecionada; em Definições ativar alertas e conceder a permissão no próprio Android. O registo expira em 24 h sem renovação; abrir a aplicação diariamente. Nenhuma confirmação de permissão ou entrega é feita antecipadamente.

Exemplos PowerShell apenas com placeholders (usar os caminhos/ID privados confirmados, nunca copiar segredos para Git):

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS = 'C:\private\homeoffice\service-account.json'
$env:Notifications__FirebaseProjectId = '<project-id-confirmado>'
$env:Notifications__PushProvider = 'Fcm'
# Iniciar a API como no guia. Noutro terminal, a partir de apps/mobile:
$env:HO_FIREBASE_ANDROID_CONFIG = 'C:\private\homeoffice\google-services.json'
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:5080 --dart-define=FCM_ENABLED=true
```

FirebaseAdmin 3.6.0 usa `Message.Fid`. O manifesto ativa o modo FID; a ponte Android chama `FirebaseMessaging.register()` antes de devolver o identificador. `onRegistered()` atravessa a thread principal e callbacks iguais não repetem registos. Retoma/renovação também consultam o FID atual. Logout revoga na API e usa `unregister()`/eliminação da instalação no SDK. O plugin Dart Installations 0.4.3 foi retirado após uma falha real de threading. [ADR-010](adr/ADR-010-android-fcm-registration.md) preserva causas, versões e fontes. Sem rede podem chegar avisos genéricos até revogação/expiração, incluindo mensagens em trânsito; uma conta nova usa nova instalação e nunca lê a caixa anterior.

## Ensaio externo e evidência — 2026-09-10

Após configuração **real** e seleção/consentimento do utilizador: gerar apenas novos eventos sintéticos através das contas autorizadas; verificar foreground, background e cold start após sessão restaurada/login; confirmar texto genérico, detalhe autorizado e ausência de comandos de negócio; testar permissão recusada, rotação/reconexão e logout/troca de conta. Conservar só cenário, data UTC, plataforma, versão/commit, resultado e contagens de aceitação/recibo, sem endereços do dispositivo, tokens, payloads ou conteúdo privado. Verificar `ProviderAcceptedAt` e, separadamente, callback/abertura e `DeviceReportedAt`. Uma aceitação FCM sem observação no dispositivo não satisfaz entrega real.

`python scripts/check_fcm_build.py` compila os recursos FCM usando um ficheiro sintético temporário externo, sem instalar ou enviar. O plugin recebe esse caminho após a configuração das variantes Android.

Projeto de teste criado pelo responsável, package confirmado, FCM V1 ativo e service account com papel de envio. Os dois ficheiros reais foram validados e guardados fora do repositório; chave de servidor acessível apenas ao utilizador Windows e SYSTEM. O responsável concedeu a permissão Android. Não se publicam projeto, chave, endereços, payloads ou ficheiros de configuração reais.

Emulador Android 17/API 37 com Google Play services; API/worker/PostgreSQL reais; tarefas novas identificadas como ensaios, sem alterar tarefas, pedidos ou planos pré-existentes. Horas abaixo em **UTC de 2026-09-09** (já 2026-09-10 em Zurique):

| Cenário real | Aceitação FCM | Recibo autenticado do dispositivo | Observação |
|---|---|---|---|
| Primeira tentativa antes da correção | Não | Não | `UNREGISTERED`, falha preservada; notificação interna mantida e dispositivo revogado |
| Foreground | 22:21:36.236 | 22:21:36.857 | Aviso na app e abertura de detalhe autorizado |
| Background | 22:22:26.073 | 22:22:59.790 | Texto genérico observado na barra Android; sem recibo antes de abrir |
| Cold start | 22:23:50.484 | 22:24:15.849 | Processo ausente antes do envio (`am kill`, sem force-stop); abertura restaura sessão e detalhe |
| Após reinício/reconexão | 22:49:15.801 | 22:49:15.877 | Entry point normal, registo confirmado e novo aviso foreground observado |

Cada entrega bem-sucedida acima teve uma tentativa; isso não constitui promessa de exatamente uma entrega. Abrir manteve as notificações não lidas e não executou decisões. Apenas resultados sanitizados são versionados.

O reinício normal revelou que ativar auto-init FID podia aguardar Installations na thread principal. A ponte passou a usar a fila background oficial do Flutter; os callbacks continuam na thread principal. A repetição após reinício passou. O teste de ciclo de conta também foi repetido sem inicializar Firebase antecipadamente, para exercitar o mesmo arranque da app. O estado de erro oferece “Tentar novamente”, com diagnóstico debug limitado a etapa, classe de erro e código HTTP.

O teste nativo opcional `integration_test/fcm_live_test.dart` passou contra FCM/API/PostgreSQL: desativar, negar reativação do UUID revogado, reconectar com novo UUID, logout, entrar como chefia, negar leitura da notificação do colaborador, registar/remover a chefia e regressar ao colaborador. Usa permissão **previamente concedida**; não concede consentimento por código. O ensaio foi repetido após ajustar o runner: `flutter drive` sem `--keep-app-running` desinstala a aplicação no fim, mesmo em falha. A instalação/permissão anteriormente autorizada foram restauradas e apenas o registo órfão conhecido foi revogado pela API. As tentativas falhadas do runner não contam como checks passados.

Com permissão concedida, contas sintéticas autorizadas e configuração privada definida:

```powershell
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/fcm_live_test.dart --no-dds --keep-app-running -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:5080 --dart-define=FCM_ENABLED=true --dart-define-from-file=<private-dir>/client-test.json
# Repor sempre o entrypoint normal; não distribuir o bundle com contas de teste.
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:5080 --dart-define=FCM_ENABLED=true
```

Compilação sintética, simulações de canal/fornecedor e ensaios reais continuam separados. Recusa de permissão, logout offline, crashes/duplicados e registos atrasados são cobertos por simulações/testes PostgreSQL, não por afirmações de entrega externa nesses cenários. Não foram validados dispositivo físico, fabricante/modo de bateria, lojas, assinatura release, iOS, redes de produção nem recuperação após perda das chaves. A lease de 24 h exige abrir a app diariamente. A receção em background só é reportada ao abrir. Force-stop pelo utilizador pode impedir entrega até reabrir. Issue #8 permanece aberta até revisão/merge e verificação de integração; o PR só sai de draft com CI final verde e sem conflitos.
