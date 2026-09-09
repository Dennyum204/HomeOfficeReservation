# Continuidade Codex

Direção atual: Web e Android; iOS adiado para HO-306, sem data e sem debug no core. Trabalhar apenas no item explicitamente selecionado. HO-005 implementa o calendário Web sobre HO-004; consultar STATUS.md e backlog canónico para evidência atual, dependências e próximo item.

## Referência histórica de preparação HO-002

# Tarefas para Codex

Ler AGENTS.md e a fonte canónica docs/backlog.json. Os prompts antigos que exigiam Outlook em V1 foram substituídos pela direção registada em [ADR-004](adr/ADR-004-independent-core.md). [CODEX_PROMPTS.md](CODEX_PROMPTS.md) e notas de HO-000 são histórico, não requisitos atuais.

## Tarefa atual — HO-002

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

HO-002 está no [PR #28](https://github.com/Dennyum204/HomeOfficeReservation/pull/28). Depois de merge humano e CI de integração verificados, selecionar **HO-003** para autenticação Identity, membros/relações/autorizações conforme ADR-004 e os seus critérios canónicos. Fazer fetch, reconciliar HO-002 para done e criar branch própria antes de implementar. O prompt de HO-002 acima preserva o âmbito da entrega atual; não repetir o scaffold nem retomar Microsoft.

Trabalhar só no item pedido. Cada início verifica merge/CI e reconcilia estados antes de avaliar dependências. Preservar alterações existentes; cada mudança usa branch delimitada. Critérios, contratos e testes acompanham o comportamento implementado. Uma simulação não valida serviço externo.

Trabalho completo é entregue sem draft com CI relevante verde e sem conflitos; trabalho incompleto fica draft com passos concretos. `done` exige integração verificada. Alterações de âmbito preservam IDs, issue history e decisões anteriores. HO-001 é o ID da tarefa, não o número da issue.

## Integrações opcionais

Retomar registo/consentimento/probe apenas ao selecionar HO-008 ou HO-009 explicitamente. Estudo legado é referência; adaptar ensaio ao âmbito autorizado. Não pedir Microsoft para scaffold, login ou calendário core. HO-008 publica dias confirmados; HO-009 retoma leituras e mecanismos avançados. Microsoft login opcional futuro não é requisito de nenhuma destas tarefas core.

## Continuidade após HO-003

HO-003 implementa autenticação/membros nas três áreas. Depois de revisão/merge humano e CI de integração verificados, selecionar **HO-004 — planeamento e aprovação transacional na API**. Fazer fetch, reconciliar o tracking e só então começar a tarefa separada. O prompt HO-002 acima é referência histórica, não instrução para repetir scaffold ou autenticação.
