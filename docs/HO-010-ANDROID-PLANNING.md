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

Evidência de 2026-09-10, entregue no [PR #35](https://github.com/Dennyum204/HomeOfficeReservation/pull/35); integração em main depende da revisão humana. [Capturas sintéticas e contexto](evidence/ho-010/README.md).

| Critérios | Evidência executada |
|---|---|
| Mês/agenda, seleção, padrão/plano/pendentes/presenças, legenda e disponibilidade | Vistas usam `CalendarView`/`DayInput` gerados; inspeção do emulador e teste de widgets a 320 px com texto a 100%/200%. Seleção de colaboradores verificada na API. |
| Rascunho/intervalo, submissão, decisão parcial e retirada | `integration_test/planning_test.dart`: colaborador submete cinco dias; chefia aprova três; ambos veem três aprovados/dois pendentes; retirada mantém as três aprovações. Android/API/PostgreSQL reais. |
| Revisões, cancelamento e contraproposta | Mesmo ensaio: aprovação vigente durante revisão e aceitação; decisão final cancela apenas o dia selecionado. Teste PostgreSQL adicional rejeita versão de base forjada, sem efeitos. |
| Comentários, rejeição com motivo, listas/filtros/paginação | Implementados com contratos existentes e resumo antes do envio; a API conserva as regras e histórico. O percurso nativo automatizado cobre aprovação/contraproposta, não todas as combinações destes controlos. |
| Recuperação, proteção de input, conta e consultas antigas | Testes Flutter com transporte simulado: resposta perdida após commit, replay com bytes/chave iguais e uma consequência, falha de armazenamento sem HTTP, duplo toque, 412/revisão, cache após falha, consulta atrasada e logout/troca de conta. Não são testes de perda de rede do fornecedor. |
| Datas Lisbon/Zurich/DST | `date_timezone_test.dart` passou nas duas zonas reais do Android, verificando offsets de inverno/verão e roundtrip de datas nos limites DST contra API/PostgreSQL; testes unitários adicionais de componentes date-only. |
| Convergência Web/Android | `tools/android-handoff.mjs create` submete pelo browser; `web_handoff_test.dart` decide no Android; `verify` confirma detalhe e calendário no browser. Dados sintéticos próprios, sem reset. |
| Notificações de pedido/decisão | Teste de widgets cobre abertura autorizada e toque duplicado; teste nativo da caixa permanece em CI. `planning_push_live_test.dart` passou com entrega FCM real foreground, abertura do pedido atual, sem decisão nem marcação de leitura implícita. |
| Contrato e regressão backend | `generate_contracts.py --check`: 172 ficheiros coincidem. `dotnet test`: 4 unitários + 47 testes PostgreSQL, zero skips. Sem migração/DTO novo. |
| Verificação partilhada | `flutter analyze`, format e 25 testes Flutter passaram. Documentação/configuração nativa validadas. Backend/Web/Android completos são executados novamente em CI; os resultados do último SHA ficam no PR. |

### FCM real e limites da evidência

A segunda execução do ensaio HO-010 recebeu aceitação FCM em **2026-09-10T00:15:14.544054Z** e recibo do dispositivo em **2026-09-10T00:15:14.770102Z**, uma tentativa, sem erro de entrega. O callback foreground e a abertura autenticada passaram; a captura mostra um dia aprovado e zero pendentes. Consulta posterior apenas dos campos sanitizados confirmou os timestamps. Não são publicados tokens, credenciais, payloads ou IDs privados. Background/cold start mantêm a evidência histórica HO-007; não foram repetidos como ensaio HO-010.

### Falha de CI corrigida

O [primeiro run core](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34420408119) passou backend/contracts e Web, mas falhou no teste nativo `app_test.dart`: `scrollUntilVisible` encontrou dois `Scrollable` no novo calendário, e os diagnósticos já não pertencem a esse ecrã. O teste passa a abrir **Definições** e a tornar visível o diagnóstico existente. Permanecem as asserções de ligação real, secure storage, restauro, expiração e logout. Não foi classificado como infraestrutura transitória nem resolvido por retry sem alteração. A CI completa tem de voltar a passar; sucesso local não substitui CI remota.

Durante um arranque local posterior foram encontrados um cache de compilação danificado e falha de leitura Android `runtime-permissions.xml`. O cache foi conservado com outro nome e reconstruído. O emulador original foi preservado; criou-se `HO010_Test` (`emulator-5556`) para utilização manual. PostgreSQL, contas e configuração Firebase não foram repostos. A evidência FCM acima pertence ao emulador original antes desta falha; permissões/registo no novo emulador não são presumidos. Usar `flutter devices` e o ID disponível nos comandos do guia.

Não há ensaio físico, distribuição/assinatura, produção, iOS, Outlook nem decisões offline neste item. Configuração Firebase real mantém-se externa. HO-011 completa presenças/tarefas Android e a aceitação transversal restante.
