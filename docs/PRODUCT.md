# Produto e âmbito da V1

## Objetivo e utilizadores

Um colaborador e o seu chefe planeiam localização e disponibilidade com antecedência. O desenho dos dados suporta mais utilizadores, mas a V1 não inclui administração completa de várias empresas.

| Papel | Pode fazer |
|---|---|
| Employee | Consultar o próprio plano, submeter/rever/cancelar pedidos, comentar, gerir a sua ligação Outlook, confirmar leitura, atualizar tarefas atribuídas |
| Manager | Consultar colaboradores atribuídos, decidir pedidos, propor datas, criar compromissos presenciais e atribuir tarefas |
| Admin | Configurar membros e relações de aprovação; não recebe automaticamente acesso a conteúdo privado do Outlook |

Um utilizador pode acumular papéis, mas nunca aprovar o próprio pedido. Identidades usam IDs estáveis do fornecedor; não confiar apenas no endereço de email. A associação de chefe é configurada pela aplicação, não inferida do Microsoft Graph.

## V1: comportamento funcional

### Calendário e dashboard

- Calendário mensal e semanal, com agenda compacta no mobile.
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
- Reunião Outlook, por si só, é aviso de sobreposição. Só um compromisso criado/resolvido na aplicação impõe presença física.

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

### Outlook

Sincronização do calendário principal da própria conta ligada, publicação de planeamento confirmado e importação de disponibilidade. Fonte e comportamento de alterações definidos em [OUTLOOK.md](OUTLOOK.md).

O chefe vê apenas intervalos indisponíveis necessários ao planeamento, não títulos/corpos de eventos privados. A ligação do chefe é opcional e independente; não é necessária para publicar no calendário do colaborador.

### Férias e indisponibilidade

Registo manual para planeamento. Não substitui autorização de férias de RH. Uma indisponibilidade sobre datas confirmadas abre conflito/revisão, sem apagar silenciosamente decisões. Na V1 os períodos são dias inteiros.

## Aceitação do produto

1. Colaborador submete cinco dias pela Web; chefe aprova três pelo mobile; ambos veem os mesmos três dias confirmados.
2. Dois dias rejeitados não aparecem no Outlook como home office aprovado.
3. Uma instalação sobre um dia aprovado abre conflito e mantém a aprovação até à resolução explícita.
4. Um segundo clique/retry da mesma decisão não duplica decisão, evento ou notificação interna.
5. Uma decisão efetuada com versão antiga é recusada e a UI recupera com informação atual.
6. O mesmo dia permanece o mesmo ao abrir o calendário em Lisboa e Zurique, incluindo mudanças de hora.
7. Uma falha temporária do Outlook não desfaz a aprovação; apresenta sincronização pendente e recupera.
8. O chefe não consulta pedidos de outro colaborador sem relação de gestão nem vê detalhes privados do Outlook.
9. Web e mobile cobrem os fluxos essenciais para ambos os papéis.
10. O utilizador sabe se as datas vêm do padrão base, de aprovação ou de obrigação presencial.

Os critérios detalhados por entrega estão em [BACKLOG.md](BACKLOG.md).
