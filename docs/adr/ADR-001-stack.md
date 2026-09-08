# ADR-001 — Stack e organização

Estado: aceite pelo responsável em HO-000, 2026-09-08. Proposta original: 2026-09-07.

## Contexto

Dois utilizadores precisam de uma Web com calendário completo e de aplicações mobile. Fernando tem experiência em C#, React e Flutter. A aprovação e a sincronização precisam de regras consistentes e transações.

## Decisão confirmada

Monorepo, ASP.NET Core .NET 10, PostgreSQL/EF Core, React/TypeScript Web e Flutter Mobile. Backend modular com worker durável alojado no processo da API. Contrato OpenAPI e clientes gerados em TypeScript/Dart.

## Alternativas consideradas

- React Native/Expo permitiria partilhar mais TypeScript com a Web; exige adotar outra stack mobile em vez de aproveitar Flutter.
- Flutter também na Web reduziria linguagens de UI, mas optamos por React para a experiência desktop do dashboard.
- PWA apenas simplificaria distribuição; não corresponde à proposta de app Android/iOS desta V1.
- Microserviços acrescentariam operação e coordenação sem uma necessidade atual.

## Consequências

Mantemos dois conjuntos de componentes UI; partilhamos o contrato, as regras no servidor e a linguagem visual. O worker precisa de alojamento ativo e armazenamento durável. Bibliotecas e versões exatas são fixadas em HO-002 após validação de compatibilidade.

## A validar

Flutter para Android e iOS está confirmado. Permanecem em aberto os meios de assinatura/distribuição do piloto, as integrações Microsoft opcionais (HO-008/HO-009); identidade própria escolhida em ADR-004 e o fornecedor/região de alojamento (HO-012). A confirmação está no [pedido HO-000](../CODEX_PROMPTS.md); não significa que existam projetos compiláveis ou integrações testadas.
