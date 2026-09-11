# Estado do projeto

Atualizado: 2026-09-11.

HO-000 a HO-007, HO-010/011 e **HO-013/014/015/016 integrados**. Merges humanos #42–#45, ancestralidade e quatro checks de integração: [evidência](docs/HO-012-INTEGRATION.md). [Histórico](docs/history/HO-012-resume-before-reconciliation.md).

**HO-012 review/incompleta**, [PR #37 draft](https://github.com/Dennyum204/HomeOfficeReservation/pull/37), [issue #13 aberta](https://github.com/Dennyum204/HomeOfficeReservation/issues/13), branch ops/ho-012-pilot-preparation. Novo alvo: Raspberry Pi 5/4 GB, Debian 13 aarch64. [Proposta](docs/HO-012-PILOT.md), [recursos/comandos](infra/pi/README.md), [ADR-019](docs/adr/ADR-019-pi-arm64-trial.md).

Responsável reportou alimentação 27 W, caixa/ventoinha, microSD High Endurance 64 GB/50 GB livres, 3,7 GiB disponíveis antes do Docker, swap zero, hello-world arm64v8 e Compose 5.5.1. SSH automático recusou autenticação: Engine, workloads, memória pós-Docker, limites e forwarding ainda por verificar. Nenhum comando ou instalação HomeOffice no Pi; não pedir password em chat.

Perfil isolado preparado: quatro contentores ARM64, 1472 MiB/3 CPU propostos, rede interna sem portas publicadas, TLS local via SSH, SMTP capturado, volumes/configuração/key ring/PFX próprios e restauro para base nova. CI pi-preparation compila e executa nativamente fora do Pi; verifica arquitetura de todas as imagens e exporta runtimes/manifesto/hash. Resultados reais por commit nos checks/recibos do PR; nunca equivalem a adequação ou performance no Pi. Quatro checks core preservados.

NAS permanece inalterado e histórico: [inventário SSH](docs/HO-012-NAS-INVENTORY.md), [proposta anterior](docs/history/HO-012-PILOT-NAS-20260911.md). Capturas posteriores mostram DSM Healthy; discrepância com partições de sistema/swap não resolvida. Não é gate do Pi. Preparação AMD64 preservada, sem reutilizar imagens/dados no ARM64. Hetzner não aprovado. ferbatech.com existente, DNS/email preservados; nada contratado.

Próximo passo: permitir autenticação SSH local para inventário só de leitura. Antes de instalar, rever recursos/caminhos/redes/limites e autorizar a instalação concreta. Faltam ensaio/medição/restauro no Pi, decisão de alojamento, recuperação externa, HTTPS/SMTP reais, alertas, assinatura/distribuição e aceitação piloto. Dados, contas, configuração privada e emuladores habituais preservados. Sem deployment, alteração NAS/router/DNS, Cloudflare, email real, APK, merge/auto-merge/release. iOS e Outlook adiados.
