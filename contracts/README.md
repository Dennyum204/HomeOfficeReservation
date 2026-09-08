# Contrato entre backend, Web e Mobile

HO-002 implementa `GET /api/v1/workspace` e gera [openapi.json](openapi.json) a partir dos metadados ASP.NET Core. OpenAPI **3.0** escolhido explicitamente tanto no build como no endpoint Development, pela compatibilidade dos dois geradores estáveis. Não inclui endpoints de negócio fictícios.

## Regenerar e verificar

Requer .NET SDK de `global.json`, Java Temurin 21.0.12.1+1 e Python 3.10+. Restaurar o backend antes. Na raiz:

```sh
dotnet restore apps/api/HomeOffice.slnx --locked-mode
python scripts/generate_contracts.py
python scripts/generate_contracts.py --check
```

O build executa geração oficial Microsoft.Extensions.ApiDescription.Server, sem ouvir numa porta nem ligar à base de dados. O script ordena JSON, gera TypeScript/Dart com **OpenAPI Generator 7.25.0**, verifica SHA-256 do JAR antes de o executar e uniformiza whitespace. Cache em `~/.cache/homeoffice-tools` ou `HO_TOOLS_CACHE`. Os 20 ficheiros gerados são comparados, incluindo deteção de ficheiros obsoletos; `--check` falha sem alterar os ficheiros versionados. CI exige correspondência, sem credenciais.

`typescript/` é importado pela Web; `dart/` é package de dependência por caminho do Flutter. Tipos vêm do backend: não copiar DTOs nem editar outputs. Os pequenos [templates de dependências/compatibilidade Dart](templates/README.md) são entradas da geração, com origem/licença registadas. Os geradores incluem helpers genéricos de autenticação sem utilização; não implementam o login da aplicação.

Após mudar dependências do template, executar `dart pub get` em `contracts/dart` e `flutter pub get` em `apps/mobile` e versionar os lockfiles. Em CI usar `--enforce-lockfile`; analisar o cliente Dart além da aplicação. Tests Web E2E e `apps/mobile/tool/smoke_api.dart` consomem os clientes gerados contra API real.

Fontes oficiais consultadas em 2026-09-08: [OpenAPI ASP.NET Core](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/openapi/aspnetcore-openapi?view=aspnetcore-10.0), [TypeScript Fetch](https://openapi-generator.tech/docs/generators/typescript-fetch/), [Dart](https://openapi-generator.tech/docs/generators/dart/).

## Convenções propostas

| Grupo | Operações esperadas |
|---|---|
| `/api/v1/me` | Identidade, papéis e relações visíveis |
| `/api/v1/calendar` | Projeção por intervalo, versão e avisos |
| `/api/v1/remote-requests` | Rascunho, submeter, detalhe, decisão por dias, retirar |
| `/api/v1/change-proposals` | Propor e resolver alteração de datas aprovadas |
| `/api/v1/onsite-requirements` | Criar, alterar, reconhecer leitura e resolver conflito |
| `/api/v1/tasks` | Atribuir, consultar e atualizar estado |
| `/api/v1/notifications` | Listar e marcar lida |
| `/api/v1/devices` | Registar/atualizar/remover token push do próprio utilizador |
| `/api/v1/auth` (HO-003) | Login/refresh/logout e conta, usando ASP.NET Core Identity |
| `/api/v1/integrations/outlook` (HO-008) | Ligação opcional, estado de publicação e desligar; reconciliação apenas HO-009 |

Estes são grupos de desenho, não endpoints implementados. O scaffold/contrato core não depende de Microsoft; o contrato Identity deve refletir cookies Web e bearer/refresh opacos no mobile, sem inventar JWT/OAuth. Endpoints de decisão usam comandos explícitos; não expor um PATCH genérico que permita mudar `Approved=true` ignorando regras.

- IDs estáveis, datas date-only e instantes distintos.
- ETag/versão esperada e Idempotency-Key nos comandos relevantes.
- Erros Problem Details com código de negócio e correlation ID.
- Paginação e limites explícitos; nullability consistente.
- OpenAPI e clientes regenerados no mesmo PR da mudança.
- Alterações compatíveis/aditivas por defeito. Remoção/renomeação requer transição de clientes e decisão de versão.
- CI regenera e deteta diff; não editar manualmente código gerado.
