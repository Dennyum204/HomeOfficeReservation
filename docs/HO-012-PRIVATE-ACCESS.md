# HO-012 — Acesso privado atual e gates do piloto

Atualizado em 2026-09-11 após merges humanos #42–#45. [Merge/CI](HO-012-INTEGRATION.md). A [inspeção de 2026-09-10](history/HO-012-PRIVATE-ACCESS-20260910.md) preserva as lacunas originais, não o estado atual.

| Capacidade | Implementação atual |
|---|---|
| Titular administrador e colaborador | [HO-013](HO-013-OWNER-BOOTSTRAP.md): bootstrap-owner explícito e extensão idempotente pelo operador; sem atribuição implícita de papéis |
| Convite e entrega | [HO-014](HO-014-INVITATIONS.md): Identity, entrega durável cifrada, reenvio/cancelamento, validade do código distinta da permanência do convite, limites/auditoria/idempotência |
| Administração Web | [HO-015](HO-015-WEB-ADMINISTRATION.md): membros, convites, recuperação, papéis/estado e chefias com versões e confirmação |
| Identidade visual | [HO-016](HO-016-VISUAL-THEME.md): Web/Android claro/escuro/sistema e Conta e sessão nas Definições Android |

Só administradores ativos convidam na sua organização. O titular submete como colaborador; uma chefia distinta e associada decide. Administração não permite autoaprovação, acesso entre organizações ou alteração geral dos próprios papéis. O último administrador ativo permanece protegido. Sem registo público: dados exigem sessão/autorização atual; login/ativação/recuperação e metadados genéricos são acessíveis sem sessão.

O ensaio usa owner@nas.example e manager@nas.example, passwords aleatórias apenas no ficheiro privado. Bootstrap não define password nem finge aceitação: cria intenção durável para Mailpit. Ativação no ecrã existente, com código Identity e password. Não criar códigos por SQL ou importar contas/bases do PC.

Antes de pessoas reais: configurar titular/chefia no ambiente aprovado, verificar isolamento, autorizações e convites aí, aprovar destinatários/envio e ensaiar SMTP real, HTTPS e recuperação fora do NAS. Mailpit não prova entrega externa. Administração Android nativa fora do âmbito; Android já aceita convites e usa os workflows.

**Convite da aplicação** admite Identity/Member e permissões depois de ativar. **Convite Firebase App Distribution** permite obter APK, sem criar conta/membro/chefia ou conceder acesso aos dados. Assinatura e distribuição exigem a sua etapa; nenhum APK é instalado/distribuído neste ensaio.
