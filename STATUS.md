# Estado do projeto

Atualizado: 2026-09-08.

## Situação verificável

- Fase: fundação documental HO-000; stack confirmada e implementação ainda não iniciada.
- Repositório público: [Dennyum204/HomeOfficeReservation](https://github.com/Dennyum204/HomeOfficeReservation). Visibilidade preservada.
- Branch: `docs/ho-000-project-foundation`. A inspeção inicial confirmou GitHub vazio; commit de bootstrap `378a111` publicado em `origin/main` tem árvore vazia; o commit existente `d17b150` foi preservado na branch. O histórico do bundle não foi importado.
- HO-000: `review`; entrega documental e tracking no [PR #25](https://github.com/Dennyum204/HomeOfficeReservation/pull/25), ligado à [issue HO-000 #1](https://github.com/Dennyum204/HomeOfficeReservation/issues/1). Aguarda revisão e merge por Fernando; ainda não integrado na `main`.
- GitHub CLI 2.100.0 autenticado como Dennyum204, com credencial no keyring, protocolo HTTPS e acesso ADMIN ao repositório. `gh auth setup-git --hostname github.com` e `gh auth status` executados; bloqueio de autenticação resolvido. O executável foi mantido numa instalação persistente fora do diretório temporário, para o helper Git continuar disponível.
- Tracking: [24 issues](https://github.com/Dennyum204/HomeOfficeReservation/issues), [12 labels de release/área](https://github.com/Dennyum204/HomeOfficeReservation/labels) e [quatro milestones](https://github.com/Dennyum204/HomeOfficeReservation/milestones). Pesquisa prévia não encontrou issues existentes; todos os URLs foram guardados em `docs/backlog.json`.
- Proteções de `main` aplicadas e relidas pela API GitHub: PR obrigatório, `project-docs` do GitHub Actions obrigatório e branch atualizada, conversas resolvidas, histórico linear e enforcement para admins. Zero aprovações independentes obrigatórias; force-push e eliminação de `main` proibidos. Apenas squash merge; eliminação de branches após merge ativa e auto-merge desativado. Detalhes em [DEVELOPMENT.md](docs/DEVELOPMENT.md).
- CI remota: o primeiro [run documental](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34263607655) passou em `c2393b2`. A verificação do SHA final e os checks mais recentes ficam registados no PR; só retirar draft depois de CI verde no último commit e ausência de conflitos.
- Validação: `scripts/check_project.py --write` e `scripts/check_project.py` passam (22 funcionalidades, 24 tarefas). É validação documental; não compila nem testa a aplicação.
- Verificações adicionais: diff sem erros de whitespace; 16 caminhos de outputs/segredos ignorados e 15 caminhos de lockfiles/migrações/exemplos preservados, mais chave Apple `.p8`; todos os 38 ficheiros do starter presentes e validador original inalterado; ZIP/bundle excluídos e revisão de assinaturas de credenciais sem deteções.
- Backend/Web/Mobile: apenas instruções e desenho; sem projetos compiláveis, SDKs fixados, migrações ou ambiente PostgreSQL configurado. HO-002 criará esses artefactos e os comandos reais.
- Conta Outlook real: não consultada nem ligada; nenhum evento criado.

## Próximo trabalho

HO-000 fica em `review` até ao merge humano. Não há bloqueio de autenticação pendente. Fernando revê o [PR #25](https://github.com/Dennyum204/HomeOfficeReservation/pull/25) e faz merge; o Codex não integra o PR nem ativa auto-merge.

Depois do merge humano: **HO-001 — Estudo de identidade Microsoft e Outlook**, com **Astra, reasoning `high`**. Verificar merge/CI de HO-000 e reconciliar o backlog antes de avaliar a dependência. HO-002 prepara os projetos numa tarefa posterior; nenhuma das duas está iniciada nesta entrega.

## Pressupostos a confirmar

| Tema | Pressuposto proposto | Quem resolve / quando |
|---|---|---|
| Outlook | Microsoft 365 empresarial / Exchange Online | Fernando e IT, HO-001 |
| Identidade | Ambos podem usar contas do mesmo tenant autorizado | HO-001 |
| Mobile | Android e iOS confirmados; meios de assinatura/distribuição privada por decidir | Fernando, HO-002/HO-012 |
| Localização inicial | Dias úteis presumidos presenciais, com etiqueta de padrão base | Fernando e chefe, HO-003 |
| Idioma | PT-PT inicialmente; estrutura preparada para outros idiomas | Fernando, HO-005 |
| Alojar aplicação | Contentores Linux e PostgreSQL, fornecedor/região/domínio por decidir | Fernando/empresa, HO-012 |

## Regra de continuidade

Cada PR atualiza este ficheiro com o estado real, decisão relevante, bloqueio concreto e próxima tarefa. Antes de avaliar dependências, verificar merge e CI reais e reconciliar estados antigos em `docs/backlog.json`; regenerar ROADMAP.md e docs/BACKLOG.md. PR aberto é `review`, não `done`. Fernando faz merge; o Codex não integra PRs nem ativa auto-merge. Não guardar segredos ou detalhes privados do Outlook aqui.
