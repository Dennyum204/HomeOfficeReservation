# HO-016 — Refinamento dos cabeçalhos Android

[Comparador antes/depois](comparison.html) · [26 PNG e manifesto SHA-256](manifest.json). As capturas anteriores do commit `75fae2d` permanecem intactas na pasta superior, juntamente com toda a evidência Web.

Ensaio real em 2026-09-11: `HO016_Visual`, 720×1600, API/PostgreSQL isolados, contas sintéticas existentes. `flutter drive`, alvo `visual_theme_test.dart`, `VISUAL_STAGE=header`, terminou com exit 0. Verificou ambos os temas, Calendário, Pedidos, editor, presença, tarefa, Notificações, Definições, verificação manual de sessão, logout com remoção do token seguro e entrada como chefe, distinguindo conta autenticada do colaborador selecionado. Não modificou pedidos, leitura, presenças ou tarefas.

| Tema | Calendário | Conta e sessão | Após scroll |
|---|---|---|---|
| Claro | [Título e colaborador](light-calendar.png) | [Definições](light-settings.png) | [Título fora do viewport](light-calendar-scrolled.png) |
| Escuro | [Título e colaborador](dark-calendar.png) | [Definições](dark-settings.png) | [Título fora do viewport](dark-calendar-scrolled.png) |

O gesto deslocou completamente os títulos de Calendário, Pedidos, Presenças/tarefas e Definições, conservando a navegação inferior. A caixa real de três notificações tem apenas 29,714 px de overflow; o ensaio verifica essa deslocação exata, sem inventar uma captura com o título fora do viewport. A fixture widget com mais conteúdo prova também esse caso em Notificações, nos dois temas, a 320 px e com texto 100%/200%.

As primeiras duas tentativas nativas falharam porque o novo teste exigia que essa caixa curta deslocasse o título inteiro; não contam como execuções bem-sucedidas. O teste agora distingue conteúdo curto de overflow suficiente e não enfraquece a verificação de títulos em listas longas. O ensaio final exportou todas as 26 capturas, inspecionadas para verificar o resultado. Capturas não foram editadas ou recoloridas.

Análise e 52 testes Flutter passaram localmente. HTTP/armazenamento dos testes widget são simulados; o ensaio nativo usa API/PostgreSQL reais. A CI remota, expiração Identity real e restantes percursos core são registados separadamente nos checks do último commit do PR. FCM real, dispositivos físicos, TalkBack auditivo completo, iOS e Outlook não foram revalidados neste refinamento.
