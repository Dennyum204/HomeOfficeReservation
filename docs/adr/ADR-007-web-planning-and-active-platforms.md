# ADR-007 — Planeamento Web fiável e plataformas ativas

Data: 2026-09-09. Tarefa: [HO-005 / issue #6](https://github.com/Dennyum204/HomeOfficeReservation/issues/6). Integrado em main pelo PR #32 em 2026-09-09T18:29:20Z; commit aeb4f38ab258b8bb8845e4887737f3697795cf81 e quatro checks de integração verificados em HO-006. O texto de decisão original abaixo é preservado. Mantém ADR-004/005/006; altera apenas a prioridade de plataformas e concretiza o cliente Web.

## Contexto e decisão de produto

O responsável adiou iOS. O desenvolvimento e os gates de release atuais abrangem **Web e Android**. A fonte iOS e a evidência histórica permanecem. Não há builds/tests iOS automáticos no core, nem investigação de falhas iOS. [HO-306](https://github.com/Dennyum204/HomeOfficeReservation/issues/31), num milestone próprio sem data, preserva a reativação futura. O workflow manual `ios-reference.yml` conserva a receita antiga para uma tarefa explicitamente selecionada; não foi executado em HO-005.

Foram lidas as proteções antes/depois e alterada exclusivamente a lista de checks obrigatórios: retirar `flutter-ios`, conservar `project-docs`, `backend-contracts`, `web`, `flutter-android`, com correspondência à aplicação GitHub Actions e strict ativo. PR obrigatório, conversas resolvidas, zero aprovações independentes, proteção de administradores, histórico linear e bloqueio de force-push/eliminação conservados. Não havia rulesets adicionais. Ver [DEVELOPMENT](../DEVELOPMENT.md). Não se substitui iOS por um check fictício.

## Decisão do cliente

React apresenta duas camadas: plano efetivo e propostas pendentes. Datas são valores locais date-only; a biblioteca gerada serializa os DTOs. O cliente não decide conflitos ou transições. Seleção, motivo e versões são congelados na confirmação; sucesso visual apenas depois do recibo real da API. Uma revisão mantém o plano aprovado até à decisão final do gestor.

Cada comando recebe uma chave nova. Antes do HTTP, a Web guarda em `sessionStorage` a representação wire produzida pelo cliente gerado, a chave e o contexto ator/colaborador. Nunca guarda cookies, passwords, CSRF ou tokens. Uma falha de resultado incerto bloqueia novas escritas e oferece recuperação explícita do **mesmo** comando, incluindo após reload. A recuperação verifica a conta atual e obtém CSRF novo, mantendo payload/chave. Payload alterado exige novo comando/chave. Se não for possível guardar o journal, não se envia a escrita.

HTTP 409/412/428 atualiza as leituras afetadas e conserva o texto. O utilizador tem de rever os dados antes de voltar a confirmar. Não se troca silenciosamente a versão de um comando que estava em revisão. Leituras usam AbortController e identidade de âmbito; respostas atrasadas não podem repor dados de outro colaborador ou acesso já recusado. Logout confirmado e troca de conta eliminam estado específico; expiração retira as vistas privadas. Um rascunho local só pode ser restaurado para o mesmo ator/colaborador.

O armazenamento é por separador, não uma fila offline entre dispositivos. Outro separador pode provocar uma versão antiga, tratada pela transação existente. Não há aprovação otimista, sincronização Microsoft ou notificações de negócio nesta entrega.

## Ajustes mínimos de contrato

`EffectiveDay.sourceRequestId` identifica o pedido responsável pelo dia em vigor, permitindo abrir/rever uma aprovação antiga sem percorrer todo o histórico. A projeção consulta apenas dias do colaborador já autorizado, na mesma leitura consistente.

`ListPlanningRequests.state` filtra no servidor antes de paginar e conserva a privacidade de rascunhos. Valor inválido devolve 400. OpenAPI e ambos os clientes são regenerados; não há migração, alteração das regras de decisão ou nova infraestrutura. O Android conserva a autenticação/conectividade; o seu calendário continua em HO-010.

## Alternativas e consequências

Uma biblioteca adicional de calendário/estado não era necessária para a grelha mês/semana e os fluxos atuais. Usam-se componentes por funcionalidade, controlos HTML, diálogo modal nativo, foco visível e navegação de grelha por teclado. A semântica e o comportamento reais são testados no Chromium desktop e estreito; estes testes não representam Safari/iOS nem uma auditoria completa com leitores de ecrã.

## Fontes oficiais consultadas em 2026-09-09

- [React — useEffect e prevenção de respostas fora de ordem](https://react.dev/reference/react/useEffect).
- [WAI-ARIA APG — grelha de datas e diálogo modal por teclado](https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/examples/datepicker-dialog/). O calendário é de planeamento e conserva botões nativos; o exemplo orienta foco e setas, não transfere regras de negócio.
- [Playwright — configuração de projetos, servidores e execução](https://playwright.dev/docs/test-configuration).
- [GitHub REST — atualização dos checks de proteção](https://docs.github.com/en/rest/branches/branch-protection#update-status-check-protection).

Evidência executada e limitações em [HO-005-WEB](../HO-005-WEB.md), STATUS e PR real. Graph real permanece adiado, não validado.
