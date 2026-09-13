# HO-020 — UI e leitura automática de notificações

[Issue #49](https://github.com/Dennyum204/HomeOfficeReservation/issues/49). Trabalho separado de HO-012/PR #37 e do piloto instalado no Pi. Base verificada: `origin/main` `f07c3dd7185743c62f5c47d15c4b8a5198d92cbb`, merge humano de HO-016/PR #45 com integração core e documentação verdes.

## Comportamento

Web e Android abrem a caixa em **Por ler**. Os filtros Todas, Já lidas e histórico permanecem disponíveis. A consulta da notificação resolve o destino, mas não a lê: a leitura só é enviada depois de o detalhe autorizado ter sido carregado e apresentado. No Android, a abertura pela push utiliza esse mesmo percurso; receber a push não escreve. Uma falha deixa a leitura por guardar e oferece repetição. O contador e a lista são atualizados após confirmação da API. Ler continua separado de decidir pedidos, aceitar propostas, confirmar presenças ou alterar tarefas.

O único acréscimo de contrato é `readOnly=false` opcional em `GET /api/v1/notifications`, aplicado no servidor antes da paginação. `unreadOnly=true&readOnly=true` devolve zero itens. OpenAPI e clientes TypeScript/Dart regenerados. Sem migração, mudança de permissões ou alteração de transições de negócio.

O modal de convite usa checkboxes de 20 px junto dos nomes, com labels clicáveis e conteúdo limitado pela largura do formulário. O resumo do pedido coloca a data no cabeçalho, campos com labels em duas colunas (uma em largura estreita) e remoção exclusiva por botão de lixo de 44 px. Os dias de calendário combinam fundos suaves de localização com um indicador pendente separado; texto, ícones, seleção, hoje e dias fora do mês mantêm-se.

A Web não tinha um componente de lista de seleção personalizado. O adaptador `Select` reutiliza os handlers e opções existentes e usa **@radix-ui/react-select 2.3.7** (MIT, versão e transitivas no lockfile), sem substituir o tema ou introduzir uma biblioteca de estilos. A primitiva fornece navegação por teclado, typeahead, semântica e foco; o portal permanece dentro do `dialog` nativo e respeita os seus limites. [Documentação oficial](https://www.radix-ui.com/primitives/docs/components/select).

## Verificação reproduzível

Usar os SDKs fixados e uma instância PostgreSQL **exclusiva de testes**, com configuração e contas criadas por `scripts/init_auth.py --private-dir <diretório-privado> --database-from-env HO_TEST_DATABASE`; migrar e provisionar conforme `apps/api/README.md`. Não reutilizar uma base habitual. As suites de convites acumulam contas sintéticas e estão sujeitas aos limites reais do servidor; iniciar uma base nova para uma nova campanha completa, sem elevar limites ou apagar dados existentes.

- `python scripts/check_project.py` e `python scripts/generate_contracts.py --check`.
- `dotnet format apps/api/HomeOffice.slnx --no-restore --verify-no-changes`; build Release e `dotnet test apps/api/HomeOffice.slnx -c Release --no-build` com `HO_TEST_DATABASE` isolada: 73 testes locais passaram (4 API, 69 integração PostgreSQL).
- Em `apps/web`: `npm ci`, `npm run format:check`, `npm run typecheck`, `npm run lint`, `npm test`, `npm run build`; `HO_DEV_ACCOUNTS` aponta para o ficheiro privado. `npm run test:e2e` usa API real e ambos os viewports; `npm run test:e2e:auth` é também obrigatório na CI.
- Em `apps/mobile`: `flutter pub get --enforce-lockfile`, `flutter gen-l10n`, `flutter analyze --no-pub`, `flutter test --no-pub`: 54 testes locais passaram. O ensaio visual nativo é `flutter drive -d <emulador-isolado> --driver test_driver/ho020_visual.dart --target integration_test/ho020_visual_test.dart --dart-define-from-file=<ficheiro-privado>`.

As regressões cobrem resolução recusada sem leitura, falha de persistência/repetição, leitura/contador após detalhe, reabertura depois de marcar como não lida, filtro antes de paginação e ausência de decisões implícitas. Os percursos administrativos continuam a verificar isolamento, titular com dois papéis, convites, versões obsoletas, replay incerto, suspensão e permissões. O teste de UI verifica foco/teclado do dropdown, ausência de overflow horizontal, checkboxes e remoção sem submissão.

Os quatro checks remotos **project-docs, backend-contracts, web, flutter-android** no último head e a ausência de conflitos são o gate para retirar draft; resultados locais não os substituem. Os resultados remotos finais ficam no PR. HO-020 permanece `review` até merge humano.

## Revisão visual e limitações

[Comparações antes/depois e capturas reais](evidence/ho020/README.md). O emulador separado HO020_Visual usa dados sintéticos e uma API PostgreSQL local. Não se alterou o emulador habitual. O APK de revisão é debug com endereço local, sem credenciais de teste embutidas; não foi distribuído.

A receção de push FCM num dispositivo físico não foi executada nesta tarefa: o callback e o encaminhamento autenticado são cobertos por testes simulados. As capturas nativas são de execução real no emulador; não são prova de distribuição ou acessibilidade validada por uma pessoa com leitor de ecrã. As permissões e regras continuam na API.

[HO-021/issue #50](https://github.com/Dennyum204/HomeOfficeReservation/issues/50) regista português/inglês/alemão, preferência persistente, formatação, acessibilidade/plurais e estratégia para emails/notificações do servidor. A implementação aguarda a revisão deste primeiro PR.

## Recuperação e teste manual

Não há alterações no Pi, nas suas contas, no SMTP ou nos backups. Reverter este PR restaura a apresentação anterior; o parâmetro opcional não requer reversão de dados.

O guia privado local identifica endereços, ficheiro de contas, papéis e processos do ambiente HO020. Entrar como colaborador, abrir Notificações e um contexto; regressar e confirmar a remoção da lista Por ler e a presença em Já lidas. No Calendário comparar remoto aprovado, proposta pendente e revisão sobre um dia aprovado; testar claro/escuro e o editor em largura estreita. Como administrador, abrir Convidar membro e navegar pelos papéis e dropdowns com Tab/setas/Escape. No Android repetir a abertura do contexto e consultar o calendário. Não usar contas reais.
