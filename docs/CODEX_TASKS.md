# Tarefas para Codex

Ler AGENTS.md e a fonte canónica docs/backlog.json. Os prompts antigos que exigiam Outlook em V1 foram substituídos pela direção registada em [ADR-004](adr/ADR-004-independent-core.md). [CODEX_PROMPTS.md](CODEX_PROMPTS.md) e notas de HO-000 são histórico, não requisitos atuais.

## Próxima tarefa — HO-002

```text
Implementa apenas HO-002 em Dennyum204/HomeOfficeReservation.
Lê AGENTS.md, README.md, STATUS.md, ROADMAP.md, docs/BACKLOG.md,
docs/ARCHITECTURE.md, ADR-004 e instruções das áreas.
Faz fetch, verifica merge/CI do PR #27, reconcilia HO-001 antes de avaliar
as dependências e cria branch própria a partir da main atualizada.

Cria projetos compiláveis ASP.NET Core/.NET 10, React/TypeScript e Flutter
Android/iOS, PostgreSQL local, versões/lockfiles, OpenAPI e geração reproduzível
TypeScript/Dart, com checks reais. Core sem conta Microsoft, Graph ou probe.
Segue a decisão ASP.NET Core Identity; autenticação funcional é HO-003.
Não implementes já pedidos/aprovações nem inicies outro work item.

Documenta comandos executados, atualiza backlog/STATUS, regenera documentos,
abre PR com issue real e verifica CI no último SHA e ausência de conflitos.
Fernando revê e faz merge; não faças merge nem atives auto-merge.
```

## Continuidade geral

Trabalhar só no item pedido. Cada início verifica merge/CI e reconcilia estados antes de avaliar dependências. Preservar alterações existentes; cada mudança usa branch delimitada. Critérios, contratos e testes acompanham o comportamento implementado. Uma simulação não valida serviço externo.

Trabalho completo é entregue sem draft com CI relevante verde e sem conflitos; trabalho incompleto fica draft com passos concretos. `done` exige integração verificada. Alterações de âmbito preservam IDs, issue history e decisões anteriores. HO-001 é o ID da tarefa, não o número da issue.

## Integrações opcionais

Retomar registo/consentimento/probe apenas ao selecionar HO-008 ou HO-009 explicitamente. Estudo legado é referência; adaptar ensaio ao âmbito autorizado. Não pedir Microsoft para scaffold, login ou calendário core. HO-008 publica dias confirmados; HO-009 retoma leituras e mecanismos avançados. Microsoft login opcional futuro não é requisito de nenhuma destas tarefas core.
