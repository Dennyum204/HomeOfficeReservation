# ADR-010 — Registo Android FCM por Firebase Installation ID

Data: 2026-09-10. Item: HO-007, [issue #8](https://github.com/Dennyum204/HomeOfficeReservation/issues/8), [PR #34](https://github.com/Dennyum204/HomeOfficeReservation/pull/34). Substitui apenas o mecanismo Android de registo/rotação de ADR-009; preserva worker, contratos, autorização e histórico.

## Evidência que motivou a alteração

Os ensaios com projeto e dispositivo autorizados revelaram falhas que os testes simulados e a compilação não detetavam:

1. `firebase_app_installations` 0.4.3 publicava `onIdChange` a partir da thread Firebase. FlutterJNI rejeitava a chamada fora da thread principal, interrompendo o registo. A stack observada coincide com o listener da versão oficial indicada nas fontes.
2. Obter um FID com Installations depois de `FirebaseMessaging.getToken()` não regista esse FID para envio. O primeiro envio respondeu `UNREGISTERED`; a API preservou a notificação interna, gravou falha permanente e desativou o dispositivo. Não contamos essa tentativa como entrega.
3. Num arranque normal com cache fria, ativar auto-init em modo FID chama `FirebaseMessaging.fetchFid` → `Tasks.await`. Na thread principal, `checkNotMainThread` rejeita a operação. O ensaio que inicializava Firebase antecipadamente escondia este caso; foi corrigido para usar o entrypoint normal.

## Decisão

Ativar `firebase_messaging_installation_id_enabled=true` no manifesto Android e usar as APIs oficiais `FirebaseMessaging.register()`/`unregister()`. FlutterFire 16.6.0 ainda expõe o percurso legado `getToken()`/`deleteToken()`, que é incompatível com o modo FID. Um pequeno `MethodChannel` Android liga Dart às APIs mantidas, sem implementar protocolos Firebase nem modificar a cache dos SDKs.

`register()` aguarda o registo FCM e só depois devolve o identificador obtido por Firebase Installations. `reset()` desativa auto-init, aguarda `unregister()` e elimina a instalação. As chamadas usam os SDKs já resolvidos pelo FlutterFire: Messaging **25.1.2** e Installations **19.1.2**, declarados explicitamente no Gradle para a compilação da ponte. FirebaseAdmin **3.6.0**, firebase_core **4.14.0** e firebase_messaging **16.6.0** mantêm-se fixados. O plugin Dart firebase_app_installations foi removido, incluindo as dependências transitivas exclusivas.

O serviço Android não exportado recebe `onRegistered()` e encaminha o FID na thread principal. A aplicação filtra callbacks repetidos com o mesmo FID para impedir que cada `register()` dispare outro registo em ciclo. A rotação real ou a retoma da app atualizam o backend. O receiver protegido FlutterFire continua responsável por receção, apresentação e abertura; não duplicamos mensagens em `onMessageReceived()`.

Auto-init continua desativado por defeito. A ponte de registo só é chamada pelo coordenador depois da permissão explícita; não é necessária configuração Firebase para arrancar/desenvolver/compilar o core. Segredos e configuração real permanecem externos. Erros do canal não incluem exceções com credenciais ou identificadores. Logout mantém revogação, versões e limpeza pendente de ADR-009.

## Alternativas e consequências

O handler nativo corre numa `makeBackgroundTaskQueue()` serial do Flutter para que o SDK possa aguardar Installations ao ativar auto-init. Os resultados assíncronos do canal podem ser emitidos de qualquer thread; a notificação inversa `onRegistered` é sempre encaminhada pela thread principal. A app permite tentar novamente um registo falhado sem retirar a opção de alertas. Diagnóstico debug inclui apenas etapa, classe de erro e código HTTP, nunca mensagem arbitrária ou endereço FCM.

Não voltar ao envio por tokens legados deprecados nem presumir que um FID existente já está registado para FCM. Esperar por um novo FlutterFire bloquearia um percurso já suportado pelo SDK Android. A ponte contém apenas adaptação de chamadas/callbacks e pode ser removida quando FlutterFire expuser estas APIs; nessa alteração será necessário repetir os testes reais.

Nenhuma alteração de DTO, OpenAPI, migração ou implementação iOS. Testes simulados cobrem falha do canal, callbacks repetidos e rotação ao retomar. O teste Android opcional `fcm_live_test.dart` exige projeto/configuração privados, duas contas sintéticas e permissão já concedida; nunca executa em CI normal. A evidência de entrega é separada da validação da ponte e da aceitação pelo fornecedor no [guia HO-007](../HO-007-NOTIFICATIONS.md).

## Fontes oficiais consultadas em 2026-09-10

- [Android: ativar FID e registar/remover](https://firebase.google.com/docs/cloud-messaging/android/get-started).
- [Gestão de registos FCM](https://firebase.google.com/docs/cloud-messaging/manage-tokens): `onRegistered`, sincronização, registos inválidos e diferença para tokens legados.
- [Fonte FirebaseMessaging](https://github.com/firebase/firebase-android-sdk/blob/master/firebase-messaging/src/main/java/com/google/firebase/messaging/FirebaseMessaging.java): incompatibilidade getToken/deleteToken com modo FID.
- [Plugin Installations 0.4.3, listener Android](https://github.com/firebase/flutterfire/blob/firebase_app_installations-v0.4.3/packages/firebase_app_installations/firebase_app_installations/android/src/main/kotlin/io/flutter/plugins/firebase/installations/firebase_app_installations/TokenChannelStreamHandler.kt) e [changelog](https://pub.dev/packages/firebase_app_installations/changelog).
- [Receção Flutter](https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages): foreground, background, abertura inicial e limitações de force-stop.
- [Flutter: handlers numa fila de background](https://docs.flutter.dev/platform-integration/platform-channels#execute-channel-handlers-on-a-background-thread-android) e [MethodChannel.Result](https://api.flutter.dev/javadoc/io/flutter/plugin/common/MethodChannel.Result.html).
