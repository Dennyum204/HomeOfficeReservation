# Estado do projeto

Atualizado: 2026-09-08.

## Situação verificável

- Fase: fundação documental HO-000; stack confirmada e implementação ainda não iniciada.
- Repositório público: [Dennyum204/HomeOfficeReservation](https://github.com/Dennyum204/HomeOfficeReservation). Visibilidade preservada.
- Branch: `docs/ho-000-project-foundation`. A inspeção inicial confirmou GitHub vazio; commit local de bootstrap `378a111` tem árvore vazia. O histórico do bundle não foi importado.
- HO-000: `blocked`; ficheiros integrados na raiz e documentação validada. Push, tracking e PR ainda dependem da autenticação Git local. Nenhuma issue, milestone, label, proteção ou PR remoto foi criado nesta entrega.
- A ligação GitHub lê o repositório, mas a criação de issue devolveu HTTP 403, `Resource not accessible by integration`. Git Credential Manager iniciou o login; nenhum token foi guardado no repositório.
- Validação: `scripts/check_project.py --write` e `scripts/check_project.py` passam (22 funcionalidades, 24 tarefas). É validação documental; não compila nem testa a aplicação.
- Verificações adicionais: diff sem erros de whitespace; 16 caminhos de outputs/segredos ignorados e 15 caminhos de lockfiles/migrações/exemplos preservados, mais chave Apple `.p8`; todos os 38 ficheiros do starter presentes e validador original inalterado; ZIP/bundle excluídos e revisão de assinaturas de credenciais sem deteções.
- Backend/Web/Mobile: apenas instruções e desenho; sem projetos compiláveis, SDKs fixados, migrações ou ambiente PostgreSQL configurado. HO-002 criará esses artefactos e os comandos reais.
- Conta Outlook real: não consultada nem ligada; nenhum evento criado.

## Próximo trabalho

Concluir a publicação e verificação remota de HO-000, mantendo a tarefa em `review` depois de abrir o PR. Fernando revê e faz merge.

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
