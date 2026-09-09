export const n = {
  title: "Notificações",
  intro:
    "Atualizações do seu trabalho, com ligações ao estado atual de cada pedido, presença ou tarefa.",
  unread: "Não lidas",
  all: "Todas as atuais",
  archive: "Histórico anterior às notificações",
  filter: "Filtrar notificações",
  empty: "Não há notificações neste filtro.",
  read: "Lida",
  unreadLabel: "Por ler",
  markRead: "Marcar como lida",
  markUnread: "Marcar como não lida",
  open: "Abrir contexto",
  unavailable:
    "O contexto já não está disponível. Nenhuma decisão foi alterada.",
  error: "Não foi possível atualizar as notificações. Tente novamente.",
  refresh: "Atualizar notificações",
  updated: "Estado de leitura guardado.",
  loading: "A carregar notificações…",
  more: "Página seguinte",
  back: "Página anterior",
  automatic:
    "Atualização automática enquanto esta página está visível. A leitura não aprova pedidos nem confirma presenças.",
  archiveHint:
    "Eventos anteriores à ativação deste centro. Não geraram push e não contam como novas notificações.",
  events: {
    "planning.submitted": "Pedido ou revisão submetido",
    "planning.withdrawn": "Pedido retirado",
    "planning.decided": "Decisão registada no pedido",
    "planning.counterproposed": "Nova contraproposta ou alteração",
    "planning.counterproposal-accepted":
      "Contraproposta aceite — aguarda decisão",
    "onsite.created": "Nova presença obrigatória",
    "onsite.edited": "Presença obrigatória alterada",
    "onsite.cancelled": "Presença obrigatória cancelada",
    "task.assigned": "Nova tarefa atribuída",
    "task.updated": "Tarefa alterada",
    "context.unavailable": "Atualização indisponível",
  } as Record<string, string>,
};
