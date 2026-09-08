# Web React/TypeScript

Shell responsivo PT-PT com Calendário, Pedidos, Tarefas, Notificações e Definições. As áreas de negócio estão explicitamente em preparação. Só navegação e ligação/atualização do serviço funcionam nesta entrega. Sem login, aprovações fictícias ou dependência Microsoft.

Node **24.20.0**, npm **11.19.0**, React **19.2.8**, TypeScript **6.0.3**, Vite **8.2.2**. Versões exatas em package.json/package-lock.json; TypeScript 6 foi escolhido pela compatibilidade declarada com typescript-eslint.

## Arranque a partir da raiz

Iniciar a API conforme [guia backend](../api/README.md), depois noutro terminal:

```sh
npm --prefix apps/web ci
npm --prefix apps/web run dev
```

Abrir **http://127.0.0.1:5173**. O proxy Vite encaminha `/api` para `http://localhost:5080`; definir `API_PROXY_TARGET` no ambiente do processo Vite para outro backend de desenvolvimento. O browser usa sempre a mesma origem, sem CORS permissivo. Em alojamento futuro, servir `/api` pela mesma origem HTTPS. Não introduzir tokens em localStorage.

`src/features/workspace/api.ts` usa o cliente TypeScript gerado em `contracts/typescript`. O timestamp e as zonas vêm da API real; erro/timeout têm recuperação explícita. Strings em `src/i18n/pt-PT.ts`. Ícones/ilustração CSS decorativos, navegação por teclado e estado anunciado por leitor de ecrã.

## Checks reais

```sh
npm --prefix apps/web run format:check
npm --prefix apps/web run typecheck
npm --prefix apps/web run lint
npm --prefix apps/web test
npm --prefix apps/web run build
```

Testes de browser, a partir de `apps/web` (requer backend previamente compilado em Release):

```sh
npx playwright install chromium
npm run test:e2e
```

Em Linux CI, `npx playwright install --with-deps chromium` também instala bibliotecas do SO. Playwright arranca Vite e a API reais, testa o cliente gerado/navegação/retry/offline nos tamanhos desktop e mobile e guarda capturas em `test-results/`, relatório em `playwright-report/`. O projeto `small-screen` usa Chromium com viewport/toque iPhone; **não é validação de Safari/iOS nativo**. Os testes Flutter/iOS são separados.

Para uma execução E2E isolada, parar instâncias locais em 5080/5173 ou definir `CI=true`; a CI nunca reutiliza outro processo. Sem mocks nos testes E2E de conectividade; os dois testes Vitest usam respostas sintéticas para os estados de UI.
