# Web React/TypeScript

HO-015 acrescenta **Administração** para administradores ativos: membros, convites, entrega, papéis e chefias. [Utilização, recuperação e teste](../../docs/HO-015-WEB-ADMINISTRATION.md). Os ecrãs de aceitação Identity Web/Android de HO-014 mantêm-se. HO-016 aplica [Claude + e hierarquia visual](../../docs/HO-016-VISUAL-THEME.md), com claro/escuro/sistema no topo e em Definições.

Calendário próprio mês/semana e Pedidos em PT-PT, com rascunhos, revisão de datas, aprovação/rejeição parcial, retirada, revisões/cancelamentos e contrapropostas. Plano confirmado e alterações pendentes são camadas distintas. HO-006 acrescenta Presenças/Tarefas com preview, leitura por revisão, resolução explícita e progresso autorizado. [Percurso HO-006](../../docs/HO-006-ONSITE-TASKS.md). HO-007 acrescenta notificações; Outlook continua futuro. [Percurso de teste HO-005](../../docs/HO-005-WEB.md). Login, ativação, recuperação, logout e sessão autenticada funcionam com cookies Identity. Sem aprovações fictícias ou dependência Microsoft. [Preparar contas e obter credenciais privadas](../../docs/HO-003-AUTHENTICATION.md).

Node **24.20.0**, npm **11.19.0**, React **19.2.8**, TypeScript **6.0.3**, Vite **8.2.2**. Versões exatas em package.json/package-lock.json; TypeScript 6 foi escolhido pela compatibilidade declarada com typescript-eslint.

## Arranque a partir da raiz

Iniciar a API conforme [guia backend](../api/README.md), depois noutro terminal:

```sh
npm --prefix apps/web ci
npm --prefix apps/web run dev
```

Abrir **http://127.0.0.1:5173**. O proxy Vite encaminha `/api` para `http://localhost:5080`; definir `API_PROXY_TARGET` no ambiente do processo Vite para outro backend de desenvolvimento. O browser usa sempre a mesma origem, sem CORS permissivo. Em alojamento futuro, servir `/api` pela mesma origem HTTPS. Não introduzir tokens em localStorage.

`src/features/workspace/api.ts` usa o cliente TypeScript gerado em `contracts/typescript`. O timestamp e as zonas vêm da API real; erro/timeout têm recuperação explícita. Strings em `src/i18n/pt-PT.ts`  , `src/i18n/planning.pt-PT.ts` e `src/i18n/work.pt-PT.ts`; planeamento em `src/features/planning/`. Ícones/ilustração CSS decorativos, navegação por teclado e estado anunciado por leitor de ecrã.

## Checks reais

```sh
npm --prefix apps/web run format:check
npm --prefix apps/web run typecheck
npm --prefix apps/web run lint
npm --prefix apps/web test
npm --prefix apps/web run build
```

Testes de browser, a partir de `apps/web` (requer backend compilado em Release, PostgreSQL com migração/contas e HO_DEV_ACCOUNTS apontado ao accounts.json privado):

```sh
npx playwright install chromium
npm run test:e2e:auth
npm run test:e2e
```

Em Linux CI, `npx playwright install --with-deps chromium` também instala bibliotecas do SO. Playwright arranca Vite e a API reais, testa o cliente gerado/navegação/retry/offline nos tamanhos desktop e mobile e guarda capturas do shell em `test-results/`; não grava traces/HAR nem publica snapshots de formulários. O projeto `small-screen` usa Chromium com viewport/toque Pixel 5. iOS está adiado (HO-306), sem execução normal; partilha Flutter/Dart e validação Android mantêm-se obrigatórias.

Playwright usa 5083/5174 com instâncias próprias; os servidores normais 5080/5173 podem continuar abertos. `test:e2e:auth` mantém a expiração real de quatro segundos em Development; `test:e2e` usa dez minutos para percursos de negócio. Um worker conserva previsibilidade sobre as contas locais partilhadas. Os testes de planeamento escolhem datas livres, nunca fazem reset e deixam o seu histórico sintético. Vitest simula HTTP para contratos, UI e respostas atrasadas; não substitui E2E/PostgreSQL. Consulte o guia HO-005 para distinção entre efeitos reais e perda de resposta injetada.

`features/auth` usa AuthApi/AccessApi gerados. Cookie HttpOnly, Secure em produção; o cliente pede CSRF atualizado antes de login/logout. Não guarda tokens em localStorage. Falha de verificação retira vistas privadas e apresenta estado de sessão/rede. HTTPS e mesma origem são requisitos de alojamento; HTTP é exclusivo do ambiente local Development.

## Caixa de notificações HO-007

[Percurso com duas contas](../../docs/HO-007-NOTIFICATIONS.md): filtros atuais/não lidas/histórico, páginas de 20, badge e leitura idempotente, links para pedido/presença/tarefa atuais. Polling de 15 s pausado ao ocultar/offline, sem Web OS push. Strings em `src/i18n/notifications.pt-PT.ts`; `NotificationsApi` gerado, sem DTOs copiados. `tests/notifications.spec.ts` usa API, worker e PostgreSQL reais em desktop/ecrã estreito e verifica que ler não decide nem confirma presença. Nenhuma credencial Firebase exigida no browser.

## Passagem para Android HO-010

Com Web/API já em execução e contas privadas autorizadas, `node tools/android-handoff.mjs create` cria um pedido pelo formulário browser. Depois da decisão Android, `node tools/android-handoff.mjs verify` confirma o detalhe e calendário pela sessão Web. Não arranca outra API nem reseta fixtures. Variáveis, comandos Android e evidência no [guia HO-010](../../docs/HO-010-ANDROID-PLANNING.md).

## Aceitação Web/Android HO-011

Os rótulos distinguem **Pedir os meus dias de trabalho** de **Exigir presença do colaborador**, e a conta autenticada do colaborador selecionado. Em ecrã estreito, abrir presença/tarefa mostra o detalhe antes da lista, recebe foco e devolve-o à lista ao fechar. As ações de resolução não usam UUIDs como nomes. `tools/core-acceptance.mjs` coordena ensaios reais com Android, sem mocks nem reset de dados. [Matriz, estado privado e sequência exata](../../docs/HO-011-CORE-ACCEPTANCE.md).
