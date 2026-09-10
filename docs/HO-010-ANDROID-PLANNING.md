# HO-010 — Calendário e pedidos Android

O Android usa Identity e o calendário da aplicação. Microsoft/Outlook não fazem parte do arranque nem destes ensaios. O mesmo backend serve a Web e Android; [ADR-011](adr/ADR-011-android-planning.md) descreve estado, recuperação e a pequena correção de revisão na API.

## Utilização

1. Entrar como colaborador. Em **Calendário**, navegar por mês, voltar a **Hoje**, selecionar um dia e consultar a legenda/agenda. Padrão, confirmação, pedido pendente e obrigação presencial têm rótulos e ícones próprios. Uma obrigação em conflito não esconde uma aprovação.
2. Em **Pedidos**, criar um pedido, adicionar datas isoladas ou pré-visualizar um intervalo inclusivo, rever os dias e escrever um comentário. Guardar rascunho e depois submeter são ações distintas, ambas com confirmação. Localização e disponibilidade manual são campos distintos.
3. Entrar como chefia e escolher o colaborador autorizado no seletor. Abrir o pedido, selecionar um subconjunto de dias pendentes e aprovar/rejeitar após rever o resumo. Rejeição exige motivo. Comentários e decisões por dia mantêm o contexto.
4. Voltar ao colaborador: retirar apenas os dias pendentes mantém os aprovados. Selecionar dias aprovados para propor alteração/cancelamento cria outra revisão; o plano efetivo continua válido até decisão final. Aceitar uma contraproposta cria uma revisão para decisão, não uma aprovação automática.
5. A caixa abre pedidos/decisões atuais autorizados. Presenças e tarefas ainda remetem para a Web: a implementação completa Android pertence a HO-011.

Input é protegido localmente por conta. Background preserva-o; logout explícito apaga-o. Falha de rede mantém o último resultado identificado como desatualizado e impede decisões offline. Se o resultado de envio ficar incerto, usar **Recuperar a mesma operação**; não criar uma segunda intenção. Uma versão desatualizada exige atualização e revisão explícita. As datas nunca são convertidas por UTC.

## Preparação e ensaio nativo

Usar os SDKs e comandos do [README mobile](../apps/mobile/README.md), PostgreSQL/API disponíveis e contas sintéticas privadas já provisionadas conforme [HO-003](HO-003-AUTHENTICATION.md). Não resetar a base nem contas existentes. `client-test.json` contém as contas de teste fora do Git. O ensaio procura uma semana livre, cria novos pedidos marcados como ensaio e só altera esses pedidos.

```sh
cd apps/mobile
flutter drive --driver=test_driver/planning.dart --target=integration_test/planning_test.dart --no-dds --keep-app-running -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:5080 --dart-define-from-file=<private-dir>/client-test.json
```

No ambiente local com FCM já configurado, manter o ambiente privado existente e acrescentar `--dart-define=FCM_ENABLED=true`. O core CI não exige Firebase. `--keep-app-running` evita desinstalar a aplicação no fim; após os testes repor `flutter run` com `lib/main.dart`, sem defines de contas. Screenshots sintéticos são produzidos em `apps/mobile/test-results/`, inicialmente ignorados pelo Git, para inspeção antes de selecionar evidência.

## Passagem Web → Android → Web

Com API e Web locais já em execução e contas privadas, definir `HO_DEV_ACCOUNTS=<private-dir>/accounts.json` e `HO_CROSS_STATE=<private-dir>/ho010-web-handoff.json`. A partir de `apps/web`:

```sh
node tools/android-handoff.mjs create
```

O script usa Chromium/Playwright fixado no lockfile, cria e submete pelo formulário Web numa data livre e guarda só a referência sintética no ficheiro externo. Em `apps/mobile`, passar também esse ficheiro:

```sh
flutter drive --driver=test_driver/planning.dart --target=integration_test/web_handoff_test.dart --no-dds --keep-app-running -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:5080 --dart-define-from-file=<private-dir>/client-test.json --dart-define-from-file=<private-dir>/ho010-web-handoff.json
```

Depois, em `apps/web`, `node tools/android-handoff.mjs verify` verifica a decisão no detalhe Web e o calendário da mesma conta através da sessão browser. Não é uma simulação de cliente Web por chamada direta de escrita. O script não arranca serviços nem altera fixtures existentes. `HO_WEB_URL` permite outra origem local; por defeito usa `http://127.0.0.1:5173`.

## Evidência e limites

Resultados finais, capturas e CI serão registados após concluir os ensaios desta branch. Um teste ainda em execução ou uma tentativa falhada não constitui evidência aprovada. Testes de falhas por transporte/HTTP simulado, testes Android contra API/PostgreSQL e entrega pelo fornecedor FCM são evidências distintas.

Não há ensaio físico, distribuição/assinatura, produção, iOS, Outlook nem decisões offline neste item. Configuração Firebase real mantém-se externa. HO-011 completa presenças/tarefas Android e a aceitação transversal restante.
