export const a = {
  title: "Administração",
  intro: "Membros, convites e chefias da sua organização.",
  members: "Membros da organização",
  invite: "Convidar membro",
  search: "Procurar por nome ou email",
  empty: "Não foram encontrados membros.",
  loading: "A carregar membros…",
  refresh: "Atualizar membros",
  more: "Mostrar mais membros",
  forbidden: "Não tem autorização para administrar esta organização.",
  readError:
    "Não foi possível consultar os membros. Verifique a ligação e tente novamente.",
  detail: "Gerir membro",
  close: "Voltar à lista",
  identity: "Identificação",
  name: "Nome",
  email: "Email do convite",
  roles: "Papéis e acesso",
  employee: "Colaborador",
  manager: "Gestor",
  admin: "Administrador",
  active: "Acesso ativo",
  self: "Esta é a sua conta. Pode gerir membros e usar o seu calendário. Os seus papéis e acesso só podem ser alterados por outro administrador ou pelo procedimento restrito ao operador.",
  saveRoles: "Rever papéis e acesso",
  saveManager: "Rever associação",
  currentManager: "Chefe atual",
  selectManager: "Chefe associado",
  none: "Sem chefe associado",
  unavailableManager:
    "Chefe sem autoridade atual; reveja a associação ou os papéis.",
  relationship: "Chefia e decisões",
  relationshipHelp:
    "Só um gestor distinto, ativo e associado pode decidir os pedidos deste colaborador. Administrar não permite autoaprovação.",
  relationImpact:
    "Mudar ou retirar a chefia altera quem pode decidir e consultar os pedidos deste colaborador. O calendário e o histórico são preservados.",
  roleImpact:
    "As permissões são aplicadas imediatamente pela API. Suspender bloqueia o acesso; retirar o papel de gestor impede decisões para os colaboradores associados. Os dados e o calendário são preservados. Não é permitido remover o último administrador ativo.",
  pendingImpact:
    "Atenção: suspender uma conta ainda por ativar cancela definitivamente o convite e invalida os códigos. Um convite cancelado não pode ser reaberto.",
  invitation: "Convite e ativação",
  delivery: "Entrega do email",
  state: {
    Pending: "Por aceitar",
    Accepted: "Aceite · conta ativada",
    Cancelled: "Cancelado",
  } as Record<string, string>,
  deliveries: {
    Pending: "Em fila · tentativa pendente",
    Sending: "A enviar",
    Sent: "Enviado ao serviço de email",
    Failed: "Entrega falhada",
    Stopped: "Entrega terminada",
    Unknown: "Sem registo de entrega",
  } as Record<string, string>,
  deliveryHelp:
    "Email enviado não significa convite aceite. A ativação só termina quando a pessoa usa um código válido e define a sua palavra-passe.",
  failureHelp:
    "A entrega encontrou uma falha. O serviço tenta novamente enquanto houver tentativas disponíveis. Atualize o estado; após o limite, corrija o serviço de email com o operador e reenvie o convite.",
  codeExpired:
    "Código expirado. O convite continua pendente; reenvie para emitir um novo código.",
  codeValid: "Código válido até",
  resendAt: "Próximo reenvio disponível",
  attempts: "Tentativas de entrega",
  resend: "Reenviar convite",
  cancel: "Cancelar convite",
  resendImpact:
    "Será emitido um novo código. O anterior deixa de funcionar. O reenvio respeita os limites do servidor.",
  cancelImpact:
    "O convite será cancelado definitivamente e o acesso desativado. Nenhum código anterior poderá ativar esta conta. Esta operação não se destina a contas já ativadas.",
  confirm: "Confirmar operação",
  back: "Voltar sem enviar",
  confirmTitle: "Rever alteração",
  sendInvite: "Rever convite",
  inviteImpact:
    "Será criada uma conta privada com estes papéis e enviado um convite de ativação. A pessoa define a sua palavra-passe ao aceitar. Não é um convite para instalar o APK.",
  busy: "A confirmar operação…",
  success:
    "Operação confirmada pela API. Consulte o estado atual do membro; a entrega e a aceitação são processos separados.",
  uncertain:
    "A resposta não chegou. A operação pode ter sido aplicada. Recupere a mesma operação antes de fazer outra alteração; não crie um segundo convite.",
  recover: "Recuperar a mesma operação",
  stale:
    "Os dados foram alterados entretanto. A operação não foi aplicada. Atualize os membros e reveja novamente a alteração.",
  storage:
    "Não foi possível guardar a operação para recuperação neste navegador. Nada foi enviado. Permita o armazenamento da sessão e tente novamente.",
  error:
    "A operação foi recusada. Atualize os membros e reveja os dados antes de tentar novamente.",
  errors: {
    forbidden: "Não tem autorização para esta operação.",
    self_administration_denied:
      "Não pode alterar os próprios papéis ou acesso.",
    last_active_administrator:
      "A organização deve manter pelo menos um administrador ativo.",
    invitation_cancelled:
      "Este convite está cancelado e não pode ser reativado.",
    invitation_unavailable:
      "Este convite já não permite a operação. Consulte o estado atual.",
    invalid_relationship:
      "Escolha um gestor distinto e ativo para um colaborador ativo.",
    resend_limited:
      "O limite de reenvio foi atingido. Consulte o próximo instante disponível.",
    invitation_limit: "Foi atingido o limite de convites. Tente mais tarde.",
    account_exists:
      "Este email não está disponível para um novo convite. Consulte os membros existentes.",
    invalid_member: "Verifique o nome, email e papéis do convite.",
  } as Record<string, string>,
  suspended: "Suspenso",
  enabled: "Ativo",
  noRoles: "Sem papéis atribuídos",
  you: "A sua conta",
  unknown: "Estado não reconhecido",
  selected: "Membro selecionado",
  timestampNone: "Não disponível",
};
