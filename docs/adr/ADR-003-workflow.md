# ADR-003 — Continuidade com Git e Codex

Estado: aceite pelo responsável em HO-000, 2026-09-08. Proposta original: 2026-09-07.

## Contexto

As funcionalidades futuras e decisões não devem depender da memória de uma conversa. O Codex precisa de saber qual tarefa executar, onde editar e como verificar o resultado.

## Decisão confirmada

Um monorepo com main estável, branches curtas, PRs por alteração funcional, backlog JSON versionado, documentos de estado/ADRs e AGENTS.md raiz com instruções locais por área. Codex Astra é escolhido no ambiente de desenvolvimento, sem acoplar a aplicação ao modelo.

O Codex gere branches, commits, atualizações de issues e preparação dos PRs em [Dennyum204/HomeOfficeReservation](https://github.com/Dennyum204/HomeOfficeReservation). Fernando revê e faz merge; o Codex não integra PRs nem ativa auto-merge. Antes de verificar dependências, cada tarefa confirma evidência de merge/CI e reconcilia estados antigos. Trabalho completo termina num PR sem draft, com CI relevante verde no último commit e sem conflitos; trabalho parcial fica explicitamente marcado.

## Consequências

Cada mudança de âmbito atualiza o backlog. A validação automatizada deteta IDs/dependências/cobertura e documentos desatualizados. A CI da aplicação e revisão humana complementam as instruções; nenhum documento garante qualidade sozinho.

Não configurar uma aprovação independente impossível para um mantenedor único. Quando existir outro revisor, ativar proteção correspondente. A configuração real do GitHub só pode ser afirmada após verificação.

## Referência

[Descoberta e alcance de AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md). Instruções de pastas específicas complementam a raiz; os caminhos editados determinam quais devem ser consultadas.
