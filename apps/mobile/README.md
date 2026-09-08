# Flutter Android/iOS

Shell PT-PT equivalente à Web: navegação, estados em preparação e ligação real ao endpoint de metadados. Sem login, dados fictícios de calendário, aprovação, push ou Microsoft. Strings ARB em `lib/l10n/app_pt.arb`; `flutter pub get`/`flutter gen-l10n` geram código ignorado. Separação entre vista, repository e cliente Dart gerado, sem regras de negócio duplicadas.

## Ferramentas fixadas

- Flutter **3.47.2**, revisão `d3b14c876900e553bc736ca19295fc09e3853e8e`, Dart **3.13.2** incluído. `.flutter-version` e pubspec registam a versão; instalação oficial ou clone da tag. Não atualizar automaticamente durante o setup.
- Android: JDK Temurin **21.0.12+8**, SDK/target **36**, min **24**, NDK **28.2.13676358**, AGP **9.1.0**, Kotlin **2.4.0**, Gradle **9.3.1** com SHA-256. SDK/NDK vêm dos defaults do Flutter fixado. Android Studio/SDK e emulador são necessários para execução local.
- iOS: macOS e Xcode; CI usa **macos-15/Xcode 26.3**, deployment target **iOS 15.0**. Assinatura/conta Apple só para dispositivos físicos/distribuição, não para compilar Simulator ou release sem assinatura. Não é possível compilar iOS em Windows/Linux.
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
dart format --output=none --set-exit-if-changed lib/main.dart lib/config lib/features test tool integration_test
flutter analyze
flutter test
dart run tool/smoke_api.dart http://localhost:5080
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.invalid
```

O smoke usa o mesmo repository e cliente gerado da app com HTTP real; verifica o contrato e um timestamp recente, sem emitir dados pessoais. Os widget tests usam respostas sintéticas e cobrem falha/retry/navegação/ecrã pequeno. Teste de plataforma com API real:

```sh
flutter test integration_test/app_test.dart -d <device-id> --dart-define=API_BASE_URL=http://10.0.2.2:5080
```

No Mac, com Simulator:

```sh
flutter build ios --simulator --debug --dart-define=API_BASE_URL=http://localhost:5080
flutter build ios --release --no-codesign --dart-define=API_BASE_URL=https://api.example.invalid
flutter test integration_test/app_test.dart -d <simulator-id> --dart-define=API_BASE_URL=http://localhost:5080
```

CI exige análise/testes, cliente Dart contra Kestrel real, release Android sem assinatura, builds iOS Simulator/device sem assinatura e smoke de plataforma Android Emulator/iOS Simulator. Não substitui ensaio físico, assinatura, lojas ou push, trabalhos posteriores. O APK release é unsigned; usar `flutter run` para instalar debug. Resultados efetivos e limitações em [STATUS](../../STATUS.md) e no PR.
