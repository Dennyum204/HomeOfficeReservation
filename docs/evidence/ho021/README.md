# HO-021 — Evidência local dos idiomas

Capturas de aplicações reais com API/PostgreSQL e contas sintéticas, em 14/09/2026. Não são mockups nem capturas do piloto.

- Web: 16 capturas da execução concluída de `languages.spec.ts`, 4 testes passaram (desktop 1280×720; viewport estreito Pixel 5 393×727; claro/escuro). Formulários alemães, rascunho relido pela API com data/texto intactos, persistência, logout e revisão administrativa.
- Android: 18 capturas da execução concluída de `languages_test.dart` no emulador isolado HO021_Visual, 1080×2340, PT/EN/DE, claro/escuro. Definições, calendário e notificações; idioma recuperado após recriar a aplicação; logout no final. A execução passou em 55 segundos. Não representa teste em Android físico.
- Inspeção visual: rótulos alemães e ações cabem nas superfícies; seletor/identidade preservados; navegação Android usa «Meldungen» para não cortar «Benachrichtigungen». Corrigido o corte fixo de abreviaturas de dias, incompatível com «Mo»/«So». Nomes e comentários sintéticos em português continuam intencionalmente no idioma original.
- Foco/teclado e texto ampliado continuam cobertos pela suite existente; o teste de idioma acrescenta texto Android a 130%, cobertura de catálogos, plurais, datas e falhas de armazenamento.

Execuções iniciais que falharam não contam como evidência concluída: o ensaio nativo detetou o corte alemão; os novos E2E corrigiram expectativas de recibo/ícone do seletor; um teste administrativo existente serializava datas locais via UTC. As capturas abaixo provêm apenas das execuções posteriores que passaram.

Emails e push geradas pelo servidor continuam em português; as caixas de notificações traduzem os tipos de evento. Nenhum email real foi enviado. [Âmbito e comandos](../../HO-021-LANGUAGES-PLAN.md).

## Galeria

- [ho021-desktop-de-dark-calendar.png](ho021-desktop-de-dark-calendar.png)
- [ho021-desktop-de-dark-editor.png](ho021-desktop-de-dark-editor.png)
- [ho021-desktop-de-dark-invite.png](ho021-desktop-de-dark-invite.png)
- [ho021-desktop-de-light-calendar.png](ho021-desktop-de-light-calendar.png)
- [ho021-desktop-de-light-editor.png](ho021-desktop-de-light-editor.png)
- [ho021-desktop-de-light-invite.png](ho021-desktop-de-light-invite.png)
- [ho021-desktop-en-dark-settings.png](ho021-desktop-en-dark-settings.png)
- [ho021-desktop-en-light-settings.png](ho021-desktop-en-light-settings.png)
- [ho021-small-screen-de-dark-calendar.png](ho021-small-screen-de-dark-calendar.png)
- [ho021-small-screen-de-dark-editor.png](ho021-small-screen-de-dark-editor.png)
- [ho021-small-screen-de-dark-invite.png](ho021-small-screen-de-dark-invite.png)
- [ho021-small-screen-de-light-calendar.png](ho021-small-screen-de-light-calendar.png)
- [ho021-small-screen-de-light-editor.png](ho021-small-screen-de-light-editor.png)
- [ho021-small-screen-de-light-invite.png](ho021-small-screen-de-light-invite.png)
- [ho021-small-screen-en-dark-settings.png](ho021-small-screen-en-dark-settings.png)
- [ho021-small-screen-en-light-settings.png](ho021-small-screen-en-light-settings.png)
- [ho021-de-dark-calendar.png](ho021-de-dark-calendar.png)
- [ho021-de-dark-notifications.png](ho021-de-dark-notifications.png)
- [ho021-de-dark-settings.png](ho021-de-dark-settings.png)
- [ho021-de-light-calendar.png](ho021-de-light-calendar.png)
- [ho021-de-light-notifications.png](ho021-de-light-notifications.png)
- [ho021-de-light-settings.png](ho021-de-light-settings.png)
- [ho021-en-dark-calendar.png](ho021-en-dark-calendar.png)
- [ho021-en-dark-notifications.png](ho021-en-dark-notifications.png)
- [ho021-en-dark-settings.png](ho021-en-dark-settings.png)
- [ho021-en-light-calendar.png](ho021-en-light-calendar.png)
- [ho021-en-light-notifications.png](ho021-en-light-notifications.png)
- [ho021-en-light-settings.png](ho021-en-light-settings.png)
- [ho021-pt-dark-calendar.png](ho021-pt-dark-calendar.png)
- [ho021-pt-dark-notifications.png](ho021-pt-dark-notifications.png)
- [ho021-pt-dark-settings.png](ho021-pt-dark-settings.png)
- [ho021-pt-light-calendar.png](ho021-pt-light-calendar.png)
- [ho021-pt-light-notifications.png](ho021-pt-light-notifications.png)
- [ho021-pt-light-settings.png](ho021-pt-light-settings.png)
