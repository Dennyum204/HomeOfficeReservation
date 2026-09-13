#!/bin/sh
# Explicit operator step AFTER destination approval. No timers started and no uploads.
set -eu
umask 077
test "$(id -u)" = 0
test "$(uname -m)" = aarch64
cd "$(dirname "$0")"
echo '2fb45ac6f9071b6f20eb883953a188f9e7c7cb6bbe43c67a2e47ada4e85ee7f0  restic' | sha256sum -c -
for path in /opt/homeoffice-backup /etc/homeoffice-backup /var/lib/homeoffice-backup; do
    test ! -e "$path" || { echo 'Existing backup installation: inspect; no overwrite.'; exit 1; }
done
for unit in homeoffice-backup*.service homeoffice-backup*.timer; do
    test ! -e "/etc/systemd/system/$unit" || { echo 'Existing systemd unit: no overwrite.'; exit 1; }
done
install -d -m 700 /opt/homeoffice-backup /etc/homeoffice-backup /var/lib/homeoffice-backup
install -m 700 restic /opt/homeoffice-backup/restic
install -m 600 backup.py config.example.json /opt/homeoffice-backup/
for unit in homeoffice-backup*.service homeoffice-backup*.timer; do
    install -m 644 "$unit" "/etc/systemd/system/$unit"
done
systemctl daemon-reload
systemd-analyze verify /etc/systemd/system/homeoffice-backup.service /etc/systemd/system/homeoffice-backup.timer
echo 'Installed disabled units. Private configuration/recovery kit/init/live test required before enabling timers.'
