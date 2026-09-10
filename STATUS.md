# Estado do projeto

Atualizado: 2026-09-10.

HO-000 a HO-007, HO-010 e **HO-011 integrados**; [histórico anterior](docs/history/HO-012-status-before-reconciliation.md).

HO-011: [PR #36](https://github.com/Dennyum204/HomeOfficeReservation/pull/36) integrado em `main` em 2026-09-10T19:05:49Z, commit `39c766043227e23b561ca4e0aa753b4fe0ce0fb2` confirmado no histórico remoto obtido por fetch. [Documentação](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34518345259) e [integração core](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34518345123) verdes: project-docs, backend-contracts, web e flutter-android. [Aceitação histórica HO-011](docs/HO-011-CORE-ACCEPTANCE.md).

**HO-012 em `review` no [PR draft #37](https://github.com/Dennyum204/HomeOfficeReservation/pull/37)**, branch `ops/ho-012-pilot-preparation`, [issue #13](https://github.com/Dennyum204/HomeOfficeReservation/issues/13). [Proposta/custos/evidência](docs/HO-012-PILOT.md), [procedimentos](infra/pilot/README.md), [ADR-013](docs/adr/ADR-013-pilot-hosting.md). Imagem API/Web, HTTPS, SMTP isolado, migração, worker, reinício e recuperação cifrada de dados/sessões verificados no [ensaio CI de 15c4bbe](https://github.com/Dennyum204/HomeOfficeReservation/actions/runs/34525583766/job/103033891052). Assinatura Android com chave descartável também compilada/verificada localmente, sem instalação/distribuição. Os quatro checks do último commit ficam registados no PR draft; preparação não satisfaz deployment/aceitação V1.

Pendente: aprovação de fornecedor/região/domínio/retenção, recursos externos, SMTP real, backup/restauro no fornecedor, chave piloto e distribuição privada autorizada, instalação/push físicos e aceitação com duas pessoas. Issue aberta, critérios intactos. Sem compra, deployment, convite, APK público, release/tag, merge ou auto-merge. iOS e Outlook adiados.

Ambiente local preservado: dados, contas, Firebase privado e emulador. Docker Desktop instalado, mas falta WSL/motor Linux; validação de contentores no runner Linux não é staging publicado. Próximo passo é continuar **HO-012 na mesma branch/PR**, após a revisão da preparação e aprovação das ações externas.
