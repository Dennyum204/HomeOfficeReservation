# Produto e âmbito da V1

## Plataformas atuais

A direção confirmada em HO-005 é **Web e Android**. Todas as referências a mobile no core significam Android. iOS está adiado, não cancelado: preservar código e evidência histórica, sem builds/testes automáticos, distribuição obrigatória ou data de entrega. HO-306 regista a reativação futura.

## Objetivo e utilizadores

A aplicação tem calendário próprio autoritativo e funciona integralmente sem conta Microsoft ou ligação Outlook. Um colaborador e o seu chefe usam contas locais da aplicação para planear localização e disponibilidade com antecedência. O desenho dos dados suporta mais utilizadores, mas a V1 não inclui administração completa de várias empresas.

| Papel | Pode fazer |
|---|---|
| Employee | Consultar o próprio plano, submeter/rever/cancelar pedidos, comentar, gerir a sua ligação Outlook, confirmar leitura, atualizar tarefas atribuídas |
| Manager | Consultar colaboradores atribuídos, decidir pedidos, propor datas, criar compromissos presenciais e atribuir tarefas |
| Admin | Configurar membros e relações de aprovação; não recebe automaticamente acesso a conteúdo privado do Outlook |

Um utilizador pode acumular papéis, mas nunca aprovar o próprio pedido. Identidades usam IDs locais estáveis do ASP.NET Core Identity associados ao MemberId; não confiar apenas no endereço de email. A associação de chefe é configurada pela aplicação, não inferida do Microsoft Graph.

## V1: comportamento funcional

O acesso é privado, sem registo público. HO-013 permite ao operador criar explicitamente o titular como administrador e colaborador na mesma identidade ou acrescentar colaboração a um administrador ativo existente. O chefe distinto precisa de papel gestor e associação explícita; administrar não concede autoridade de aprovação. HO-014 implementa convites Identity e entrega durável; HO-015 acrescenta a [administração Web](HO-015-WEB-ADMINISTRATION.md). O piloto operacional permanece pendente em HO-012; esta entrega não autoriza convites reais.

### Calendário e dashboard

- Calendário próprio mensal e semanal, com agenda compacta no mobile, mostrando remoto em Portugal, presencial na Suíça, pedidos pendentes e períodos presenciais obrigatórios. Web/mobile partilham o mesmo backend e dados autoritativos.
- Localização confirmada, pedido pendente e obrigação presencial visíveis sem perder informação por sobreposição de cores.
- Estados de disponibilidade separados: a trabalhar, férias e indisponível.
- Padrão base configurável, inicialmente proposto como presencial nos dias úteis. A UI identifica o que vem do padrão e o que foi confirmado. Fins de semana são neutros, salvo seleção explícita.
- Não alterar retroativamente datas concluídas através da mudança do padrão base.
- Resumos contam apenas dias de trabalho; pendentes, aprovados e ausências têm totais distintos.
- Pedidos para decidir, conflitos por resolver, próxima presença obrigatória e próxima estadia aprovada.

### Pedidos e decisões

- Selecionar dias ou intervalo; pré-visualizar dias incluídos e fins de semana excluídos antes de submeter.
- Rascunho privado; pedido submetido com datas congeladas nessa revisão.
- Aprovar/rejeitar por dia; o resumo do pedido é derivado das decisões por dia.
- Rejeição e contraproposta exigem uma razão curta. Aprovação pode ter comentário.
- Uma contraproposta não reserva nem aprova dias: se o colaborador a aceitar, cria uma revisão pendente para decisão final do chefe.
- O colaborador pode retirar um pedido ainda pendente. Alterar/cancelar dias já aprovados cria uma proposta que mantém o plano vigente até à decisão.
- Aprovações concorrentes usam controlo de versão; quem tem dados antigos recebe aviso para atualizar.
- Comentários ficam no contexto do pedido/compromisso. Sem edição silenciosa do histórico de decisões.

### Presença e conflitos

- Chefe define intervalo de dias, motivo, local e máquina/projeto opcional.
- Na V1 o compromisso é por dia inteiro; horários detalhados e meios dias ficam em V1.2.
- Se não houver conflito, a presença necessária fica ativa e o colaborador confirma apenas leitura.
- Se houver home office já aprovado, o compromisso fica `NeedsResolution`. A aprovação existente mantém-se; os dois veem a divergência.
- Resolução: chefe altera/cancela o compromisso, ou inicia uma revisão das datas que o colaborador reconhece e o chefe aprova. A ativação da presença e substituição dos dias incompatíveis é atómica.
- Confirmação de leitura não equivale a concordar com uma mudança de uma aprovação.
- Os conflitos do core são calculados com pedidos, plano confirmado, presenças e indisponibilidade manual da aplicação. Reuniões Outlook não são importadas no core.

### Tarefas

