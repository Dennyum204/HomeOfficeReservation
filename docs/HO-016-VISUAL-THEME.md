# HO-016 — Tema Claude + e hierarquia visual

> Integração verificada em 2026-09-11: merge humano do PR #45, quatro checks de main verdes; [SHA/runs](HO-012-INTEGRATION.md). O relato de execução abaixo preserva a evidência da entrega e não é deployment.

Issue: [#41](https://github.com/Dennyum204/HomeOfficeReservation/issues/41). Data: 2026-09-11. Estado: `review` no [PR #45](https://github.com/Dennyum204/HomeOfficeReservation/pull/45); sem merge automático. Os [checks do head](https://github.com/Dennyum204/HomeOfficeReservation/pull/45/checks) registam a validação remota antes da entrega pronta.

## Base e âmbito

HO-015 foi testado e integrado pelo responsável. GitHub confirma [PR #44](https://github.com/Dennyum204/HomeOfficeReservation/pull/44) em `main` em 2026-09-11, merge `dcda6e2cceef570b3f8ab6dc5d5905d6af6212ec`, pertencente à base obtida por fetch. Integração verde: [documentação](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34591956785) e [backend/Web/Android](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34591956766). O tracking HO-015 foi reconciliado nesta branch; a origem documental HO-016 veio do PR #37 sem importar a preparação operacional.

Este trabalho adapta a identidade [Claude +](https://tweakcn.com/themes/cmdght103000n04lh3e2ae93r?p=application), com valores reais e condições registados no [ADR-017](adr/ADR-017-shared-visual-theme.md). Não há nova biblioteca, alteração de contrato, migração ou regra de negócio.

## Utilização

- Web: seletor no topo, na entrada e em Definições. Claro, Escuro ou Sistema; preferência por browser.
- Android: Definições → Aparência → Tema da interface. Claro, Escuro ou Sistema; preferência por dispositivo.
- Android, revisão do cabeçalho: Definições → Conta e sessão contém identidade, email, organização, papéis, Verificar sessão e Terminar sessão. Títulos e colaborador selecionado acompanham o scroll; o seletor da chefia mantém-se no planeamento. Não existe AppBar fixa ou flutuante.
- Localização: casa/edifício e rótulo. Aprovação/padrão/pendente: indicação separada. Conflito mantém aviso e plano aprovado visíveis.
- Editor: contexto/localização, seleção de datas, resumo, comentário e ações. Na Web, escolher Intervalo ou Dias individuais; mudar de modo não apaga o resumo.
- Pedidos: resumo, decisões por dia, ações pertinentes e histórico separados. Leitura de presença/notificação continua diferente de aceitação ou decisão; nenhuma cor executa transições.

## Manutenção e comandos

`design/tokens.json` é a fonte comum das cores; `design/claude-plus-source.json` conserva a referência original. O tipo de letra é local, com OFL-1.1 junto de ambas as cópias. Alterações de cor passam por:

```bash
python scripts/generate_theme.py
python scripts/generate_theme.py --check
python scripts/check_project.py --write
python scripts/check_project.py
```

O gerador verifica os pares de contraste e divergência dos resultados. Os comandos completos de build/teste permanecem nos README de [Web](../apps/web/README.md) e [Android](../apps/mobile/README.md). Os testes de aparência Web usam o mesmo API/PostgreSQL isolado dos outros E2E. Os testes widget Android usam HTTP simulado; os ensaios `flutter drive` usam API real.

Para capturas reais Android, preparar uma conta sintética, pedido, presença e tarefa por mecanismos existentes e guardar as definições num ficheiro **privado**, fora de Git: `TEST_EMAIL`, `TEST_PASSWORD`, `VISUAL_REQUEST_ID`, `VISUAL_DATE`, `VISUAL_REQUIREMENT_ID`, `VISUAL_TASK_ID`. Depois:

```bash
cd apps/mobile
flutter drive --driver=test_driver/visual_theme.dart --target=integration_test/visual_theme_test.dart --no-dds -d SERIAL --dart-define=API_BASE_URL=http://10.0.2.2:5088 --dart-define=VISUAL_STAGE=after --dart-define-from-file=CAMINHO_PRIVADO
```

O ensaio apenas consulta os dados sintéticos e abre os ecrãs; não aprova nem confirma leitura. Capturas só após login. O APK de ensaio contém definições sintéticas e não é distribuído; reinstalar o ponto de entrada normal antes da revisão manual.

## Ambiente de revisão local

Preparado separadamente: Web `http://127.0.0.5:5178/`, API `http://127.0.0.1:5088`, Android `http://10.0.2.2:5088`, AVD `HO016_Visual`/`emulator-5586`, PostgreSQL `homeoffice_ho016_manual`. SMTP é capturado exclusivamente em loopback. O ambiente habitual, outras bases, contas privadas e emuladores não foram limpos.

O caminho das credenciais é comunicado apenas localmente; não publicar passwords, códigos, ficheiros de configuração ou dump de dados em issues/PR. Titular sintético tem administrador+colaborador; chefe distinto está associado. Há plano confirmado, pendente, presença em conflito, tarefa e notificações para revisão.

Percurso manual: entrar como titular; alternar temas; selecionar o dia com conflito; abrir pedido e editor sem enviar; rever presenças/tarefas/notificações e Administração. Android mostra as mesmas camadas com navegação habitual. Para uma escrita voluntária, usar datas livres, submeter como titular e decidir como chefe; conferir o resultado em ambas as plataformas.

## Evidência e limites

[Comparações antes/depois](evidence/ho016/README.md): 84 PNG originais com manifesto SHA-256 — Web desktop 1440×1080 e estreito 390×844, 32 antes e 32 depois; Android 720×1600, 6 antes e 14 depois. O comando de exportação Android terminou com exit 0 e todas as asserções passaram. Foram inspecionados visualmente os ecrãs reais, incluindo editor, administração estreita e calendário/conflito Android. A base anterior não seguia a preferência escura: as capturas «antes/escuro» documentam esse resultado real, sem recoloração artificial.

Os testes de aparência complementam os percursos core existentes de autenticação, convites, aprovações, concorrência, resposta incerta, presenças e tarefas. Uma falha de captura ou compilação não conta como ensaio concluído. A matriz final discrimina local e CI remota; iOS e Outlook não foram executados. Não se afirma certificação universal de leitor de ecrã ou validação de todos os dispositivos físicos.

[PR #37](https://github.com/Dennyum204/HomeOfficeReservation/pull/37) permanece draft e HO-012 incompleta. O NAS provou apenas conectividade Cloudflare Tunnel; instalação e desempenho HomeOffice continuam por validar. Não houve deployment, DNS, contratação, email real ou distribuição.

## Verificação local desta implementação

- Documentação, geração/contraste do tema e configuração nativa: passaram.
- Backend: 4 testes API + 69 integração com PostgreSQL real, sem skips. Contratos: 178 ficheiros correspondem à regeneração.
- Web: formatter, TypeScript, ESLint, testes unitários e build passaram; 4 E2E de autenticação + 34 percursos core/tema passaram em desktop e viewport estreito. O contraste DOM usa superfícies efetivamente renderizadas; seletor, foco do diálogo, Escape, preservação de datas e movimento reduzido estão cobertos.
- Android: análise e 51 testes passaram, incluindo aparência/layout/estado; matriz a 320 px com texto 100%/200% em ambos os temas. Guidelines Flutter verificam alvos táteis, rótulos semânticos e contraste no calendário a 411 px. Ensaios widget usam HTTP simulado; capturas nativas usam dados/API reais.
- Tentativas anteriores do exportador Android falharam por imports/seletores do novo ensaio e não contam como sucesso. Foram corrigidas antes da execução completa com 14 capturas. A tentativa inicial da base anterior encontrou a colisão de PageStorage; a captura antes foi obtida com montagem isolada e a regressão foi corrigida na aplicação.

A certificação com utilizadores de leitores de ecrã, dispositivos físicos diversos, perfis de cores e diferenças de renderização de fabricantes não foi realizada. Foram verificados rótulos/semântica automatizados; não se afirma uma sessão auditiva completa de TalkBack. A CI remota do PR é registada separadamente e nunca inferida a partir destes resultados locais.

## Refinamento Android da revisão — 2026-09-11

A revisão do PR #45 remove o painel persistente e a AppBar, integra títulos compactos no scroll de cada separador e coloca a identidade e as ações de sessão em Conta e sessão. Os controladores de autenticação e observadores de retoma não foram alterados. O teste encontrou posições de scroll herdadas entre contas; um PageStorageBucket por identidade corrige essa transferência, sem apagar os dados normais nem perder a posição entre separadores da mesma conta.

Análise, formatter e 52 testes Flutter passaram. O novo percurso widget cobre cinco separadores, claro/escuro, 320 px, texto 100%/200%, áreas seguras, verificação manual, logout, descarte de rascunho/credenciais/intenção e troca de conta, seguida de validação automática na retoma do Calendário. Os testes nativos de autenticação, convites, notificações, planeamento e FCM opcional alcançam ações de sessão por Definições; mantêm as asserções funcionais. O teste de expiração nativo verifica a sessão manualmente antes de sair de Definições e prova a expiração automática no Calendário após inatividade.

[26 capturas reais e comparações](evidence/ho016/android-header/README.md) foram exportadas com sucesso no HO016_Visual; preservam-se as 84 originais e toda a Web. O mesmo comando de captura acima aceita `--dart-define=VISUAL_STAGE=header`; acrescentar `TEST_MANAGER_EMAIL`/`TEST_MANAGER_PASSWORD` ao ficheiro privado. O ensaio consulta os dados existentes, testa sessão/logout e seleciona o colaborador como chefe; não submete alterações de negócio. A caixa real curta tem 29,714 px de scroll, limite explicitamente registado. A análise visual confirma títulos, conta, seletor e navegação nos dois temas.

Revisão manual curta: percorrer os separadores e fazer scroll; abrir Definições → Conta e sessão, verificar sessão e terminar sessão; entrar como chefe e distinguir o colaborador do calendário da identidade em Definições. Alternar claro/escuro em Aparência. API/Web/emulador isolados continuam disponíveis; credenciais apenas no ficheiro privado local. CI remota final e ausência de conflitos são confirmadas no PR antes de retirar draft.
