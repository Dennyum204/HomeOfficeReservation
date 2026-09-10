#!/usr/bin/env bash
# Install/activate on the approved Linux host only. No credentials in arguments or logs.
set -euo pipefail
umask 077
: "${HO_CHECKOUT:?absolute checkout}"
: "${HO_ENV_FILE:?private environment file}"
: "${HO_EXPORT_ROOT:?private export directory}"
: "${RESTIC_REPOSITORY:?approved repository}"
: "${RESTIC_PASSWORD_FILE:?private password file}"
[[ "$HO_EXPORT_ROOT" == /* && "$HO_CHECKOUT" == /* && "$HO_ENV_FILE" == /* ]]
install -d -m 0700 "$HO_EXPORT_ROOT"
exec 9>"$HO_EXPORT_ROOT/backup.lock"
flock -n 9
target="$HO_EXPORT_ROOT/$(date -u +%Y%m%dT%H%M%SZ)"
python3 "$HO_CHECKOUT/infra/pilot/operations.py" --env-file "$HO_ENV_FILE" snapshot "$target"
restic backup "$target" --tag homeoffice --quiet
restic check --quiet
date -u +%FT%TZ > "$HO_EXPORT_ROOT/last-success.tmp"
mv -- "$HO_EXPORT_ROOT/last-success.tmp" "$HO_EXPORT_ROOT/last-success"
# Retention/prune and local export removal remain explicit operator steps after a verified restore.