- Título, descrição curta, responsável, prazo, estado e referência opcional a projeto/compromisso.
- Estados: Todo, InProgress, Done, Cancelled.
- `RequiresOnsite` assinala necessidade; não altera localização nem cria uma obrigação sem decisão explícita do chefe.
- A criação de uma obrigação a partir de uma tarefa é uma ação explícita, com pré-visualização das datas.
- Não inclui Gantt, timesheets, dependências avançadas ou gestão de manutenção.

### Notificações

- Centro de notificações persistente Web/Mobile e push mobile para submissão, decisão, contraproposta, alteração, obrigação presencial e tarefa atribuída.
- Conteúdo de push discreto: resumo genérico e ligação segura; detalhes só após autenticação.
- Decisões exigem abrir a aplicação autenticada; tocar numa notificação não aprova nada.
- Recusa de permissão push não impede utilizar a aplicação; a notificação interna mantém-se.
- Leituras sincronizadas entre dispositivos. Push é uma tentativa de entrega, não prova de leitura.
- Emails, resumos semanais e lembretes automáticos entram em V1.1.

### Outlook opcional, após o core

Ligação apenas em Definições, sem requisito para login, planeamento ou lançamento. O primeiro marco opcional HO-008 publica unidirecionalmente dias explícitos de localização confirmada no calendário principal do utilizador ligado: disponibilidade livre por defeito, eventos próprios e sem convites. Trabalho remoto não é ausência. Sem ligação, o calendário interno e todos os fluxos permanecem completos.

Importação de disponibilidade, delta, webhooks e reconciliação de edições externas ficam em HO-009/marco posterior. Ambos permanecem no backlog. Contrato em [OUTLOOK.md](OUTLOOK.md); autenticação independente em [ADR-004](adr/ADR-004-independent-core.md).

### Férias e indisponibilidade

Registo manual para planeamento. Não substitui autorização de férias de RH. Uma indisponibilidade sobre datas confirmadas abre conflito/revisão, sem apagar silenciosamente decisões. Na V1 os períodos são dias inteiros.

## Aceitação do produto

Admissão privada HO-014: só o administrador ativo convida para a sua organização. Pending/Accepted/Cancelled e estado de entrega são distintos; expiração do código Identity não apaga o convite. Reenvio invalida códigos anteriores; cancelamento é terminal. Web/Android aceitam código/password sem registo público. Interface administrativa autónoma pertence a HO-015. [Percurso e limites](HO-014-INVITATIONS.md).

1. Colaborador submete cinco dias pela Web; chefe aprova três pelo mobile; ambos veem os mesmos três dias confirmados.
2. Dois dias rejeitados não aparecem como aprovados no calendário interno; não é preciso configurar integração externa.
3. Uma instalação sobre um dia aprovado abre conflito e mantém a aprovação até à resolução explícita.
4. Um segundo clique/retry da mesma decisão não duplica decisão, evento ou notificação interna.
5. Uma decisão efetuada com versão antiga é recusada e a UI recupera com informação atual.
6. O mesmo dia permanece o mesmo ao abrir o calendário em Lisboa e Zurique, incluindo mudanças de hora.
7. Todas as jornadas core funcionam com contas locais e nenhuma configuração Microsoft; indisponibilidade de um conector opcional não bloqueia decisões.
8. O chefe não consulta pedidos de outro colaborador sem relação de gestão; detalhes privados de futuros calendários ligados não são expostos.
9. Web e mobile cobrem os fluxos essenciais para ambos os papéis.
10. O utilizador sabe se as datas vêm do padrão base, de aprovação ou de obrigação presencial.

Os critérios detalhados por entrega estão em [BACKLOG.md](BACKLOG.md).

### Concretização HO-007

A caixa persistente e a leitura sincronizada funcionam em Web/Android independentemente de push. O tratamento completo dos destinos Android fica para HO-010/011; há detalhe explícito com referência e indicação da Web. O adaptador Android é FCM, com configuração opcional para desenvolvimento. Entrega real foi observada no emulador autorizado em foreground, background e cold start; reconexão/logout/troca de conta foram ensaiados contra os serviços reais. Recibo/aceitação do fornecedor não equivalem a leitura nem aprovação. Dispositivos físicos e distribuição não foram validados. [Guia e evidência datada](HO-007-NOTIFICATIONS.md).

### Concretização HO-010

Calendário e pedidos Android permitem os dois papéis: decisões parciais, retirada, revisões/cancelamentos, contrapropostas e disponibilidade manual, com dados autoritativos partilhados com a Web. Notificações de pedidos abrem o detalhe atual, sem executar decisões. Presenças/tarefas completas Android e aceitação transversal restante continuam em HO-011. [Guia e evidência](HO-010-ANDROID-PLANNING.md).

Identidade visual HO-016: Web/Android usam superfícies neutras e temas claro/escuro/sistema. Localização usa ícones e texto; estado de aprovação, plano confirmado, proposta e conflito são distinguíveis sem depender de cor. [Decisão e âmbito](adr/ADR-017-shared-visual-theme.md).
