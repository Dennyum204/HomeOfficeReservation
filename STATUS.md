# Estado do projeto

Atualizado: 2026-09-11.

HO-000 a HO-007, HO-010/011 e **HO-013/014/015/016 integrados**. Merges humanos #42–#45, ancestralidade em origin/main e quatro checks de integração verdes: [SHA e runs efetivos](docs/HO-012-INTEGRATION.md). Tracking reconciliado na branch operacional; testes manuais aceites pelo responsável. [Histórico anterior](docs/history/HO-012-resume-before-reconciliation.md).

**HO-012 review/incompleta**, [PR #37 draft](https://github.com/Dennyum204/HomeOfficeReservation/pull/37), [issue #13 aberta](https://github.com/Dennyum204/HomeOfficeReservation/issues/13), branch ops/ho-012-pilot-preparation atualizada com main. [Proposta atual NAS](docs/HO-012-PILOT.md), [stack/comandos](infra/nas/README.md), [ADR-018](docs/adr/ADR-018-nas-trial.md). Preparação útil de produção, SMTP seguro, Data Protection, backup e assinatura preservada; não equivale a aprovação operacional.

Inventário SSH autorizado concluído em 2026-09-11: DS218+ x86_64, DSM 7.1.1-42962 Update 9, Engine 20.10.3, Compose 1.28.5, kernel 4.4.180+. [Recibo sanitizado e fontes](docs/HO-012-NAS-INVENTORY.md). Dados RAID1 saudáveis; arrays de sistema/swap degradados, sem causa atribuída à atualização. SMART global passou nos dois discos. Quotas CPU CFS indisponíveis, encaminhamento SSH desativado e cerca de 1048 MiB disponíveis no baseline curto, abaixo da margem proposta. Os 17 pacotes consultados reportam running; serviços/contentores preservados. Nenhuma reparação ou alteração de configuração realizada.

HomeOffice não instalado/medido no NAS; a stack atual continua bloqueada por compatibilidade/acesso/margem e revisão do armazenamento. Imagens/ensaios no runner Linux são evidência separada. Stack preparada: quatro contentores, 896 MiB de limites propostos, rede interna sem portas publicadas, contas sintéticas, email capturado, volumes/chaves privados, backup/restauro novo. Resultados por commit nos checks e recibos do PR, sem afirmar execução NAS.

Hetzner passa a alternativa histórica não aprovada. Domínio ferbatech.com existente, nomes futuros homeoffice.ferbatech.com e staging.homeoffice.ferbatech.com; sem compra/transferência, DNS/email preservados. Nada contratado. Próximo passo: esclarecer o estado das partições de sistema no Gestor de armazenamento pelo percurso suportado Synology; não reparar automaticamente. Antes da instalação, resolver os restantes pontos do inventário e rever a stack. Faltam ensaio/medição NAS, decisão de alojamento, recuperação fora do NAS, HTTPS externo, SMTP real, alertas, assinatura/distribuição e aceitação piloto. Um Staging sintético não valida isolamento produção/staging.

Dados, contas, configuração privada e emuladores habituais preservados. Sem deployment NAS, alteração DSM/router/DNS, rota Cloudflare, email real, distribuição APK, merge/auto-merge/release. iOS e Outlook continuam adiados; não se inicia outro work item.
