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
- Labels `release:v1.0`, `release:v1.1`, `release:v1.2`, `release:v2.0`, `release:outlook-publish`, `release:outlook-sync` e `area:<área>` refletem o backlog. Os [milestones](https://github.com/Dennyum204/HomeOfficeReservation/milestones) guardam gates separados: [publicação opcional](https://github.com/Dennyum204/HomeOfficeReservation/milestone/5) e [sincronização posterior](https://github.com/Dennyum204/HomeOfficeReservation/milestone/6) não condicionam o core. Sem datas de entrega inventadas.
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
| HO-001 revisto | `project-docs` normal; `outlook-probe-tests` só por workflow_dispatch com opção explícita, como referência sintética opcional |
| HO-002 e projetos compiláveis | Format/lint/analyze, build, testes por stack e validação de contratos |
| Funcionalidades críticas | Integração com PostgreSQL e cenários de autorização/concorrência |
| Antes do piloto core | E2E Web/Mobile com contas Identity, push real, builds, migração/restauro; sem Graph |
| HO-008/HO-009 opcionais | Validação real Microsoft própria, quando estes itens forem selecionados |

O scaffold deve acrescentar os jobs de cada stack no mesmo PR que cria o código. Checks obrigatórios usam nomes estáveis; não criar jobs que passam por saltar silenciosamente projetos existentes. Workflows de PR executam sem segredos de produção e sem `pull_request_target` para código não confiável.

Historicamente, HO-002 acrescentou `backend-contracts`, `web`, `flutter-android` e `flutter-ios` sem filtros de paths. HO-005 limita os alvos ativos a Web/Android: iOS sai da CI normal e dos checks obrigatórios, preservado no workflow manual `ios-reference.yml` para futura seleção HO-306. [Matriz e fontes](HO-002-FOUNDATION.md), comandos em [API](../apps/api/README.md), [Web](../apps/web/README.md) e [Mobile](../apps/mobile/README.md). PostgreSQL usa o Compose documentado no runner Linux; iOS usa macOS/Xcode 26.3. O código Dart gerado também é analisado. Lockfiles são obrigatórios e os clientes regenerados têm check de diff; os testes normais não precisam de Microsoft. Builds unsigned/Simulator não equivalem a lojas ou dispositivos físicos.

Fixar actions em SHAs verificados e ativar atualização de dependências. O workflow documental usa um commit fixo de checkout; deve ser atualizado normalmente, sem tratar este pacote como uma lista imutável de versões.

Deploy automático para staging só depois de configurar o ambiente. Produção e lojas mobile seguem a autorização existente e os gates de release; este plano não publicou nenhum ambiente.

## Evidência HO-000

Ver [STATUS.md](../STATUS.md), [PR #25](https://github.com/Dennyum204/HomeOfficeReservation/pull/25) e [notas do PR](pr/HO-000-PR.md). Configuração aplicada e confirmada por leitura da API GitHub em 2026-09-08:

| Definição | Valor verificado |
|---|---|
| Branch | `main` |
| Pull request obrigatório | Sim; inclui administradores |
| Check obrigatório | `project-docs`, GitHub Actions (`app_id: 15368`) |
| Branch atualizada antes de merge | Sim (`strict: true`) |
| Conversas resolvidas | Obrigatório |
| Aprovações independentes | `0`, adequado ao mantenedor único |
| Aprovação CODEOWNERS / último push por outra pessoa | Não exigidas |
| Force-push / eliminação de main | Proibidos |
| Histórico linear | Obrigatório |
| Método de merge | Apenas squash |
| Eliminar branch depois de merge | Ativo |
| Auto-merge | Desativado |
| Visibilidade | Pública, preservada |

O check foi observado no [run real](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34263607655), antes de o tornar obrigatório. Estes são os checks documentais disponíveis em HO-000; HO-002 acrescentará os checks reais das aplicações. Não foi exigida aprovação independente impossível, nem criado Project board, release/tag ou deployment.

## Proteções atualizadas em HO-002

Em 2026-09-08, após observar os nomes reais dos jobs, a API GitHub confirmou como obrigatórios **project-docs, backend-contracts, web, flutter-android e flutter-ios**, todos de GitHub Actions (`app_id: 15368`), com `strict: true`. Foram preservadas as restantes proteções HO-000, incluindo zero aprovações independentes e proibição de force-push/eliminação. Um check vermelho bloqueia a entrega e o merge; o PR #28 só sai de draft quando todos passarem no último commit. [Checks reais do PR](https://github.com/Dennyum204/HomeOfficeReservation/pull/28/checks). Nenhum merge ou auto-merge foi executado.

## Autenticação GitHub neste ambiente

O [probe Microsoft](../scripts/outlook_probe/README.md) é referência histórica opcional: onboarding interrompido, Graph real adiado. Normal desenvolvimento/CI exige zero credenciais Microsoft e não instala dependências do probe. Só workflow_dispatch com run_outlook_reference=true executa os testes sintéticos; nenhum workflow executa Graph real. A CI atual conserva quatro checks obrigatórios após o adiamento iOS em HO-005; a matriz HO-002 é histórica.

GitHub CLI e connector têm autenticações separadas. Nesta entrega, o connector recusou escrita com HTTP 403; a autenticação GitHub CLI resolveu o acesso Git e API, verificado com permissão ADMIN. Com `gh` instalado, o procedimento é:

```bash
gh auth login --hostname github.com --git-protocol https --web --scopes workflow
gh auth setup-git --hostname github.com
gh auth status
gh repo view Dennyum204/HomeOfficeReservation
```

Concluir o login no browser enquanto o código está válido. Não publicar palavras-passe, tokens ou o conteúdo do keyring; credenciais ficam fora do repositório. Manter o executável usado pelo helper Git numa instalação persistente. O scope `workflow` permite publicar o workflow de CI incluído nesta entrega.

## O que não deve ficar só no chat

Novas ideias entram no backlog com versão ou estado `parked` e motivo. Mudança de arquitetura entra num ADR. Correção de regra de negócio atualiza produto/domínio e um teste que a verifica. Cada fim de tarefa atualiza STATUS. A memória do chat é apoio; o repositório é a fonte de contexto do desenvolvimento.

## Direção e proteções verificadas em HO-005 — 2026-09-09

Por instrução explícita do responsável, os alvos atuais são Web e Android. A API GitHub foi lida antes/depois: apenas `flutter-ios` removido de required_status_checks. Permanecem `project-docs`, `backend-contracts`, `web` e `flutter-android`, app_id 15368, strict true. PR, conversas resolvidas, enforce_admins, histórico linear, zero aprovações independentes, proibição de force-push/eliminação e restantes valores foram comparados e preservados. Não existem rulesets adicionais. Não se alterou a visibilidade nem se criou um check iOS fictício.

`ios-reference.yml` tem apenas workflow_dispatch, reservado à futura reativação selecionada; não foi executado em HO-005. Fonte nativa, scripts e evidência histórica iOS ficam conservados. Shared Flutter/Dart, Android, backend, contratos, documentação e Web continuam obrigatórios. HO-306 fica parked sem data. A matriz/evidência HO-002 acima é histórica.
