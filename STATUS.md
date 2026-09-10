# Estado do projeto

Atualizado: 2026-09-10.

HO-000 a HO-007, HO-010 e **HO-011 integrados**; [histórico anterior](docs/history/HO-012-status-before-reconciliation.md).

HO-011: [PR #36](https://github.com/Dennyum204/HomeOfficeReservation/pull/36) integrado em `main` em 2026-09-10T19:05:49Z, commit `39c766043227e23b561ca4e0aa753b4fe0ce0fb2` confirmado no histórico remoto obtido por fetch. [Documentação](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34518345259) e [integração core](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34518345123) verdes: project-docs, backend-contracts, web e flutter-android. [Aceitação histórica HO-011](docs/HO-011-CORE-ACCEPTANCE.md).

**HO-012 em `review` no [PR draft #37](https://github.com/Dennyum204/HomeOfficeReservation/pull/37)**, branch `ops/ho-012-pilot-preparation`, [issue #13 aberta](https://github.com/Dennyum204/HomeOfficeReservation/issues/13). [Proposta/custos/evidência](docs/HO-012-PILOT.md), [procedimentos](infra/pilot/README.md), [ADR-013](docs/adr/ADR-013-pilot-hosting.md). Preparação de imagem API/Web, HTTPS, SMTP isolado, migração, worker, reinício, backup/restauro cifrado e assinatura Android com chave descartável já ensaiada. Base técnica `b07b756576b5ad982eb4bf2b8e1d121c4355e57a`: [documentação](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34528244453) e [três checks core](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34528244465) verdes. Evidência histórica dessa base, não CI do novo commit documental nem prova de deployment/aceitação externa.

Decisões do responsável em 2026-09-10: **ferbatech.com** existente na Cloudflare, produção `homeoffice.ferbatech.com` e staging `staging.homeoffice.ferbatech.com`; sem compra/transferência/reserva para domínio, restantes DNS/email preservados. Proposta: duas CX23 em Nuremberga, dois IPv4, backups e Storage Box na Finlândia, **€17,38/mês antes de impostos**, com manutenção própria. Ainda por aprovar fornecedor/região/retenção e todas as ações externas; esta revisão autoriza apenas documentação/tracking.

Acesso privado escolhido: titular administrador e colaborador na mesma conta; chefe associado distinto; restantes pessoas por convite; autoaprovação e dados anónimos proibidos. [Inspeção do código](docs/HO-012-PRIVATE-ACCESS.md) confirma ativação Identity e criação administrativa existentes, mas bootstrap só administrador e nenhuma UI de gestão de membros. Novas tarefas **planeadas, não iniciadas**:

- [HO-013 — #38](https://github.com/Dennyum204/HomeOfficeReservation/issues/38): preparar/corrigir titular administrador e colaborador com segurança.
- [HO-014 — #39](https://github.com/Dennyum204/HomeOfficeReservation/issues/39): estado, entrega recuperável e revogação dos convites da aplicação.
- [HO-015 — #40](https://github.com/Dennyum204/HomeOfficeReservation/issues/40): administração Web de membros, convites e associação ao chefe.
- [HO-016 — #41](https://github.com/Dennyum204/HomeOfficeReservation/issues/41): tema Claude + e hierarquia Web/Android, em [marco visual próprio](https://github.com/Dennyum204/HomeOfficeReservation/milestone/8), sem gate do piloto.

HO-013/014 são gates antes dos convites reais; HO-015 antes da gestão autónoma de convidados/aceitação final. Não impedem decidir o alojamento agora e não dependem de deployment HO-012. Faltam também SMTP real, cópia/restauro no fornecedor, alertas externos, chave piloto, distribuição privada autorizada, instalação/push físicos e aceitação. Convites Firebase só entregam APK, não contas/permissões. Critérios anteriores preservados no histórico do backlog; HO-012 complementado com os novos gates. Sem contratação, DNS, deployment, convite, distribuição, release/tag, merge ou auto-merge. iOS e Outlook adiados.

Ambiente local preservado: dados, contas, Firebase privado e emulador. Docker Desktop instalado, mas falta WSL/motor Linux; validação de contentores no runner Linux não é staging publicado. Esta revisão só executa checks documentais/diff, sem repetir testes pesados ou alterar workflows; resultados do commit documental no PR, mantendo draft. Próxima decisão: aprovar/rever a proposta de alojamento e responsabilidades; depois selecionar explicitamente HO-013 para desbloquear o titular, sem iniciar outro item nesta revisão.
