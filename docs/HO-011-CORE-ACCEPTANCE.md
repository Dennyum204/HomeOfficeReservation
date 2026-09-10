# HO-011 — Interfaces core e aceitação Web/Android

Data: 2026-09-10 · [issue #12](https://github.com/Dennyum204/HomeOfficeReservation/issues/12) · [PR #36](https://github.com/Dennyum204/HomeOfficeReservation/pull/36) · branch `feat/ho-011-core-integration`, em revisão, sem merge.

## Âmbito

Android completa presenças e tarefas com os contratos de HO-006: lista, filtros/páginas, detalhe, comentários e histórico. A chefia cria/pré-visualiza/edita/cancela presenças para colaboradores autorizados; o colaborador confirma a revisão específica. O calendário abre a presença e conserva remoto aprovado enquanto existir conflito. A chefia propõe resolução, o colaborador aceita e a chefia decide a revisão resultante.

Tarefas mostram prazo, estado, necessidade de presença e ligação atual. A chefia atribui/edita; o colaborador altera apenas progresso permitido. Cancelar/editar a presença ligada não altera estado/prazo da tarefa. NeedsResolution, leitura, progresso e aprovação são conceitos distintos.

Inbox e push abrem os detalhes autenticados atuais, sem marcar leitura ou tomar decisões. Conta autenticada e colaborador selecionado têm rótulos separados. **Pedir os meus dias de trabalho** é diferente de **Exigir presença do colaborador**. Na Web estreita, o detalhe aparece antes da lista e recebe foco; fechar devolve o foco à lista. Android usa scroll, voltar e formulários localizados; input permanece protegido em erros recuperáveis.

Sem mudança de API, OpenAPI, migração ou dependências. [ADR-012](adr/ADR-012-core-interfaces.md) documenta a extensão do journal existente. A API continua a decidir autorização, transições e concorrência.

## Base integrada

PR #35 integrado em main em 2026-09-10T17:17:47Z, commit `96cf3c3e06a6f753c29e3295875593a5370101da`, confirmado no histórico obtido por fetch. [Documentação](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34507336388) e [core](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34507336432) passaram após integração. HO-010 foi reconciliado para done nesta branch. HO-005/006/007 têm PRs #32/#33/#34 integrados e CI aplicável, preservada no [histórico de estado](history/HO-011-status-before-reconciliation.md). Nada foi integrado automaticamente.

## Matriz de aceitação corrente

Estes ensaios usam contas locais sintéticas já autorizadas, API real e PostgreSQL portátil 18.6. O emulador existente `HO010_Test` usa Android API 37; CI usa API 35. Nenhuma conta, configuração privada, plano pré-existente ou imagem de emulador foi apagada. Os ensaios só escrevem novos registos sintéticos em datas livres.

| Percurso | Evidência executada nesta tarefa | Resultado |
|---|---|---|
| Pedido Web de cinco dias; chefia aprova três Android | `tools/core-acceptance.mjs create` + `cross_platform_test.dart planning` | Real, passou; ambos os papéis consultam três aprovações e dois pendentes |
| Colaborador retira dois Android | Mesmo ensaio, seguido de fase Web `onsite` | Real, passou; três aprovações preservadas e zero pendentes |
| Revisão conserva aprovação até decisão | Fase Web `proposal`, Android `resolve` | Real, passou; aceitação produz revisão pendente, ainda com remoto aprovado |
| Presença Web sobre remoto; leitura Android | Fase Web `onsite`, Android `acknowledge` | Real, passou; leitura por revisão sem mudar plano |
| Proposta Web → aceitação/decisão Android | Fases `proposal`/`resolve` e verificação Web `task` | Real, passou; um dia presencial, outros dois remotos, presença Active |
| Tarefa ligada Web → progresso Android | Fases `task`/`progress`/`verify` | Real, passou; ambos os papéis Web veem progresso e ligação; calendário inalterado |
| Criar, editar e cancelar presença; revisão de leitura; resolução; tarefa/comentário Android | `integration_test/work_test.dart` | Real, passou; revisão 2 invalida leitura antiga, cancelamento mantém tarefa Em curso e aprovação |
| Caixa com permissão recusada | `work_push_live_test.dart`, fase `denied` | Real, passou após escolher Don’t allow no diálogo Android de teste; caixa e detalhe continuam utilizáveis |
| Destinos Requirement/Task e duplicação; logout; 403/404 e colaborador não atribuído | `test/work_widget_test.dart` e `test/work_test.dart` | HTTP/widgets simulados, passaram; zero escritas ao abrir, detalhe antigo eliminado e dados eliminados no logout |
| Journal incerto, stale, input, resposta atrasada | `test/work_test.dart` + testes de HO-010 mantidos | Simulados, passaram; replay exato e um efeito; revisão explícita; isolamento |
| Android 320 px, texto 100%/200%, formulário e voltar | `test/work_widget_test.dart` + `planning_widget_test.dart` | Widgets simulados, passaram, sem overflow |
| Autorização, concorrência, idempotência, transições e datas | 47 testes PostgreSQL + 4 testes API | Reexecutados, passaram, zero skips; contratos idênticos (172 ficheiros gerados) |
| FCM real foreground de presenças/tarefas | `work_push_live_test.dart` com configuração privada existente | Real, passou; callbacks FCM abriram recurso atual, leitura/progresso/calendário inalterados |
| FCM background de tarefa | App normal, Home, tarefa sintética criada na API, notificação real Android tocada | Real, passou; recibo do dispositivo, detalhe correto; tarefa Todo/versão 1 e notificação não lida |
| FCM cold start de presença | App normal em background, presença sintética criada, processo terminado com `am kill`, notificação real tocada | Real, passou; processo ausente antes/sessão restaurada, recibo do dispositivo, recurso/calendário idênticos, revisão 1 ainda sem leitura |
| FCM e mudança de conta | `integration_test/fcm_live_test.dart` com configuração privada | Real, reexecutado e passou; desligar/religar revoga binding anterior, chefia recebe 404 para notificação do colaborador, registo isolado após regresso à conta |
| Quatro checks remotos no commit final | project-docs, backend-contracts, web, flutter-android | SHA, links e resultados no [recibo de entrega do PR](https://github.com/Dennyum204/HomeOfficeReservation/pull/36#issuecomment-5623557694); draft só pode ser retirado após os quatro verdes e ausência de conflitos |

Os testes de datas Lisboa/Zurique/DST e de sessão nativa de HO-010 continuam nos quatro gates CI. O ensaio atual de resolução inclui datas date-only; os testes dedicados de zonas/sessão só contam como reexecutados quando o respetivo job remoto passar. Sem validação física, loja, produção, iOS ou Graph.

Execuções locais finais: análise Flutter limpa e **34 testes unit/widget**, Web format/typecheck/lint e **13 testes unit/build**, **4 testes browser de autenticação + 18 de planeamento/presenças** (14 passaram na execução completa; os quatro de presenças passaram novamente após corrigir a paginação do helper de teste). Na CI a suite completa é executada de novo. Um teste Web encontrou mais de 25 tarefas sintéticas acumuladas; o helper agora percorre as páginas reais, sem limpar dados nem retirar asserções. Os 47 testes PostgreSQL + 4 API passaram sem skips; os 172 ficheiros gerados coincidem. O build Release local encontrou DLLs ocupadas pela API em execução: a API foi reiniciada em Debug com a mesma configuração/base, e o build Release passou sem avisos.

### Capturas sintéticas

- [Android: presença com conflito](evidence/ho011/android-onsite-conflict.png) e [tarefa ligada](evidence/ho011/android-linked-task.png).
- [Web chefia: progresso vindo do Android](evidence/ho011/web-manager-task.png) e [Web estreita, colaborador](evidence/ho011/web-employee-task-narrow.png).
- [Android: FCM foreground](evidence/ho011/android-task-fcm.png), [tarefa aberta do background](evidence/ho011/android-task-background.png) e [presença após cold start](evidence/ho011/android-onsite-cold.png).

As capturas Web usam diretamente o elemento do detalhe para não incluir outros registos locais. A fase `capture` consulta a tarefa atual de uma passagem já concluída, sem repetir nem reivindicar novamente a aceitação cinco/três/dois. Essa aceitação exige `verify` imediatamente após as fases anteriores: mais tarde outro ensaio autorizado usou uma das datas retiradas, e a repetição de `verify` recusou corretamente o calendário já alterado. Não se apagaram esses dados para obter uma captura.

## Percurso manual com duas contas

Reutilizar as contas privadas indicadas pelo [setup Identity](HO-003-AUTHENTICATION.md). Não publicar passwords nem executar provisionamento de novo num ambiente já preparado.

1. **Colaborador Web:** Pedidos → Pedir os meus dias de trabalho. Escolher cinco dias úteis livres, pré-visualizar/adicionar intervalo, Guardar rascunho, Submeter pedido → Confirmar envio.
2. **Chefia Android:** confirmar Conta com sessão iniciada, selecionar o colaborador em Pedidos, abrir o pedido, selecionar só três dias → Aprovar dias → confirmar o resumo. No Web, atualizar: três aprovados/dois pendentes.
3. **Colaborador Android:** abrir pedido, selecionar pendentes → Retirar dias pendentes → confirmar. Os três aprovados mantêm-se.
4. **Chefia Web:** Presenças → Exigir presença do colaborador, numa data remota aprovada. Motivo/local/datas → Pré-visualizar conflitos → Confirmar presença. Deve ficar Por resolver; o remoto mantém-se.
5. **Colaborador Android:** Presenças/tarefas → Presenças → Abrir detalhe → Confirmar leitura desta revisão → confirmar resumo. O plano ainda é remoto. Alterar a presença cria uma nova revisão que precisa de leitura própria.
6. **Chefia:** no detalhe da presença, Propor resolução do plano (Web) ou Propor resolução deste pedido (Android). Rever contraproposta presencial. O colaborador aceita em Pedidos; a chefia abre a nova revisão e aprova. Só então a data passa a presencial e a presença fica Ativa.
7. **Chefia Web:** no detalhe, Atribuir tarefa. **Colaborador Android:** abrir em Tarefas → Atualizar progresso → Em curso, nota → Rever antes de enviar → confirmar. Atualizar Web e verificar a ligação. Ler uma notificação não realiza nenhuma destas ações.

## Reproduzir os ensaios

Arranque normal, sem Microsoft/Firebase:

```sh
dotnet run --project apps/api/src/HomeOffice.Api
npm --prefix apps/web run dev
cd apps/mobile
flutter run -d <device-id> --dart-define=API_BASE_URL=http://10.0.2.2:5080
```

Usar SDKs fixados e o PostgreSQL/configuração existentes; comandos completos nos guias [API](../apps/api/README.md), [Web](../apps/web/README.md) e [Android](../apps/mobile/README.md). Na máquina Windows preparada, carregar `.git/ho002-env.ps1` antes dos comandos. Esse helper é local, não parte do clone público. Verificar processos/portas antes de iniciar uma segunda API.

Dentro de `apps/mobile`, sem Firebase, com API e ficheiro privado de contas sintéticas:

```sh
flutter drive --driver=test_driver/planning.dart --target=integration_test/work_test.dart --no-dds --keep-app-running -d <device-id> --dart-define=API_BASE_URL=http://10.0.2.2:5080 --dart-define-from-file=<private-dir>/client-test.json
```

Para passagem entre plataformas, definir `HO_DEV_ACCOUNTS=<private-dir>/accounts.json` e `HO_CROSS_STATE=<private-dir>/ho011-cross.json`. O script recusa guardar estado dentro do repositório. Não reutilizar uma passagem já criada como se fosse nova; conservar o estado para concluir/verificar a mesma passagem.

| Ordem | Diretório/comando |
|---|---|
| 1 | `apps/web`: `node tools/core-acceptance.mjs create` |
| 2 | Android: fase `planning` |
| 3 | `apps/web`: `node tools/core-acceptance.mjs onsite` |
| 4 | Android: fase `acknowledge` |
| 5 | `apps/web`: `node tools/core-acceptance.mjs proposal` |
| 6 | Android: fase `resolve` |
| 7 | `apps/web`: `node tools/core-acceptance.mjs task` |
| 8 | Android: fase `progress` |
| 9 | `apps/web`: `node tools/core-acceptance.mjs verify` |

Cada fase Android usa:

```sh
flutter drive --driver=test_driver/planning.dart --target=integration_test/cross_platform_test.dart --no-dds --keep-app-running -d <device-id> --dart-define=API_BASE_URL=http://10.0.2.2:5080 --dart-define=TEST_CORE_PHASE=<fase> --dart-define-from-file=<private-dir>/client-test.json --dart-define-from-file=<private-dir>/ho011-cross.json
```

Os testes native/UI não apagam fixtures anteriores. Se já não houver datas livres, param. Os bundles de teste incorporam as credenciais privadas apenas localmente: não distribuir, não guardar no Git, e reinstalar depois `flutter run` com `lib/main.dart`, sem defines de contas. Usar `--keep-app-running` evita desinstalação e perda de dados/definições do emulador pelo runner; não transforma o bundle de teste numa build normal.

## Push e evidência externa

Reutilizar exclusivamente o [setup privado de HO-007](HO-007-NOTIFICATIONS.md), com `HO_FIREBASE_ANDROID_CONFIG` externo e ADC no backend. O core e CI não exigem credenciais. `work_push_live_test.dart` usa mensagens reais de presenças/tarefas novas, callback FCM e o botão do aviso foreground; consulta o recurso/estado de leitura depois de abrir. Só executar com permissão preparada no dispositivo selecionado. A fase `denied` exige recusa real do Android; não aceita “not determined” como recusa.

```sh
flutter drive --driver=test_driver/planning.dart --target=integration_test/work_push_live_test.dart --no-dds --keep-app-running -d <device-id> --dart-define=API_BASE_URL=http://10.0.2.2:5080 --dart-define=FCM_ENABLED=true --dart-define-from-file=<private-dir>/client-test.json
```

Para o ensaio de recusa acrescentar `--dart-define=TEST_CORE_PHASE=denied`. O teste não concede permissão nem recria o projeto Firebase. Registar separadamente aceitação do fornecedor, callback/recibo e abertura; um HTTP 200 do fornecedor não prova entrega. Background/cold start e mudança de conta precisam da evidência externa explícita, não de um deep link inventado.

Procedimento background/cold start executado nesta entrega: restaurar `lib/main.dart` com configuração Firebase privada, sem defines de contas; iniciar sessão como colaborador sintético e enviar a app para Home. A chefia cria uma tarefa/presença sintética pela API existente. Confirmar a notificação genérica na barra Android. No caso cold start, terminar o processo em background com `adb shell am kill dev.homeoffice.homeoffice_mobile` e confirmar `pidof` vazio, sem limpar dados nem usar force-stop. Tocar na notificação real, observar o detalhe correto e comparar recurso/calendário/leitura antes/depois. A aceitação do fornecedor e o recibo autenticado do dispositivo são evidências separadas. O registo privado guardou identificadores/snapshots; o Git contém apenas resultados e capturas sintéticos.

O ensaio `fcm_live_test.dart` foi reexecutado para desligar/religar, trocar colaborador→chefia→colaborador e verificar o 404 ao tentar abrir uma notificação da outra conta. O projeto, chaves e registos de outros dispositivos foram preservados. Uma instalação anterior offline também era elegível para a conta sintética: a aceitação FCM dessa instalação não foi contada como recibo; apenas o emulador aberto reportou receção nestes ensaios.

## Limites e recuperação

Uma falha de armazenamento impede a escrita. Um resultado incerto bloqueia nova intenção até recuperação com chave/corpo originais. Depois de versão stale, atualizar e rever os dados antes de confirmar outra intenção. Input protegido não equivale a submissão offline. Uma presença/tarefa indisponível não reapresenta um detalhe antigo como se fosse o destino pedido.

Não há rollback de migração em HO-011 porque não existe migração. Repor o cliente anterior preserva dados no backend, mas recupera as limitações de interface anteriores. Não limpar contas, base, keyring, configuração Firebase ou armazenamento do emulador para resolver problemas de arranque.

O projeto continua sem alojamento/distribuição/piloto: **HO-012 — hosting, operational readiness and pilot preparation** é o próximo trabalho, apenas após merge humano verificado. iOS/HO-306 e Outlook/HO-008/009 continuam adiados.

## Fontes oficiais consultadas em 2026-09-10

- [Flutter — validação de formulários](https://docs.flutter.dev/cookbook/forms/validation): Form/validator e apresentação de erros.
- [Flutter — testes de integração](https://docs.flutter.dev/cookbook/testing/integration/introduction): execução no alvo real, distinta de widget tests.
- [Firebase — receção Flutter](https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages): permissão, foreground, background, mensagem inicial e limites de force-stop. A implementação nativa FID existente mantém as decisões do ADR-010.
