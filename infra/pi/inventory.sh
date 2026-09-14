#!/bin/sh
# Read-only host metadata. Use an existing authorized sudo session. No writes or installation.
set -u
printf '\nPi / OS / kernel\n'
if test -r /proc/device-tree/model; then tr -d '\000' < /proc/device-tree/model; printf '\n'; fi
uname -smr
cat /etc/os-release
printf '\nMemory / swap / storage / pressure\n'
awk '/MemTotal|MemAvailable|SwapTotal|SwapFree/ {print}' /proc/meminfo
cat /proc/swaps
df -h / /var/lib/docker 2>/dev/null
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINTS
cat /proc/loadavg
awk '/pswpin|pswpout|oom_kill/ {print}' /proc/vmstat
for f in /proc/pressure/memory /proc/pressure/cpu /sys/class/thermal/thermal_zone0/temp; do
    if test -r "$f"; then printf '%s\n' "$f"; cat "$f"; fi
done
if command -v vcgencmd >/dev/null; then vcgencmd get_throttled; fi
printf '\nCgroup v2 and selected boot arguments\n'
if test -r /sys/fs/cgroup/cgroup.controllers; then cat /sys/fs/cgroup/cgroup.controllers; fi
if test -r /sys/fs/cgroup/cgroup.subtree_control; then cat /sys/fs/cgroup/cgroup.subtree_control; fi
tr ' ' '\n' < /proc/cmdline | grep -E '^(cgroup|systemd.unified|swapaccount)' || true
printf '\nDocker / limits / existing resources\n'
docker compose version
if docker info >/dev/null 2>&1; then
docker version --format 'Engine={{.Server.Version}} API={{.Server.APIVersion}} OS={{.Server.Os}} arch={{.Server.Arch}}'
docker info --format 'Root={{.DockerRootDir}} Driver={{.Driver}} Memory={{.MemoryLimit}} Swap={{.SwapLimit}} CFS={{.CPUCfsQuota}} Security={{json .SecurityOptions}}'
docker ps -a --format 'Name={{.Names}} Image={{.Image}} Status={{.Status}}'
docker volume ls
docker stats --no-stream --format 'Name={{.Name}} CPU={{.CPUPerc}} RAM={{.MemUsage}}'
docker network ls -q | while read -r network; do docker network inspect "$network" --format '{{.Name}} {{range .IPAM.Config}}{{.Subnet}} {{end}}'; done
else
    printf 'UNVERIFIED: Docker daemon access denied/unavailable; no Engine, workload or limit result.\n'
fi
ip route
printf '\nSSH forwarding configuration (context-specific Match rules may override)\n'
if ssh_config=$(/usr/sbin/sshd -T 2>/dev/null); then
    printf '%s\n' "$ssh_config" | awk '/^allowtcpforwarding |^disableforwarding |^permitopen / {print}'
else
    printf 'UNVERIFIED: sshd effective configuration requires authorized elevated read.\n'
fi
printf '\nAny failed/denied read remains unverified. No credentials, service config or full logs collected.\n'
