# HO-012 — Inventário Raspberry Pi e bloqueio de memória

2026-09-11. [PR #37 draft](https://github.com/Dennyum204/HomeOfficeReservation/pull/37). Apenas leituras; nenhuma instalação, transferência de imagens, alteração de boot, reinício ou operação no NAS.

## Fontes e resultados

SSH com a chave dedicada confirmou `dennyum`, Linux ARM64, permissões `.ssh=700`/`authorized_keys=600`, proprietário correto e ausência de `/home/dennyum/ho012-pi-trial`. A autenticação funciona sem expor a chave privada. `sudo -n` recusou: a password continua exclusivamente no terminal do responsável.

O responsável executou o mesmo `infra/pi/inventory.sh` via SSH com sudo interativo e forneceu o resultado. Distinguir essas leituras protegidas das leituras diretas do assistente:

| Dado | Resultado / origem |
|---|---|
| Modelo / OS | Pi 5 Model B Rev 1.1, Debian 13.4 Trixie, kernel 6.12.75+rpt-rpi-2712; SSH direto |
| CPU / RAM | 4 CPUs, 4 146 896 KiB total; 3 780 864 KiB disponíveis na leitura direta e 3 740 368 KiB na leitura sudo (~3,57 GiB) |
| Swap / pressão | zram ~2 GiB, uso zero; pswpin/pswpout/oom_kill zero em ambas as amostras; não é medição sob carga |
| Armazenamento | microSD ~59,5 GiB; raiz ext4; 53 259 395 072 bytes livres (~49,6 GiB), SSH direto |
| Temperatura | 50,15–50,7 °C; throttled=0x0; snapshots em repouso |
| Docker | Engine 29.8.0, API 1.56, linux/arm64, overlayfs, Compose 5.5.1; resultado sudo do responsável |
| Limites Docker | **Memory=false, Swap=false, CFS=true**; leitura sudo válida, não confundir com valores vazios de consulta sem acesso |
| Workloads | Nenhum contentor ou volume listado na leitura sudo; redes bridge/host/none, bridge 172.17.0.0/16 |
| Rede | LAN por wlan0; nenhuma rota observada colide com 10.78.17.0/24; serviço preexistente em 8787 e SSH 22 preservados |
| Forwarding | sshd global: allowtcpforwarding yes, disableforwarding no, permitopen any (sudo). SSH direct-tcpip para o serviço SSH loopback existente devolveu banner (teste direto, sem novo listener). Destinos da futura bridge ainda não existem; testar após instalação |

Não se recolheram conteúdo de contas, configuração de serviços, tokens ou logs integrais. Inventário sem sudo agora assinala Docker como não verificado, em vez de imprimir falsos valores de limites a partir de uma resposta falhada.

## Bloqueio real antes da instalação

Leitura direta: cgroup2fs, controladores `cpuset cpu io pids`, sem `memory`; `/proc/cmdline` contém `cgroup_disable=memory`. O ficheiro `/boot/firmware/cmdline.txt` não contém uma opção cgroup e `config.txt` não seleciona outro cmdline/include. O preflight existente exige memória/swap/CFS e recusará este host. **Não reduzir ou eliminar limites para contornar a recusa.**

O mantenedor Raspberry Pi explica que o DTB desativa memória por defeito e que `cgroup_enable=memory` no cmdline posterior permite ativá-la; `/proc/cgroups` pode omitir memória no kernel 6.12 por ser a interface V1. Validar V2 e Docker, não exigir uma linha V1. [Explicação do fornecedor](https://github.com/raspberrypi/linux/issues/6980), [métricas/cgroups Docker](https://docs.docker.com/engine/containers/runmetrics/) (consultados em 2026-09-11).

**Proposta para revisão, não executada:** guardar cópia do cmdline atual, acrescentar apenas `cgroup_enable=memory` à sua única linha, mantendo todas as opções existentes, e reiniciar numa janela autorizada. Não editar DTB, instalar kernel, desligar zram ou acrescentar a opção antiga `cgroup_memory=1`. A alteração de boot/reinício é um passo separado da instalação HomeOffice e necessita da decisão do responsável.

Após esse passo: `cat /sys/fs/cgroup/cgroup.controllers` deve incluir memory; `sudo docker info --format '{{.MemoryLimit}} {{.SwapLimit}} {{.CPUCfsQuota}}'` deve devolver `true true true`. Repetir inventário/margem e confirmar serviços anteriores. Se falhar, não instalar nem declarar limites verificados.

## Instalação proposta depois de resolver o bloqueio

[Runbook com comandos](../infra/pi/README.md): quatro contentores, 1472 MiB de limites (~1,44 GiB) e 3 CPU; margem inicial ~2,13 GiB sobre MemAvailable observado, sem previsão de consumo real. Diretório novo, dois volumes e key ring cifrado próprios; nenhum serviço ou dado existente reutilizado. Zero portas no Pi, browser via SSH loopback do PC. Sem app no Pi até aprovação separada. Imagens nativas e ensaio no runner não medem desempenho, persistência ou recuperação na microSD.
