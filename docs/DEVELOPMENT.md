# Git, PRs e continuidade

## Repositório

Repositório público confirmado: [Dennyum204/HomeOfficeReservation](https://github.com/Dennyum204/HomeOfficeReservation), com `main` estável e branches curtas. A visibilidade é preservada. Git guarda versões; PRs, issues e proteções são funções do serviço GitHub. Exemplos, evidência e fixtures públicos devem ser sintéticos, sem segredos nem dados privados do calendário.

Uma só base reúne backend, Web, Mobile, contratos e documentos. Um PR pode alterar várias áreas quando entrega o mesmo comportamento. Não desenvolver backend completo e só depois descobrir incompatibilidades nas interfaces.

## Identificadores e fonte de verdade

- `docs/backlog.json`: inventário canónico de funcionalidades, versão, tarefas, dependências e critérios de aceitação.
- `ROADMAP.md` e `docs/BACKLOG.md`: gerados a partir desse JSON; não editar diretamente.
- `STATUS.md`: contexto atual, bloqueios e próxima tarefa.
- `docs/adr/`: decisões duráveis, incluindo alternativas e consequências.
- [GitHub Issues](https://github.com/Dennyum204/HomeOfficeReservation/issues): uma issue por cada um dos 24 IDs HO, incluindo releases futuras. Pesquisar issues abertas e fechadas antes de criar; reutilizar a issue do mesmo ID. Cada issue inclui aceitação, dependências e o URL real no JSON. Alterar versão/âmbito no mesmo PR que altera o JSON.
- Labels `release:v1.0`, `release:v1.1`, `release:v1.2`, `release:v2.0` e `area:<área>` refletem o backlog. Os [milestones de release](https://github.com/Dennyum204/HomeOfficeReservation/milestones) guardam os gates, sem inventar datas de entrega.
- Issues, labels e milestones são o tracking obrigatório. Um Project board é opcional e não é necessário para concluir HO-000.

HO-004 é um identificador de trabalho, não uma promessa de número de issue ou PR. Trabalhos grandes podem ser divididos em novos IDs com dependências e critérios próprios antes da implementação.

## Ciclo de trabalho

1. Inspecionar Git/remote e fazer fetch. Antes de avaliar dependências, verificar os PRs reais dos itens com estado potencialmente antigo: merge para `main`, commit integrado na base obtida (também para squash/rebase) e CI de integração relevante. Issue fechada, PR aberto ou texto do chat não comprovam integração.
2. Preservar trabalho existente, atualizar a base por fast-forward quando possível e criar uma branch delimitada, por exemplo `feat/ho-004-approval-workflow`, `fix/ho-009-sync-retry` ou `docs/ho-000-project-foundation`. Reconciliar nessa branch o backlog/STATUS com a evidência verificada e regenerar os documentos; só depois avaliar as dependências da tarefa escolhida. Não modificar `main` diretamente.
3. Implementar uma alteração delimitada. Conservar trabalho alheio e manter alterações partilhadas de contrato coordenadas.
4. Executar verificações relevantes, rever o diff e atualizar documentos.
5. Criar commits claros, por exemplo `feat(planning): support partial day approvals`.
6. Abrir PR em draft cedo quando já houver mudança concreta. Usar o modelo incluído; associar a issue real com `Closes #N` apenas quando o PR cumprir integralmente essa issue.
7. Rever código e comportamento; resolver checks, conversas e conflitos. Quando cumprir a tarefa, fazer o último push e verificar CI no SHA mais recente antes de retirar o draft. Entregar um PR sem draft, com checks relevantes verdes e sem conflitos. Qualquer push posterior exige nova verificação. Se incompleto, manter draft e enumerar os critérios pendentes.
8. Fernando revê e faz merge, preferencialmente por squash. O Codex é responsável por branches, commits, pushes, issues e preparação do PR; não faz merge nem ativa auto-merge.
9. Após merge humano, a tarefa seguinte confirma integração/CI e passa o item a `done` com URL/evidência, antes de avaliar as suas próprias dependências. Atualizar STATUS com a próxima tarefa.

Se o PR apenas propõe a conclusão, o estado no seu último commit pode ser `review`. O PR seguinte ou uma atualização documental de fecho confirma `done` após a integração. Nunca marcar como concluída apenas por abrir o PR.

## Proteção da main

Configurar e verificar no repositório real, usando o nome do check observado na CI:

- PR obrigatório, sem push direto de desenvolvimento.
- Checks obrigatórios e conversas resolvidas; sem force-push nem eliminação de main.
- Squash merge, eliminação de branches integradas e releases com tags semver.
- CODEOWNERS só com responsáveis reais; o exemplo incluído não atribui ninguém e não é uma exigência de revisão.
- Revisão obrigatória por outra pessoa quando existir um segundo revisor com permissões.

Se Fernando for o único mantenedor e autor das branches através do Codex, exigir uma aprovação independente no GitHub pode bloquear todos os PRs: o autor não aprova o próprio PR. Nesse cenário, manter PR + CI obrigatórios e revisão manual por Fernando antes do merge, sem configurar uma exigência impossível nem contornar checks. Ativar a revisão independente quando houver outro revisor.

Disponibilidade e enforcement dependem do plano/permissões do repositório. Registar o resultado real da configuração; não confundir um template com proteção ativa. [Proteções de branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches).

## CI/CD por fase

| Fase | Checks |
|---|---|
| HO-000 | `project-docs`: backlog, cobertura, dependências e documentos |
| HO-002 e projetos compiláveis | Format/lint/analyze, build, testes por stack e validação de contratos |
| Funcionalidades críticas | Integração com PostgreSQL e cenários de autorização/concorrência |
| Antes do piloto | E2E Web/Mobile, builds de distribuição, migração/restauro e Graph real de teste |

O scaffold deve acrescentar os jobs de cada stack no mesmo PR que cria o código. Checks obrigatórios usam nomes estáveis; não criar jobs que passam por saltar silenciosamente projetos existentes. Workflows de PR executam sem segredos de produção e sem `pull_request_target` para código não confiável.

Fixar actions em SHAs verificados e ativar atualização de dependências. O workflow documental usa um commit fixo de checkout; deve ser atualizado normalmente, sem tratar este pacote como uma lista imutável de versões.

Deploy automático para staging só depois de configurar o ambiente. Produção e lojas mobile seguem a autorização existente e os gates de release; este plano não publicou nenhum ambiente.

## Evidência HO-000

Ver [STATUS.md](../STATUS.md) e [notas do PR](pr/HO-000-PR.md) para a entrega atual. As proteções só serão descritas como ativas depois de a API GitHub devolver os valores configurados. A validação documental local não comprova CI remota nem integração na `main`.

## O que não deve ficar só no chat

Novas ideias entram no backlog com versão ou estado `parked` e motivo. Mudança de arquitetura entra num ADR. Correção de regra de negócio atualiza produto/domínio e um teste que a verifica. Cada fim de tarefa atualiza STATUS. A memória do chat é apoio; o repositório é a fonte de contexto do desenvolvimento.
