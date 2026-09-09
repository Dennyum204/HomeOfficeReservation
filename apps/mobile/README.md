# Flutter Android — iOS adiado

**Alvo atual: Android.** Em HO-005 o responsável adiou iOS. As configurações/comandos iOS abaixo são referência preservada, sem execução/debug nos trabalhos core. Reativação em HO-306, sem data; não é requisito de setup ou release.

Shell PT-PT equivalente à Web: navegação, estados em preparação e ligação real ao endpoint de metadados. Login, ativação/recuperação, restauro, refresh limitado e logout próprios. Sem dados fictícios de calendário, aprovação, push ou Microsoft. [Setup Identity e credenciais privadas](../../docs/HO-003-AUTHENTICATION.md). Strings ARB em `lib/l10n/app_pt.arb`; `flutter pub get`/`flutter gen-l10n` geram código ignorado. Separação entre vista, repository e cliente Dart gerado, sem regras de negócio duplicadas.

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
dart format --output=none --set-exit-if-changed lib/main.dart lib/config lib/features test tool integration_test test_driver
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

Caixa real: páginas de 20, badge, filtros, leitura/não lida e detalhe autorizado. O detalhe informa que o calendário/pedidos/tarefas completos Android ainda pertencem a HO-010/011 e preserva a referência. Polling de 15 s pausa em background; só leituras idempotentes repetem uma vez após refresh Identity. O teste de expiração Android passa agora por background para não confundir atividade da caixa com sessão inativa; a lógica iOS anterior não foi alterada nem executada.

FCM está desativado por defeito; [configuração privada, limites e ensaio externo](../../docs/HO-007-NOTIFICATIONS.md). FirebaseAdmin/FlutterFire com versões fixadas; sem Firebase Auth, sem configuração real em Git. Só pedir permissão na ação de Definições. Recusa mantém a caixa. Registo expira após 24 h sem renovação; abrir diariamente. Logout offline mostra quando não foi possível confirmar remoção; IDs pendentes em armazenamento seguro, sem conservar credenciais da conta anterior. Não se afirma entrega real sem observação no dispositivo.

Teste nativo adicional (Android apenas, mesma API/PG/ficheiro privado do teste de autenticação):

```sh
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/notifications_test.dart --no-dds -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:5080 --dart-define-from-file=<private-dir>/client-test.json
```

Prova submissão gerada por colaborador, consumo real pelo worker, inbox da chefia, leitura sem decisão e detalhe/contexto; não usa Firebase. Os testes em `test/notifications_test.dart` simulam fornecedor/HTTP para recusa, rotação, logout e respostas atrasadas. iOS permanece adiado. O SDK Android atual emite avisos de migração Kotlin em plugins Firebase mantidos; não foram modificadas dependências para ocultar avisos.
