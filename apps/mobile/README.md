# Flutter Android — iOS adiado

HO-016 aplica a identidade Claude + com claro/escuro/sistema em **Definições → Aparência**. [Guia, capturas e comandos de revisão](../../docs/HO-016-VISUAL-THEME.md). `lib/theme` é verificado pelo formatter; cores geradas a partir de `design/tokens.json`, sem editar o Dart gerado.

HO-014: aceitar um convite em «Ainda não ativei a conta → Já tenho um código», com email, código Identity recebido e password escolhida. [Guia e preparação do teste nativo](../../docs/HO-014-INVITATIONS.md). Antes de executar `integration_test/app_test.dart`, preparar também o convite sintético com `scripts/prepare_invitation_test.py`; os campos TEST_INVITE_* ficam apenas no input privado de teste. O entrypoint normal não contém credenciais. Administração de convites permanece HO-015 (Web).

**Alvo atual: Android.** Em HO-005 o responsável adiou iOS. As configurações/comandos iOS abaixo são referência preservada, sem execução/debug nos trabalhos core. Reativação em HO-306, sem data; não é requisito de setup ou release.

Calendário e pedidos Android PT-PT para colaboradores e chefias, com mês/agenda, rascunhos, decisões parciais, revisões/contrapropostas e recuperação protegida. [Guia HO-010 e percurso com duas contas](../../docs/HO-010-ANDROID-PLANNING.md). HO-011 completa presenças/tarefas, confirmação por revisão, resolução e histórico; [matriz e percurso cruzado](../../docs/HO-011-CORE-ACCEPTANCE.md). Ligação real ao endpoint de metadados mantida. Login, ativação/recuperação, restauro, refresh limitado e logout próprios. Sem dados fictícios de calendário, aprovação, push ou Microsoft. [Setup Identity e credenciais privadas](../../docs/HO-003-AUTHENTICATION.md). Strings ARB em `lib/l10n/app_pt.arb`; `flutter pub get`/`flutter gen-l10n` geram código ignorado. Separação entre vista, repository e cliente Dart gerado, sem regras de negócio duplicadas.

## Ferramentas fixadas

- Flutter **3.47.2**, revisão `d3b14c876900e553bc736ca19295fc09e3853e8e`, Dart **3.13.2** incluído. `.flutter-version` e pubspec registam a versão; instalação oficial ou clone da tag. Não atualizar automaticamente durante o setup.
- Android: JDK Temurin **21.0.12+8**, compile SDK **37** (requisito flutter_secure_storage 11.0.0), target **36**, min **24**, NDK **28.2.13676358**, AGP **9.1.0**, Kotlin **2.4.0**, Gradle **9.3.1** com SHA-256. Target/min/NDK vêm dos defaults do Flutter fixado; compile SDK foi elevado para o plugin de secure storage. Android Studio/SDK e emulador são necessários para execução local.
- iOS: macOS e Xcode; CI usa **macos-15-intel/Xcode 26.3**, Simulator **iPhone 16 / iOS 18.6**, deployment target **iOS 15.0**. O build device continua ARM64. Assinatura/conta Apple só para dispositivos físicos/distribuição, não para compilar Simulator ou release sem assinatura. Não é possível compilar iOS em Windows/Linux.
- `pubspec.lock` da app e do cliente gerado são versionados. Nenhuma chave de assinatura no Git. Os identificadores `dev.homeoffice.*` são de desenvolvimento; confirmar distribuição em HO-012.

## Arranque

Com a [API](../api/README.md) na porta 5080, executar a partir da raiz:

```sh
cd apps/mobile
flutter pub get --enforce-lockfile
flutter devices
flutter run -d <device-id> --dart-define=API_BASE_URL=http://10.0.2.2:5080
```

Substituir `<device-id>` pelo ID devolvido por `flutter devices` e escolher a origem adequada:

