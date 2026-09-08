# HO-002 — Fundação executável

Data: 2026-09-08. Âmbito: scaffold/contratos/CI, issue [#3](https://github.com/Dennyum204/HomeOfficeReservation/issues/3). Sem implementação dos fluxos HO-003 e seguintes.

## Base verificada

[PR #27](https://github.com/Dennyum204/HomeOfficeReservation/pull/27) merged para main em **2026-09-08T20:02:47Z**, commit **7f783bf9bde5a72ac8271c42cc2916b054170d17**, confirmado na história de origin/main após fetch. [CI de integração 34272493270](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34272493270) passou `project-docs` nesse commit. HO-001 passa a done pelo âmbito documental revisto. Graph real permanece **deferred_by_product_direction**, nunca verificado. Branch HO-002 criada dessa base; trabalho anterior preservado.

## Resultado e limites

- Quatro projetos backend pequenos nas fronteiras já acordadas. Metadados usam Domain/Application e relógio injetado; Infrastructure tem EF/IdentityDbContext e health check de conexão real. Nenhuma abstração genérica vazia ou framework especulativo.
- `/health/live` mede o processo; `/health/ready` mede a conexão PostgreSQL. O endpoint `/api/v1/workspace` fornece timestamp atual e zonas IANA. Não exige sessão nem apresenta dados de calendário. O modelo Identity existe, mas criação de esquema/contas/auth é HO-003.
- Shells Web/Flutter com strings externalizadas, navegação e estados de ligação. Secções futuras visivelmente em preparação. Navegação não efetua aprovações fictícias.
- OpenAPI 3.0 gerado pelo backend, clientes estáveis TypeScript Fetch/Dart pelo mesmo gerador Java. Compara todos os outputs e ficheiros obsoletos; nada é duplicado manualmente.
- Compose persiste PostgreSQL local; configuração gerada fora do Git. Readiness não atesta migrações. Release mobile compila sem assinatura, HTTP somente em debug. Sem deployment/lojas/push ou contas reais nesta entrega.

## Ferramentas e fontes oficiais

Consultadas em **2026-09-08**; versões resolvidas/instaladas e fixadas nos ficheiros e lockfiles, não assumidas a partir de exemplos com latest.

| Ferramenta | Pin e fonte |
|---|---|
| .NET SDK/runtime | 10.0.400 / 10.0.11 — [metadados oficiais](https://builds.dotnet.microsoft.com/dotnet/release-metadata/10.0/releases.json), [suporte](https://learn.microsoft.com/en-us/dotnet/core/releases-and-support) |
| ASP.NET OpenAPI | Microsoft 10.0.11, OpenAPI 3.0 explícito também no build — [documentação](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/openapi/aspnetcore-openapi?view=aspnetcore-10.0) |
| EF/Npgsql | Microsoft Identity EF 10.0.11, Npgsql EF 10.0.3 — [fornecedor Npgsql](https://www.npgsql.org/efcore/) |
| PostgreSQL | 18.6-alpine3.24 — [imagem oficial e volume 18+](https://hub.docker.com/_/postgres) |
| Node/npm | 24.20.0 LTS / 11.19.0 — [distribuição oficial](https://nodejs.org/dist/v24.20.0/) |
| React/Vite/TypeScript | 19.2.8 / 8.2.2 / 6.0.3 — [Vite](https://vite.dev/guide/), [React](https://react.dev/learn/build-a-react-app-from-scratch), [typescript-eslint dependências](https://typescript-eslint.io/users/dependency-versions/) |
| Flutter/Dart | 3.47.2 / 3.13.2 — [arquivo estável](https://docs.flutter.dev/install/archive), [tag confirmada](https://github.com/flutter/flutter/tree/3.47.2), [localização](https://docs.flutter.dev/ui/internationalization) |
| Java/gerador | Temurin 21.0.12+8 / OpenAPI Generator 7.25.0, SHA-256 verificado — [Temurin](https://github.com/adoptium/temurin21-binaries/releases), [Dart](https://openapi-generator.tech/docs/generators/dart/), [TypeScript Fetch](https://openapi-generator.tech/docs/generators/typescript-fetch/) |
| Android/iOS | Gradle 9.3.1, AGP 9.1.0, Kotlin 2.4.0, SDK 36/NDK 28.2.13676358, Xcode 26.3 — [Android](https://docs.flutter.dev/deployment/android), [iOS](https://docs.flutter.dev/deployment/ios), [runner macOS](https://github.com/actions/runner-images/tree/main/images/macos) |

TypeScript 7 é mais recente no registry, mas typescript-eslint declara compatibilidade abaixo de 6.1; fixa-se 6.0.3. Os templates de geração Dart ajustam dependências e aguardam as respostas assíncronas dentro do try; ver [proveniência](../contracts/templates/README.md). Não são DTOs escritos à mão.

## Matriz de evidência

| Check | Evidência que fornece |
|---|---|
| project-docs | Validador original, 23 funcionalidades/24 IDs, derivados e links |
| backend-contracts | Restore locked, format/build, 2 testes API, 1 integração PostgreSQL EF, Kestrel real com ready 200/503, contrato sem drift |
| web | Typecheck/lint/build, 2 testes UI sintéticos, 4 browser tests reais desktop/small-screen, capturas |
| flutter-android | Análise app/cliente, format, 2 widget tests sintéticos, cliente Dart real, build release unsigned, smoke Android Emulator |
| flutter-ios | Build Simulator, build release device sem assinatura, smoke iPhone Simulator contra API real |

Resultados efetivos do último commit e URLs dos runs são registados no PR, depois de executados; a tabela define o que os jobs verificam, não substitui conclusão verde. No PC Windows foram instalados SDKs .NET/Node/Java/Flutter em cache privada; Docker e Android SDK/emulador não estavam instalados. iOS exige macOS. A CI é a evidência para essas plataformas/Compose. Não foi validado um dispositivo físico, assinatura/distribuição, Safari real, push ou autenticação. Estes limites não são falhas ocultadas e não se apresentam como funcionalidades prontas.

Os simuladores usam o endpoint real sem PostgreSQL porque metadados são independentes da base; o job backend verifica separadamente PostgreSQL real. O cliente VM Dart não é, isoladamente, validação de execução nativa; os smoke tests de plataforma são distintos.

Capturas reais do browser local com API ligada: [desktop](evidence/ho-002/shell-desktop.png) e [viewport pequeno](evidence/ho-002/shell-small-screen.png). Não são dados de calendário reais nem mockups de funcionalidades já implementadas.
