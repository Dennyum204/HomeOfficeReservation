# HO-012 — Inventário NAS por SSH

Observado diretamente em **2026-09-11, aproximadamente 19:44–19:51 Europe/Zurich**, com autorização do responsável. Leituras de metadados por SSH/sudo; sessão terminada. Substitui a indisponibilidade SSH e as versões desconhecidas registadas na preparação inicial. O responsável já tinha atualizado DSM; esta inspeção não executou atualizações.

**HomeOffice continua sem instalação ou medição no NAS. A stack preparada não pode ser executada sem rever as condições abaixo.** [PR #37 draft](https://github.com/Dennyum204/HomeOfficeReservation/pull/37), [issue #13 aberta](https://github.com/Dennyum204/HomeOfficeReservation/issues/13), [plano e comandos](../infra/nas/README.md).

## Resultados observados

| Área | Leitura | Consequência para o ensaio |
|---|---|---|
| Host | DS218+, Celeron J3355, x86_64; DSM 7.1.1-42962 Update 9; kernel 4.4.180+ | Arquitetura amd64 confirmada; compatibilidade dos runtimes ainda não ensaiada |
| Docker | Engine/Client 20.10.3, API 1.41; pacote 20.10.3-1308; driver btrfs | Abaixo do piso 20.10.10 do preflight; não executámos imagens HomeOffice para inferir uma falha de runtime |
| Compose | docker-compose 1.28.5; sem docker compose | Ficheiro 2.4 preparado para avaliação do legado; não executado neste host |
| Limites | MemoryLimit e SwapLimit true; CPUCfsQuota e CPUCfsPeriod false; CPUSet e CPUShares true | As quotas rígidas cpus/NanoCPUs da stack atual não são suportadas; atualizar apenas Engine não demonstra suporte do kernel |
| Segurança do Engine | SecurityOptions enumera apparmor, sem seccomp; configuração do kernel comprimida não disponível | Compatibilidade seccomp/clone3 não demonstrada; não desativar proteções para passar |
| RAM | MemTotal 1 871 620 KiB; MemAvailable aproximadamente 1048 MiB nas três amostras finais | Abaixo da margem inicial proposta de 1100 MiB; não é uma medição de carga da aplicação |
| Armazenamento | /volume1 Btrfs, 3,5 T totais, cerca de 396 G usados e 3,1 T livres | Espaço observado suficiente para a reserva inicial de 8 GiB; não prova saúde de todas as partições |
| Serviços existentes | 17 pacotes reportam running com synopkg status sob sudo, incluindo Drive, VPN, WebDAV e SMB | Não foram parados; estado do pacote não é teste funcional desses serviços |
| Docker existente | Dois contentores parados, nenhum em execução; sem volumes Docker; três imagens existentes, incluindo uma imagem n8n | Todos preservados; nenhum recurso do ensaio criado |
| Rede | Apenas bridge/host/none; a rede proposta 10.78.16.0/24 não colidiu com as rotas LAN/VPN/Docker observadas | Fotografia do inventário; confirmar novamente antes de instalar |
| SSH | Login/sudo funcionaram; sshd -T, também com o contexto do utilizador, devolveu AllowTcpForwarding no | O acesso Web/Mailpit previsto por SSH -L está bloqueado pela configuração atual; nada foi alterado |

Os ficheiros cpu.cfs_quota_us e cpu.cfs_period_us também estavam ausentes no cgroup CPU; cpu.shares e cpuset estavam presentes. CPU shares são prioridade relativa sob contenção e cpuset seleciona núcleos: nenhum é substituto automático das quotas por contentor. O [Docker documenta a dependência do kernel e a diferença entre estes limites](https://docs.docker.com/engine/containers/resource_constraints/). O significado de AllowTcpForwarding está no [manual oficial OpenSSH](https://man.openbsd.org/sshd_config#AllowTcpForwarding). Fontes consultadas em 2026-09-11.

## Partições: dados e sistema têm estados diferentes

Leituras repetidas de /proc/mdstat, sysfs e mdadm --detail:

- **md2, dados:** RAID1 clean, dois membros ativos, `[UU]`, degraded=0.
- **md0, sistema DSM:** RAID1 clean,degraded, um membro ativo de dois, `[U_]`, degraded=1.
- **md1, swap:** RAID1 clean,degraded, um membro ativo de dois, `[U_]`, degraded=1.

As primeiras partições dos dois discos têm tamanhos diferentes: aproximadamente 8 GiB e 2,375 GiB. mdadm --examine não detetou superbloco MD na primeira partição do segundo disco; a segunda conserva metadados antigos, de 2022. Não foi iniciada reconstrução, reparação ou alteração de partições.

SMART global dos dois discos: **PASSED**; contadores consultados de setores realocados, pendentes, incorrigíveis offline e erros CRC a zero. Foi lido o estado existente, sem iniciar um novo autoteste. Isto não corrige nem invalida a degradação dos arrays de sistema/swap. Não há evidência para declarar perda de dados, avaria física ou atribuir a causa à atualização DSM.

A [orientação oficial Synology para partição de sistema degradada](https://kb.synology.com/en-nz/DSM/tutorial/What_to_do_when_system_partition_failed), consultada em 2026-09-11, distingue este estado da perda total das partições de sistema. O próximo diagnóstico deve confrontar o estado no Gestor de armazenamento com estas leituras e o procedimento suportado pelo fabricante. Não executar reparação automática, mdadm --add ou reparticionamento a partir deste inventário.

## Baseline curto, não teste de capacidade

Três amostras em dez segundos: MemAvailable 1 074 080 / 1 073 756 / 1 073 640 KiB; pswpin=98, pswpout=1874 e pgmajfault=2057 mantiveram-se constantes. Cerca de 6,8 MiB de swap zram ocupados; swap em disco sem uso nessa leitura. Carga instantânea baixa. vmstat não está instalado; os contadores vieram de /proc, também usado por trial.sh metrics.

Não houve atividade adicional de swap nesse intervalo. Não prova ausência histórica de OOM, estabilidade durante utilização normal, consumo HomeOffice, latência com duas contas ou capacidade para produção. Os dois contentores antigos estavam parados com OOMKilled=false; não são testes da aplicação.

## Compatibilidade e próximos requisitos

1. Esclarecer as partições de sistema/swap degradadas pelo percurso suportado Synology antes de propor reparações ou novas alterações DSM. O volume de dados saudável não significa que os arrays de sistema estejam completos.
2. Rever o runtime e o suporte de quotas do kernel. O preflight atual recusa Engine 20.10.3 e ausência de CFS; nenhum limite foi retirado. Uma proposta alternativa teria de explicar e validar a proteção dos serviços existentes.
3. Resolver, com autorização específica, a forma de acesso privado: login SSH não concede encaminhamento. Não publicar portas ou rotas Cloudflare como contorno.
4. Reavaliar a margem de RAM durante utilização normal, antes do ensaio com carga. Não parar serviços existentes nem instalar agentes de monitorização para obter artificialmente a margem.

Uma eventual migração DSM exige também compatibilidade dos pacotes existentes: os metadados instalados de SynologyApplicationService 1.7.6-10620 e WebDAVServer 2.4.8-10135 declaram os_max_ver=7.1-59999. Não assumir que essas versões são mantidas num DSM posterior. Nenhum pacote foi atualizado ou substituído nesta inspeção.

O responsável informou que não tem cópia fora do NAS e decidiu a atualização DSM anterior. Isso não bloqueou as leituras nem a preparação no repositório; este documento não acrescenta uma condição de backup ao instalador DSM. A recuperação local/externa do futuro piloto continua separada, conforme a proposta HO-012.

## Evidência, privacidade e limites

Comandos usados: versões Docker/Compose/DSM; docker info e inventários filtrados de contentores/imagens/volumes/redes; meminfo/vmstat/loadavg, df, rotas e cgroups; mdstat/mdadm/sysfs, smartctl -H -A; metadados e estado dos pacotes; sshd -T. Não foram lidos calendários, ficheiros de utilizador, variáveis de ambiente dos contentores ou credenciais de túneis. Os resultados aqui são um recibo sanitizado, não a transcrição integral: passwords, seriais, MACs e identificadores privados não pertencem ao tracking público.

Nenhuma imagem carregada/construída no NAS, contentor iniciado/removido, volume/diretório do ensaio criado, serviço parado ou configuração DSM/SSH/Docker/router/DNS/Cloudflare alterada. Sem email real, APK, contratação ou deployment. Preparação/CI Linux e imagens por commit continuam úteis, mas não satisfazem instalação, funcionalidade, desempenho ou restauro **neste NAS**. HO-012 permanece incompleta.
