# Android privado no piloto

Instalação USB solicitada pelo responsável em 2026-09-14. Aplicação normal ARM64 release, ligada a `https://homeoffice.ferbatech.com`, sem contas/passwords incorporadas. Identificador existente `dev.homeoffice.homeoffice_mobile` preservado. Chave e propriedades de assinatura ficam fora do Git, no diretório privado do operador; conservar essa chave para futuras atualizações. Não substituir instalações com assinatura diferente nem limpar dados.

O ícone reproduz o monograma `ho` da Web: Outfit com peso 650, espaçamento de -3 px a 25 px, branco sobre `#A84E32`. Contornos vetoriais derivados da fonte OFL já incluída em `apps/web/public/fonts`; ícone adaptativo desde API 26 e monocromático desde API 33. A fonte e a Web não foram alteradas. Os contornos usam uma largura de 48 numa viewport de 108, dentro da área segura do launcher.

```powershell
$env:HO_ANDROID_SIGNING_PROPERTIES = 'CAMINHO_PRIVADO/signing.properties'
flutter pub get --enforce-lockfile
flutter build apk --release --target-platform android-arm64 --build-number=2026091401 --dart-define=API_BASE_URL=https://homeoffice.ferbatech.com
```

Validar assinatura com `apksigner verify` antes de instalar por `adb -s SERIAL install -r APK`. Não incluir serial, credenciais ou keystore no tracking público. Abrir a aplicação normal após instalação; iniciar sessão com a conta existente, sem novo convite obrigatório.

Esta entrega cobre preparação do ícone e instalação privada direta. FCM permanece desativado neste build; a caixa interna funciona com a aplicação aberta. Aceitação/ativação, decisões, recuperação de sessão e push em dispositivo físico ainda exigem evidência própria. HO-017 mantém-se incompleta; PR #37/piloto Web, DNS, Pi, NAS e backups não são alterados nesta tarefa.
