# HO-012 — Candidato NAS e preparação do piloto

Atualizado em 2026-09-11. [PR #37 draft](https://github.com/Dennyum204/HomeOfficeReservation/pull/37), [issue #13 aberta](https://github.com/Dennyum204/HomeOfficeReservation/issues/13). **O NAS está em avaliação; não foi instalado nem medido.** Hetzner não foi aprovado. [Runbook do ensaio](../infra/nas/README.md), [ADR-018](adr/ADR-018-nas-trial.md).

## Evidência disponível

Dados fornecidos pelo responsável: Synology DS218+, Celeron J3355 x86_64, 2 GB; DSM observado 7.1-42661 Update 1, Docker instalado; IP DHCP observado 192.168.1.102; utilizador SSH OverseekersAdmin. Versões efetivas Engine/Compose, kernel, armazenamento, memória livre e carga ainda por obter. Não guardar passwords no Git.

`docker pull cloudflare/cloudflared:latest` funcionou por SSH e `nas-connectivity-test` apresentou «Tunnel connected successfully». Teste terminado, sem hostname/rotas, serviços publicados ou alterações ao router. **Prova apenas conectividade, não compatibilidade/desempenho HomeOffice.** Não repetir nem publicar rotas nesta etapa.

A tentativa SSH desta sessão, não interativa, com validação do host conhecido e timeout de 5 s, terminou em timeout de banner. Não houve acesso ao NAS. Docker Desktop local tem CLI/Compose, mas não motor Linux disponível. Builds e ensaios de contentores usam o runner Linux, separados das medições futuras no DS218+.

## Stack concreta para revisão

| Recurso novo: projeto homeoffice-nas-trial | Limite inicial | Função |
|---|---|---|
| app: imagem Linux amd64 do commit | 512 MiB / 0,75 CPU | React, API Identity e workers duráveis no mesmo processo |
| database: PostgreSQL 18.6 | 256 MiB / 0,50 CPU | Base/role próprias; pool API 10, máximo 20 ligações, shared_buffers 64 MiB |
| edge: Caddy 2.11.4 | 64 MiB / 0,15 CPU | HTTPS local, sem ACME ou DNS público |
| mailpit: 1.31.1 | 64 MiB / 0,20 CPU | SMTP STARTTLS autenticado, captura até 100 emails, sem relay |
| Rede bridge interna | 10.78.16.0/24, sujeita ao inventário | Sem portas publicadas nem saída; SSH encaminha para edge/mailpit |
| Volumes Docker próprios | homeoffice-nas-trial_database e homeoffice-nas-trial_mail | PostgreSQL e email sintético |
| Diretório privado novo | Volume/caminho por escolher após inventário | Configuração, credenciais sintéticas, PFX/key ring, TLS, backups e medições |

896 MiB é a soma dos limites, não previsão do consumo. Restam nominalmente 1152 MiB dos 2 GiB para DSM/kernel/Docker/serviços existentes e margem; a memória realmente disponível pode ser muito menor. Swap dos contentores limitado a zero e CPU total até 1,6 dos dois núcleos. Não desativar OOM/seccomp. Limites insuficientes devem produzir falha observável, não aumento automático nem reinícios infinitos.

Imagens compiladas/exportadas fora do NAS, com SHA do código, IDs/digests e SHA-256. Transferência SSH; configuração privada gerada separadamente no PC, nunca no artifact. Não se cria VM, túnel, DNS, registry público, infraestrutura de monitorização, FCM ou serviço Microsoft.

## Pré-condições e critérios

Inventário de leitura antes da instalação: Docker/Compose/kernel/arquitetura, cgroups/limites, espaço/memória/swap/carga, rede e serviços existentes. Compose 2.x preferível; ficheiro 2.4 permite avaliar o Compose 1.28.5 legado sem extensões recentes. Script recusa Engine anterior a 20.10.10 devido a seccomp/clone3; mesmo acima disso kernel/libseccomp do fabricante podem bloquear Noble/Bookworm. Não atualizar DSM, substituir Engine nem usar seccomp=unconfined como atalho.

Margens propostas para iniciar: MemAvailable estável de pelo menos 1100 MiB, 8 GiB livres no volume escolhido (reavaliar perante o tamanho real de archive/imagens/DB/duas cópias), limites efetivos e rede sem colisão. São condições do ensaio, não requisitos universais ou garantia de capacidade. Se faltarem, reavaliar antes de instalar.

Medir baseline, 10 min com duas sessões e pelo menos 30 min de observação; depois ensaio prolongado antes de produção. Metas propostas: sem OOM/restarts inesperados, sem degradação dos serviços DSM ou swap crescente; p95 de leituras autenticadas até 1 s após aquecimento e escritas até 2 s. Não são resultados nem SLA. Verificar convites capturados, titular/chefia, pedido/aprovação, worker, saúde com e sem DB, reinício, backup/restauro novo e persistência. [Procedimentos](../infra/nas/README.md).

## Custos e manutenção

Custo incremental contratado nesta preparação: **€0**; sem compra, transferência ou reserva para domínio. Eletricidade incremental, armazenamento/discos, UPS, cópia externa e impostos/serviços futuros ainda desconhecidos. NAS sempre ligado não equivale a energia gratuita ou alta disponibilidade.

O operador vigia disco, RAM/swap/OOM, filas e backups; planeia atualizações compatíveis, testa restauros e mantém chaves/passwords fora do NAS. Não existe HA. Backup no mesmo NAS recupera erros lógicos, mas não perda do equipamento, avaria conjunta, furto ou ransomware. Proteção externa cifrada e RPO/RTO serão decididos antes de dados reais.

Alternativa histórica: duas Hetzner CX23 com IPv4/backups/Storage Box, estimativa então consultada **€17,38/mês antes de impostos**, sem domínio. **Não aprovada; não é cotação atual ou contratação automática.** Inventário/manutenção/fontes no [histórico de 2026-09-10](history/HO-012-PILOT-20260910.md) e ADR-013. Não criar duas VMs em paralelo com o ensaio NAS.

## Gates em aberto

HO-013/014/015/016 têm merges humanos e [evidência de integração](HO-012-INTEGRATION.md). Bootstrap, convites e administração deixaram de ser lacunas de implementação; [configuração/aceitação no ambiente final](HO-012-PRIVATE-ACCESS.md) continuam necessárias.

Faltam inventário/compatibilidade NAS, autorização/execução do ensaio e medições/restauro nesse hardware, decisão de alojamento/residência/retenção, proteção externa, HTTPS externo, SMTP real autorizado, alertas, assinatura/distribuição e aceitação física. Um único Staging sintético não comprova staging/produção isolados no alojamento final.

Domínio existente **ferbatech.com**: homeoffice.ferbatech.com e staging.homeoffice.ferbatech.com. Preservar DNS/email/NS/router/DSM. HTTPS externo e Cloudflare só depois do ensaio local. Sem deployment, email real, APK, release/tag, merge ou auto-merge nesta etapa. HO-012 incompleta/draft.
