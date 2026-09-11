# ADR-017 — Identidade Claude + adaptada à Web e Android

Data: 2026-09-11. Estado: implementado em HO-016, sujeito a revisão humana.

## Contexto e decisão

O responsável escolheu [Claude +, de Luis Llanes](https://tweakcn.com/themes/cmdght103000n04lh3e2ae93r?p=application). Os ecrãs existentes tinham predominância de verde e não aplicavam um tema escuro completo. Preservamos React/CSS, Material 3, a navegação e os contratos existentes; não introduzimos biblioteca de componentes, autenticação ou serviços.

Os valores publicados foram extraídos da página real, identificada pelo ID `cmdght103000n04lh3e2ae93r`, e preservados em [claude-plus-source.json](../../design/claude-plus-source.json). A fonte canónica da adaptação é [tokens.json](../../design/tokens.json); `scripts/generate_theme.py` produz CSS, cores Dart e o relatório de contraste. CI verifica divergência e os pares semânticos usados. Não editar os resultados gerados.

Mantemos fundos quentes (`#faf9f5`/`#262624`), superfícies neutras, Outfit e raios de 16 px. Adaptamos primários, texto secundário e contornos para contraste: primário claro `#a84e32` (fonte `#c96442`), escuro `#e08a6d` (fonte `#d97757`). Âmbar identifica pendentes, vermelho identifica conflito/erro; local de trabalho usa texto e ícone neutros. Aprovação, disponibilidade, localização e conflito continuam conceitos separados.

Claro, escuro e sistema são preferências locais ao dispositivo. Web guarda apenas o modo em localStorage e aplica-o antes da pintura; Android reutiliza o armazenamento de plataforma existente numa chave independente. Falha ao guardar a preferência não bloqueia o acesso nem altera tokens de autenticação. Animações curtas respeitam `prefers-reduced-motion` e a opção de acessibilidade Android.

## Condições e atribuição

Inspeção em 2026-09-11: o [código do editor tweakcn tem licença Apache-2.0](https://github.com/jnsahaj/tweakcn/blob/main/LICENSE). A página comunitária consultada não apresentou uma licença separada para este tema. Não inferimos que a licença do editor concede direitos sobre qualquer contribuição comunitária. Usamos os valores de cor/tipografia como referência atribuída para componentes próprios; não copiamos componentes, imagens, logótipos ou texto promocional do serviço. Não existe afiliação com Claude/Anthropic.

Outfit é distribuída localmente, sem pedidos a Google Fonts durante utilização. O ficheiro oficial está fixado a um commit de google/fonts, com SHA-256 e origem em [font-source.json](../../design/font-source.json). As cópias Web/Android incluem o texto OFL-1.1 original. [Fonte e licença oficiais](https://github.com/google/fonts/tree/8b0a1d0f5983c89bc2b93f1b5fb55f9e252744b5/ofl/outfit).

## Consequências e alternativas

Uma biblioteca nova ou uma reescrita criariam migração desnecessária dos fluxos já aceites. CSS semântico e ThemeData permitem adaptar os componentes existentes. Badges e secções são reutilizados dentro de cada plataforma, sem tentar partilhar widgets entre React e Flutter.

A hierarquia do editor Web separa contexto, método de seleção, resumo, comentário e ações. Alternar intervalo/dias individuais conserva os dias já escolhidos. O detalhe de pedidos só apresenta ações pertinentes aos dias disponíveis; o servidor conserva a decisão final de autorização. Não há alterações de API, migração ou permissões.

O ensaio real Android encontrou uma colisão pré-existente de PageStorage entre a legenda expansível e a posição de scroll. Uma chave própria da legenda corrige o regresso ao calendário, com teste de regressão. Não altera dados de planeamento.

## Fontes e validação

Fontes oficiais consultadas em 2026-09-11: [WCAG 2.2 — contraste](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html), [padrão de diálogo modal WAI-ARIA](https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/), [acessibilidade Flutter](https://docs.flutter.dev/ui/accessibility). Texto normal exige 4,5:1; texto grande e indicadores de controlo/foco têm verificações próprias. Testes automáticos e inspeção visual não equivalem a uma certificação integral de acessibilidade.

O [guia HO-016](../HO-016-VISUAL-THEME.md) distingue capturas reais, testes com HTTP simulado e limitações. ADR-007/011/012/016 mantêm as decisões funcionais; este ADR substitui apenas as propostas de cor anteriores de UX. iOS e Outlook continuam adiados.

## Refinamento da revisão Android — 2026-09-11

Por pedido do responsável no PR #45, retiram-se o painel de conta persistente e a AppBar. Títulos compactos pertencem às listas com scroll; o seletor de colaborador permanece nas áreas pertinentes. Conta autenticada, papéis e ações de sessão ficam em Definições → Conta e sessão. Os observadores de ciclo de vida e controladores conservam validação automática, renovação e cleanup. Um PageStorageBucket por identidade limita as posições de scroll à sessão visual dessa conta, evitando que o login seguinte herde a posição da anterior; as posições continuam preservadas entre separadores da mesma conta.

Fontes oficiais consultadas em 2026-09-11: [PageStorage](https://api.flutter.dev/flutter/widgets/PageStorage-class.html) e [SafeArea](https://api.flutter.dev/flutter/widgets/SafeArea-class.html). Não há alteração de API, armazenamento de credenciais, regras de negócio ou Web. A decisão anterior mantém-se como histórico; esta secção substitui apenas a colocação do cabeçalho e da conta no Android.
