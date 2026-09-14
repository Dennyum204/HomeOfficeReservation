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

## Avisos flutuantes — preparação HO-017 (2026-09-14)

O APK anterior não incluía FCM. O perfil privado passa a compilar com a configuração Firebase externa existente e `FCM_ENABLED=true`, mantendo package e assinatura. O canal `homeoffice_updates` é criado com `IMPORTANCE_HIGH`, som padrão e visibilidade privada. O FCM usa esse canal por defeito em background; em foreground o callback de uma notificação real apresenta o mesmo aviso do sistema, com texto genérico e ID opaco. Tocar no aviso abre o contexto autenticado; não decide pedidos. O canal respeita escolhas anteriores do utilizador, permissões, Não incomodar e políticas de bateria do Android. Não se recria um canal para contornar uma recusa.

Não se pede full-screen intent, overlay sobre outras aplicações ou acesso às notificações de outras apps. Sem FCM/permissão continua disponível a caixa interna. Logout limpa os avisos da própria app após revogar o registo. O transporte do servidor existente mantém prioridade normal e TTL de uma hora; não há promessa de receção instantânea em Doze.

Ensaio físico anterior no Samsung: login/troca de contas sintéticas, rascunho/submissão, aprovação pelo chefe, notificação interna/contexto/leitura, calendário confirmado e sessão/plano após force-stop/reabertura passaram. Pedido identificado como sintético para 30/09/2026; dados anteriores preservados. Convite/ativação nativa e apresentação FCM real ainda pendentes. Capturas e recibos privados, sem credenciais no tracking.

Conflitos do PR com main resolvidos importando a integração humana de #37. A integração Android de main falhou por um tap em Entrar que não atingiu o botão durante a animação nativa do teclado. O teste passa a exigir insets de teclado a zero e alvo estável/hittable antes do único tap; as verificações de login, expiração, conta e logout não são removidas.

Fontes: [canais Android](https://developer.android.com/develop/ui/views/notifications/channels), [receção Flutter/FCM](https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages). A compilação/CI não substitui a captura do aviso no telefone.

## Ensaio físico FCM concluído em 2026-09-14

No Samsung Galaxy S24 Ultra, Android release privado 0.1.0 (2026091402), foram observados três avisos reais gerados pelo worker do Pi via FCM: app em foreground, app em background e processo ausente após `am kill` em background (confirmado por ausência de PID, sem force-stop do pacote). Cada cenário criou uma tarefa sintética identificada; capturas privadas mostram o aviso flutuante do sistema no topo com o ícone `ho` e texto genérico. Abrir cada notificação encaminhou para a tarefa correspondente com sessão válida. Em cold process, a sessão foi recuperada. Não se infere este resultado a partir da aceitação pelo fornecedor ou do polling da caixa.

Permissão POST_NOTIFICATIONS concedida pela UI, canal real com importância 4, Não incomodar em 0 sem alteração das definições globais. Wi-Fi e ecrã desbloqueado; não valida Doze prolongado, modo Não incomodar, permissão recusada, rede móvel isolada ou pacote force-stopped. Os testes não prometem disponibilidade imediata em todas as condições Android. Só três tarefas sintéticas novas; sem convites/emails reais, alteração de planos anteriores ou execução forçada dos backups.

O operador confirmou FCM ativo no Pi, aplicação saudável, mesma imagem, restantes serviços preservados, zero dispositivos/envios pendentes antes da mudança e configuração anterior recuperável. A nova credencial privada requer inclusão no material de recuperação: o coletor passa a exigir `private/push/server.json` quando FCM está ativo, incluindo-o no manifesto e no upload cifrado existente. A captura recusa credencial ausente/symlink/permissões abertas. Os 22 testes de backup/monitorização passaram, incluindo captura real em fixture e roundtrip restic local; isto não comprova um novo envio agendado no Pi. Instalação deste pequeno ajuste operacional aguarda recibo sudo separado; timers/retenção/destino inalterados.

Análise Flutter sem problemas e 60 testes passaram. CI do commit final continua obrigatória. Convite/ativação numa conta nova dentro do Android e aceitação completa da recuperação/distribuição de assinatura permanecem em #46; este PR não fecha a issue e não houve merge/auto-merge.
