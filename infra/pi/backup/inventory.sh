#!/bin/sh
# Read-only, no configuration payloads, tokens or customer data.
set -eu
date -u
docker ps --filter label=com.docker.compose.project=homeoffice-pi-trial --format '{{.Names}} {{.Status}}'
for id in $(docker ps -q --filter label=com.docker.compose.project=homeoffice-pi-trial); do
    docker inspect "$id" --format 'OOM={{.State.OOMKilled}} restart={{.RestartCount}} memory={{.HostConfig.Memory}} swap={{.HostConfig.MemorySwap}}'
done
find /home/dennyum/ho012-pi-trial/private/backups -mindepth 1 -maxdepth 1 -type d -printf '%f\n'
du -sh /home/dennyum/ho012-pi-trial/private/backups
systemctl list-timers --all --no-pager 'homeoffice*'
command -v restic || true
