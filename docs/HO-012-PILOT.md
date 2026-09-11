# HO-012 — Ensaio Raspberry Pi ARM64 e preparação do piloto

Atualizado em 2026-09-11. [PR #37 draft](https://github.com/Dennyum204/HomeOfficeReservation/pull/37), [issue #13 aberta](https://github.com/Dennyum204/HomeOfficeReservation/issues/13). **Pi selecionado para ensaio isolado, não aprovado como produção.** Instalação HomeOffice por autorizar, executar e medir. [Stack/recursos/comandos](../infra/pi/README.md), [ADR-019](adr/ADR-019-pi-arm64-trial.md).

## Evidência e mudança de alvo

O responsável confirmou por comandos Pi 5 de 4 GB, Debian 13 Trixie aarch64, alimentação oficial 27 W, caixa com ventoinha, microSD High Endurance de 64 GB com 50 GB livres, 3,7 GiB de RAM disponíveis antes do Docker e swap zero. Reportou instalação Docker pelo repositório oficial Debian, hello-world arm64v8 bem-sucedido e Compose 5.5.1.

A tentativa SSH automática em dennyum@192.168.1.105 alcançou o servidor, mas recebeu Permission denied (publickey,password). Não executámos comandos no Pi; versão Engine, workloads, limites/cgroups, memória pós-Docker, redes e forwarding continuam por verificar. Não pedir passwords em chat. Preparação no PC/CI prossegue sem esse acesso.

O NAS fica inalterado. [Preparação NAS histórica](history/HO-012-PILOT-NAS-20260911.md), [inventário anterior](HO-012-NAS-INVENTORY.md), [ADR-018](adr/ADR-018-nas-trial.md) e scripts AMD64 preservados. As capturas posteriores mostraram DSM Healthy apesar das leituras md0/md1; discrepância não resolvida nem reparada. Não é dependência de instalar no Pi. Hetzner permanece alternativa histórica não aprovada. Nenhum arquivo AMD64 é transferível para este ensaio ARM64.

## Proposta concreta

Projeto homeoffice-pi-trial, novo diretório /home/dennyum/ho012-pi-trial sujeito ao inventário. API/React/worker no mesmo contentor (768 MiB/1,5 CPU), PostgreSQL (512 MiB/1 CPU), Caddy TLS local (64 MiB/0,25 CPU) e Mailpit SMTP capturado (128 MiB/0,25 CPU). Total 1472 MiB/3 CPU, sem swap adicional por contentor, logs limitados e sem reinício automático. Limites propostos face aos 3,7 GiB reportados; confirmar pelo menos 2 GiB disponíveis estáveis e 8 GiB livres antes de iniciar.

Rede interna própria 10.78.17.0/24, sujeita a verificar colisões. Nenhuma porta publicada no Pi: SSH do PC encaminha loopback 18443 para edge:443 e 18025 para Mailpit:8025. Sem DNS, router, rede host ou Cloudflare. Só contas sintéticas, sem relay SMTP ou push real. Volumes de DB/mail próprios, key ring persistente protegido por PFX separado de TLS e configuração externa ao Git. Não se modifica a app/emulador habitual.

Builds nativos fora do Pi em ubuntu-24.04-arm, sem emulação. pi-preparation verifica ARM64 nas seis bases/dependências fixadas, executa o perfil exato, valida migração/ativação/convites/chefia/aprovação/worker, reinício, backup/restauro autenticado novo e publica apenas imagens runtime/manifesto/hash e evidência sanitizada. Os quatro checks core permanecem. Teste/medição no runner não prova desempenho da microSD ou do Pi.

## Aceitação e operação por validar

Após autorização de instalação: inventário/baseline, saúde com e sem DB, dois utilizadores, convites capturados, plano/decisão/inbox, reinício e recuperação completa para base nova preservando sessões e chaves. Medir RAM/CPU/latência, swap/OOM e temperatura/throttling durante dez minutos de utilização e pelo menos trinta minutos depois. Metas propostas p95 leitura <=1 s e escrita <=2 s após aquecimento; sem OOM, pressão crescente ou degradação de serviços anteriores. Não são resultados nem SLA. Depois será necessário ensaio prolongado antes de considerar produção.

Custos incrementais contratados: €0. Sem compra de domínio; ferbatech.com existente, homeoffice.ferbatech.com e staging.homeoffice.ferbatech.com apenas nomes futuros. Energia, desgaste/substituição de microSD, cópia externa e impostos/serviços futuros ainda não quantificados. Operador mantém atualizações, capacidade/temperatura, filas, backups e restauros. Cópia na mesma microSD não protege contra perda do suporte; proteção cifrada independente e RPO/RTO antes de dados reais. Não há alta disponibilidade.

[Hetzner histórico](history/HO-012-PILOT-20260910.md): estimativa anterior €17,38/mês antes de impostos, sem domínio; não é cotação atual ou proposta aprovada. Não criar VMs ou instalar no NAS em paralelo.

HO-013/014/015/016 integrados com [merge/CI verificados](HO-012-INTEGRATION.md). Faltam inventário/acesso e ensaio real no Pi, decisão final de alojamento, isolamento staging/produção, recuperação externa, HTTPS externo, SMTP real autorizado, alertas, assinatura/distribuição e aceitação física/piloto. [Acesso privado](HO-012-PRIVATE-ACCESS.md) continua a exigir configuração/aceitação no destino. Não encerrar HO-012 por passar CI ARM64.

Sem instalação nesta etapa, alteração de NAS/router/DNS, publicação Cloudflare, email real, APK, contratação, release, merge ou auto-merge. iOS/Outlook adiados.
