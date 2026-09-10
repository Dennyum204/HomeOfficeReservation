# Changelog

## Unreleased

- HO-013: bootstrap explícito de titular administrador/colaborador, extensão idempotente de administrador antigo por IDs e auditoria de acesso aditiva. Escritas administrativas revalidam autoridade sob lock por organização, protegendo o último administrador em concorrência. Contratos/credenciais/calendário preservados; sem convites ou administração Web.
- HO-011 reconciliado com merge humano do PR #36 e quatro checks de integração verdes. HO-012 permanece incompleta no PR draft #37; apenas o registo HO-013 e referências foram importados.

- HO-002: API .NET 10/EF Core/PostgreSQL, shell React PT-PT e Flutter Android/iOS; clientes TypeScript/Dart gerados, health/readiness, Compose e CI real por stack. Funcionalidades de negócio continuam por implementar.
- HO-001 reconciliado após merge humano do PR #27 (`7f783bf9bde5a72ac8271c42cc2916b054170d17`) e CI de integração verde; Graph real continua adiado.
- HO-001 reformulado por decisão do responsável: calendário autoritativo e contas próprias ASP.NET Core Identity; core V1 completo sem Microsoft.
- PR #27 documenta o novo âmbito; ADR-004 substitui ADR-002 preservando pesquisa/probe como referência opcional. Onboarding parado; Graph real adiado, nunca aprovado.
- HO-008 movido para milestone de publicação opcional; HO-009 para importação/delta/webhooks/reconciliação posterior. IDs e histórico preservados, dependências e gates core revistos.
- CI normal documental sem probe; testes sintéticos da referência apenas por execução manual explícita.
- HO-000: fundação integrada pelo PR #25, tracking original de 24 tarefas e proteções main; merge/CI verificados. A exigência original de Outlook V1 foi substituída em HO-001.

HO-001 entregou documentação; HO-002 acrescenta o scaffold executável. Sem migrações de negócio, deployment, versão lançada ou integração Graph validada.