| Destino | API_BASE_URL | Backend |
|---|---|---|
| Android Emulator no mesmo computador | `http://10.0.2.2:5080` | `dotnet run --project apps/api/src/HomeOffice.Api` |
| iOS Simulator no mesmo Mac | `http://localhost:5080` | Mesmo comando |
| Android físico por USB com `adb reverse tcp:5080 tcp:5080` | `http://127.0.0.1:5080` | Mesmo comando |
| Dispositivo físico ou Simulator num Mac diferente, mesma rede privada | `http://<IP-LAN-do-backend>:5080` | Acrescentar `--urls http://0.0.0.0:5080` |

O dispositivo e o computador têm de comunicar pela rede escolhida. Autorizar acesso de rede local no iOS quando solicitado; firewall apenas na rede privada. Não é necessário expor um túnel público. No Android físico por Wi-Fi, o IP do computador substitui `10.0.2.2`. Xcode/assinatura de desenvolvimento são necessários para instalar no iPhone físico.

Em debug, sem define, o Android usa 10.0.2.2 e iOS usa localhost. HTTP só é permitido nas configurações **debug** dos projetos nativos. Release exige `API_BASE_URL` explícito em HTTPS e mantém ATS/segurança de transporte; configuração inválida mostra erro, não sucesso. `https://api.example.invalid` nos builds CI é apenas um destino reservado para compilar, nunca deployment ou ligação real.

## Checks

Dentro de `apps/mobile`:

```sh
flutter pub get --enforce-lockfile
dart format --output=none --set-exit-if-changed lib/main.dart lib/config lib/features lib/theme test tool integration_test test_driver
flutter analyze
flutter test
dart run tool/smoke_api.dart http://localhost:5080
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.invalid
```

O smoke usa o mesmo repository e cliente gerado da app com HTTP real; verifica o contrato e um timestamp recente, sem emitir dados pessoais. Os widget tests usam respostas sintéticas e cobrem falha/retry/navegação/ecrã pequeno. Teste de plataforma com API/PG reais: primeiro seguir o guia HO-003 e iniciar API Development com access=5s/refresh=30s. Usar o ficheiro privado apenas neste entrypoint de testes; não distribuir o test bundle.

```sh
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart --no-dds -d <device-id> --dart-define=API_BASE_URL=http://10.0.2.2:5080 --dart-define-from-file=<private-dir>/client-test.json
```

No Mac, com Simulator:

```sh
flutter build ios --simulator --debug --dart-define=API_BASE_URL=http://localhost:5080
flutter build ios --release --no-codesign --dart-define=API_BASE_URL=https://api.example.invalid
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart --no-dds -d <simulator-id> --dart-define=API_BASE_URL=http://localhost:5080 --dart-define-from-file=<private-dir>/client-test.json
```

CI core exige análise/testes partilhados Flutter/Dart, cliente Dart contra Kestrel real, release Android sem assinatura e integração Android Emulator. Builds/testes iOS foram removidos da execução automática em HO-005 e preservados apenas em workflow manual opcional, não executado nesta tarefa. Não substitui ensaio físico, assinatura, lojas ou push, trabalhos posteriores. O APK release é unsigned; usar `flutter run` para instalar debug. Resultados efetivos e limitações em [STATUS](../../STATUS.md) e no PR.

