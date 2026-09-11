#!/bin/sh
# READ ONLY. Run in an existing authorized SSH session; no sudo installation or writes.
set -u
printf '\n--- NAS / kernel / CPU ---\n'
uname -smr
cat /etc.defaults/VERSION
awk '/model name/ {print; exit}' /proc/cpuinfo
printf '\n--- Memory / swap / filesystems ---\n'
awk '/MemTotal|MemAvailable|SwapTotal|SwapFree/ {print}' /proc/meminfo
cat /proc/swaps
df -h
printf '\n--- Docker / Compose / limits ---\n'
docker version --format 'Engine={{.Server.Version}} API={{.Server.APIVersion}} arch={{.Server.Arch}}'
docker compose version 2>/dev/null || docker-compose version --short 2>/dev/null || true
docker info --format 'Root={{.DockerRootDir}} Driver={{.Driver}} MemoryLimit={{.MemoryLimit}} SwapLimit={{.SwapLimit}} CpuCfsQuota={{.CpuCfsQuota}} Security={{json .SecurityOptions}}'
printf '\n--- Existing load and network ranges (read only) ---\n'
docker stats --no-stream --format 'CPU={{.CPUPerc}} RAM={{.MemUsage}}'
docker network ls -q | while read -r network; do docker network inspect "$network" --format '{{range .IPAM.Config}}{{.Subnet}}{{end}}'; done
ip route 2>/dev/null || route -n
printf '\n--- Kernel OOM evidence (permission failure is not a clean result) ---\n'
dmesg 2>&1 | tail -n 80
