# Ajustes de geração

OpenAPI Generator 7.25.0, JAR verificado pelo SHA-256 de `contracts/generator.json`.

- `dart/pubspec.mustache`: dependências compatíveis fixadas; substitui o intervalo antigo de `test` da ferramenta. O pacote gerado não contém testes vazios. Os consumidores e o pacote têm lockfiles.
- `dart/api_client.mustache`: template `dart2/api_client.mustache` do mesmo JAR, com apenas três `return Response.fromStream(response)` alterados para `return await Response.fromStream(response)`. Mantém erros assíncronos dentro do `try` e satisfaz o diagnóstico `unawaited_return_in_try_block` de Dart 3.13. Não altera modelos ou implementa autenticação.
- TypeScript usa os templates originais. O diretório correspondente fica vazio intencionalmente.
- O script uniformiza LF e whitespace final. Não editar DTOs/clientes gerados. Rever/remover os ajustes ao atualizar a ferramenta.

Fonte: [OpenAPI Generator, tag v7.25.0](https://github.com/OpenAPITools/openapi-generator/tree/v7.25.0/modules/openapi-generator/src/main/resources/dart2), consultada em 2026-09-08. Templates mantêm a licença Apache-2.0 do projeto de origem.