O smoke executa os mesmos testes `integration_test` através do adaptador oficial [`integrationDriver`](https://api.flutter.dev/flutter/package-integration_test_integration_test_driver/integrationDriver.html), com `flutter drive --no-dds` (documentação consultada em 2026-09-08). No SDK fixado, `flutter test` falhou no arranque DDS e, sem DDS, na subscrição do stream de comparação de imagens, apesar de a asserção de ligação Android passar. O adaptador suportado evita esse mecanismo; mantém todas as asserções e devolve erro se qualquer teste falhar. Não modifica o SDK nem ignora falhas. A opção `--no-dds` consta de `flutter drive --help --verbose` e dispensa apenas o serviço auxiliar de debugging/IDE. As tentativas anteriores com erro não contam como checks verdes.

Na raiz, `python scripts/check_native_config.py` verifica XML/plists/UTF-8 e exceções de transporte só em debug. É um check prévio, não substitui compilação nativa. O bundle XCTest do template não contém exemplos vazios que aparentem testes passados; os asserts reais são Dart/Flutter.

HO-003 acrescenta `flutter_secure_storage` 11.0.0: refresh por origem API em armazenamento seguro, access em memória, passwords não persistidas. Android desativa backup; iOS declara Keychain entitlements, acessibilidade unlocked_this_device. Testes simulados cobrem refresh limitado, logout em corrida e membro desativado; integração nativa verifica armazenamento/restauro/expiração/logout contra API/PG. O plugin usa Swift Package Manager no template atual. Não foram validados assinatura, dispositivo físico ou loja.

## Caixa e push Android HO-007

Caixa real: páginas de 20, badge, filtros, leitura/não lida e detalhe autorizado. HO-010 liga notificações de pedidos/decisões ao pedido atual autorizado; HO-011 abre também presenças/tarefas atuais, sem referências técnicas ou fallback Web. Polling de 15 s pausa em background; as leituras idempotentes repetem uma vez após refresh Identity. O teste de expiração Android passa por background para não confundir atividade da caixa com sessão inativa; iOS não foi executado.

Correção HO-015: o planeamento recupera uma única vez uma escrita recusada explicitamente com 401 após preflight, revalidando a mesma sessão/ator e reutilizando corpo/chave. Nunca repete automaticamente 403, timeout, transporte ou 5xx. No ensaio nativo com access=5s/refresh=30s, `--dart-define=TEST_EXPIRE_PLANNING_WRITE=true` atrasa a primeira escrita seis segundos e exige rejeição real 401 seguida de sucesso; a CI ativa este teste adicional. Não usar esse define com a app normal nem com tokens de duração maior. [Evidência e limites](../../docs/HO-015-WEB-ADMINISTRATION.md).

FCM está desativado por defeito; [configuração privada, limites e evidência externa](../../docs/HO-007-NOTIFICATIONS.md). FirebaseAdmin/FlutterFire com versões fixadas; sem Firebase Auth, sem configuração real em Git. Só pedir permissão na ação de Definições. Recusa mantém a caixa. Registo expira após 24 h sem renovação; abrir diariamente. Logout offline mostra quando não foi possível confirmar remoção; IDs pendentes em armazenamento seguro, sem conservar credenciais da conta anterior. Entrega/abertura foreground/background/cold start e reconexão/troca de conta foram verificadas no emulador API 37.

[ADR-010](../../docs/adr/ADR-010-android-fcm-registration.md): o registo FID usa `register()`/`unregister()` do SDK Android por um pequeno MethodChannel, porque FlutterFire 16.6.0 expõe apenas o registo legado. Messaging 25.1.2/Installations 19.1.2 são dependências nativas explícitas. O serviço não exportado encaminha `onRegistered()` na thread principal; o receiver FlutterFire conserva mensagens/abertura. Callbacks repetidos são filtrados e a retoma renova o registo. `firebase_app_installations` foi retirado após erro real de threading; não editar a cache de plugins.

O teste `integration_test/fcm_live_test.dart` é **manual e externo ao core CI**. Requer configuração FCM real, contas sintéticas privadas e permissão previamente concedida. Comando e evidência no guia HO-007; usar `--keep-app-running` para impedir a desinstalação no fim pelo runner, e reinstalar depois o entrypoint normal sem credenciais de teste.

Teste nativo adicional (Android apenas, mesma API/PG/ficheiro privado do teste de autenticação):

```sh
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/notifications_test.dart --no-dds -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:5080 --dart-define-from-file=<private-dir>/client-test.json
```

Prova submissão gerada por colaborador, consumo real pelo worker, inbox da chefia, leitura sem decisão e detalhe/contexto; não usa Firebase. Os testes em `test/notifications_test.dart` simulam fornecedor/HTTP para recusa, rotação, logout e respostas atrasadas. iOS permanece adiado. O SDK Android atual emite avisos de migração Kotlin em plugins Firebase mantidos; não foram modificadas dependências para ocultar avisos.

## Planeamento Android HO-010

Datas isoladas e intervalos inclusivos, preview do servidor, rascunhos, submissão, filtros/paginação, retirada só de pendentes, decisões parciais e revisões. A localização confirmada nunca desaparece enquanto a alteração está pendente. Indisponibilidade manual usa o mesmo processo. O seletor de colaborador é autorizado pela API. No refinamento HO-016, o título e o colaborador selecionado integram o conteúdo com scroll, sem barra fixa.

`features/planning` separa vistas/controller/repository; só o cliente gerado serializa contratos. Input e envelopes de recuperação são cifrados por origem e conta via secure storage. Logout explícito elimina-os; expiração conserva input protegido para a mesma conta. Uma resposta de transporte perdida exige recuperar a chave/corpo originais. A retoma atualiza leituras, sem fila offline. [ADR-011](../../docs/adr/ADR-011-android-planning.md).

`integration_test/planning_test.dart` prova o percurso cinco/três/dois, revisão pendente e contraproposta até decisão final contra API/PG reais. `date_timezone_test.dart` verifica os dois limites DST com a zona real do dispositivo selecionada; `web_handoff_test.dart` completa o pedido criado pelo browser. O [guia HO-010](../../docs/HO-010-ANDROID-PLANNING.md) contém comandos e evidência separada das simulações. Usar o driver `test_driver/planning.dart` para screenshots sanitizados. O teste `planning_push_live_test.dart` é manual, com Firebase/contas privadas e permissão previamente concedida; nunca é gate do core.

## Interfaces core HO-011

Presenças/tarefas partilham colaborador, sessão e journal de escrita com o calendário. Formulários usam DTOs gerados, preview atual, versões esperadas e confirmação explícita; falhas conservam input protegido. O calendário abre o detalhe da presença e a resolução reutiliza propostas/aceitação/decisão. A caixa distingue abrir, ler e confirmar presença.

`integration_test/work_test.dart` percorre os novos workflows com API/PG reais sem Firebase. `cross_platform_test.dart` alterna com o browser, usando estado de ensaio privado. `work_push_live_test.dart` é externo ao core e requer configuração real, permissão explícita no dispositivo de teste e contas sintéticas. Comandos, limites e evidência no [guia HO-011](../../docs/HO-011-CORE-ACCEPTANCE.md). Restaurar sempre o entrypoint normal depois de testes com contas privadas.
# Preparação de distribuição privada HO-012

Package preservado: `dev.homeoffice.homeoffice_mobile`. `HO_ANDROID_SIGNING_PROPERTIES` aponta para properties e keystore absolutos **fora do repositório**; configuração ausente gera release unsigned, nunca assinatura debug automática. [Chave, HTTPS, Firebase, build e atualização](../../infra/pilot/README.md). O ensaio `python scripts/check_android_signing.py` usa uma chave descartável e não instala/distribui o APK. Piloto físico e FCM do futuro alojamento permanecem por validar. Não desinstalar a app existente para contornar assinatura diferente.

## Cabeçalhos e sessão HO-016

Calendário, Pedidos, Presenças/tarefas, Notificações e Definições começam com um título que acompanha o scroll. A identidade autenticada, email, organização, papéis e ações **Verificar sessão / Terminar sessão** estão apenas em **Definições → Conta e sessão**. O colaborador selecionado continua explícito nas áreas de planeamento, com o seletor da chefia. A validação ao retomar a aplicação, renovação, limpeza de dados privados/push e regras de acesso não dependem de abrir Definições.

O teste widget `test/workspace_session_test.dart` percorre todos os separadores em claro/escuro a 320 px e texto 100%/200%, áreas seguras, scroll, verificação manual, logout, limpeza do rascunho e troca de conta, seguida de recusa de sessão na retoma do Calendário. Usa HTTP e armazenamento de plataforma simulados. Os testes nativos partilham `integration_test/session_helpers.dart` para alcançar as ações pela interface. [Capturas e ensaio real](../../docs/HO-016-VISUAL-THEME.md).
