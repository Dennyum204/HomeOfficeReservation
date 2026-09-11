# Estado do projeto

Atualizado: 2026-09-11.

HO-000 a HO-007, HO-010/011 e **HO-013/014/015/016 integrados**. Merges humanos #42–#45, ancestralidade em origin/main e quatro checks de integração verdes: [SHA e runs efetivos](docs/HO-012-INTEGRATION.md). Tracking reconciliado na branch operacional; testes manuais aceites pelo responsável. [Histórico anterior](docs/history/HO-012-resume-before-reconciliation.md).

**HO-012 review/incompleta**, [PR #37 draft](https://github.com/Dennyum204/HomeOfficeReservation/pull/37), [issue #13 aberta](https://github.com/Dennyum204/HomeOfficeReservation/issues/13), branch ops/ho-012-pilot-preparation atualizada com main. [Proposta atual NAS](docs/HO-012-PILOT.md), [stack/comandos](infra/nas/README.md), [ADR-018](docs/adr/ADR-018-nas-trial.md). Preparação útil de produção, SMTP seguro, Data Protection, backup e assinatura preservada; não equivale a aprovação operacional.

DS218+, Celeron J3355 x86_64, 2 GB, DSM observado 7.1-42661 Update 1, Docker instalado; somente conectividade Cloudflare Tunnel anterior reportada. HomeOffice não instalado/medido no NAS. SSH nesta sessão terminou em timeout; Docker local sem motor Linux. Imagens/ensaios no runner Linux são evidência separada. Stack: quatro contentores, 896 MiB de limites, rede interna sem portas publicadas, contas sintéticas, email capturado, volumes/chaves privados, backup/restauro novo. Scripts e documentação preparados; resultados do commit final nos checks e recibos do PR, sem afirmar execução NAS.

Hetzner passa a alternativa histórica não aprovada. Domínio ferbatech.com existente, nomes futuros homeoffice.ferbatech.com e staging.homeoffice.ferbatech.com; sem compra/transferência, DNS/email preservados. Nada contratado. Próximo passo: inventário NAS de leitura e revisão da compatibilidade/margem antes de autorizar instalação. Faltam ensaio/medição NAS, decisão de alojamento, recuperação fora do NAS, HTTPS externo, SMTP real, alertas, assinatura/distribuição e aceitação piloto. Um Staging sintético não valida isolamento produção/staging.

Dados, contas, configuração privada e emuladores habituais preservados. Sem deployment NAS, alteração DSM/router/DNS, rota Cloudflare, email real, distribuição APK, merge/auto-merge/release. iOS e Outlook continuam adiados; não se inicia outro work item.
