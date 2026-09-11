#!/bin/sh
# Run ONLY in the new prepared trial directory, after the operator approves installation.
set -eu
umask 077
cd "$(dirname "$0")"
ROOT=$(pwd -P)
PROJECT=homeoffice-nas-trial
test "$(cat .ho012-nas-trial)" = "$PROJECT" || exit 1
test -f private/application.json && test -f .env
TRIAL_ID=$(sed -n 's/^HO_TRIAL_ID=//p' .env)
test -n "$TRIAL_ID"
dc() {
    if docker compose version >/dev/null 2>&1; then
        docker compose -p "$PROJECT" -f "$ROOT/compose.yaml" "$@"
    else
        docker-compose -p "$PROJECT" -f "$ROOT/compose.yaml" "$@"
    fi
}
sql() { dc exec -T database psql -X -qAt -v ON_ERROR_STOP=1 -U postgres -d "${2:-homeoffice}" -c "$1"; }
wait_db() {
    n=0
    until dc exec -T database pg_isready -U postgres -d homeoffice >/dev/null 2>&1; do
        n=$((n+1)); test "$n" -lt 90 || { echo 'Database unavailable'; exit 1; }; sleep 2
    done
}
wait_app() {
    n=0
    until dc exec -T app bash /app/healthcheck.sh >/dev/null 2>&1; do
        n=$((n+1)); test "$n" -lt 90 || { echo 'Application readiness failed; retain private logs'; exit 1; }; sleep 2
    done
}
# Refuse to target a Compose project created from another directory.
for id in $(docker ps -aq --filter "label=com.docker.compose.project=$PROJECT"); do
    existing=$(docker inspect "$id" --format '{{index .Config.Labels "com.docker.compose.project.working_dir"}}')
    test "$existing" = "$ROOT" || { echo 'Project collision: stop and inspect, no changes made.'; exit 1; }
done
# A fresh private folder must not silently reuse volumes retained by a different trial.
for volume in "${PROJECT}_database" "${PROJECT}_mail"; do
    if docker volume inspect "$volume" >/dev/null 2>&1; then
        owner=$(docker volume inspect "$volume" --format '{{index .Labels "org.homeoffice.trial"}}')
        test "$owner" = "$TRIAL_ID" || { echo 'Volume collision: no changes made.'; exit 1; }
    fi
done
if docker network inspect "${PROJECT}_trial" >/dev/null 2>&1; then
    owner=$(docker network inspect "${PROJECT}_trial" --format '{{index .Labels "org.homeoffice.trial"}}')
    test "$owner" = "$TRIAL_ID" || { echo 'Network collision: no changes made.'; exit 1; }
fi
case "${1:-help}" in
  validate)
    dc config --quiet
    ;;
  start)
    # Version floor for newer glibc clone3/seccomp; not proof of vendor support or compatibility.
    docker version --format '{{.Server.Version}}' | awk -F. '{if ($1<20 || ($1==20 && ($2<10 || ($2==10 && $3<10)))) exit 1}' || {
        echo 'Engine below 20.10.10: stop for compatibility review; do not bypass seccomp or update DSM here.'; exit 1;
    }
    # Images must already be imported. This script never pulls/builds on the NAS.
    dc config --images | while read -r image; do docker image inspect "$image" >/dev/null; done
    test "$(id -u)" = 0 || { echo 'Use the authorized operator sudo session for trial file ownership.'; exit 1; }
    chmod 700 private
    chown 1654:1654 private/application.json private/protection.pfx private/bootstrap.json private/ca.pem
    chmod 600 private/application.json private/protection.pfx private/bootstrap.json private/ca.pem
    chown -R 1654:1654 private/keys
    chmod 700 private/keys
    chown 999:999 private/postgres-password private/database-password
    chmod 600 private/postgres-password private/database-password
    dc up -d database mailpit
    wait_db
    # The normal API and its worker are stopped during migration; never run a second API worker.
    dc stop app
    dc run --rm --no-deps app --migrate
    dc up -d app edge
    wait_app
    echo 'Trial ready. No public/host ports; use the documented SSH forwards.'
    ;;
  bootstrap)
    wait_app
    dc run --rm --no-deps app --bootstrap-owner /run/config/bootstrap.json
    echo 'Owner invitation queued; activation remains a separate action in the Web UI.'
    ;;
  health)
    wait_db; wait_app
    dc ps
    ;;
  database-outage-check)
    dc stop database
    trap 'dc start database >/dev/null' EXIT HUP INT TERM
    dc exec -T app bash -c 'set -eu; exec 3<>/dev/tcp/127.0.0.1/8080; printf "GET /health/live HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n" >&3; IFS= read -r status <&3; [[ "$status" == *" 200 "* ]]'
    if dc exec -T app bash /app/healthcheck.sh >/dev/null 2>&1; then
        echo 'Incorrect readiness while database is stopped'; exit 1
    fi
    dc start database >/dev/null
    trap - EXIT HUP INT TERM
    wait_db; wait_app
    echo 'Liveness stayed available; readiness failed without DB and recovered afterwards.'
    ;;
  metrics)
    date -u
    awk '/MemTotal|MemAvailable|SwapTotal|SwapFree/ {print}' /proc/meminfo
    awk '/pswpin|pswpout|oom_kill/ {print}' /proc/vmstat
    for id in $(dc ps -q); do
        docker stats --no-stream --format '{{.Name}} CPU={{.CPUPerc}} RAM={{.MemUsage}} PIDs={{.PIDs}}' "$id"
        docker inspect "$id" --format 'OOM={{.State.OOMKilled}} exit={{.State.ExitCode}} restart={{.RestartCount}} memory={{.HostConfig.Memory}} swap={{.HostConfig.MemorySwap}} cpuPeriod={{.HostConfig.CpuPeriod}} cpuQuota={{.HostConfig.CpuQuota}}'
    done
    ;;
  restart)
    dc stop app edge mailpit database
    dc start database mailpit
    wait_db
    dc start app edge
    wait_app
    ;;
  backup)
    target="$ROOT/private/backups/$(date -u +%Y%m%dT%H%M%SZ)-$$"
    mkdir -p "$ROOT/private/backups"
    mkdir "$target"
    dc stop app
    trap 'dc start app >/dev/null' EXIT HUP INT TERM
    dc exec -T database pg_dump -U postgres -d homeoffice -Fc --no-owner > "$target/database.dump"
    cp -p private/application.json private/protection.pfx private/ca.pem "$target/"
    cp -Rp private/keys "$target/keys"
    cp .env "$target/image.env"
    (cd "$target"; find . -type f ! -name SHA256SUMS -exec sha256sum '{}' \; > SHA256SUMS)
    dc start app >/dev/null
    trap - EXIT HUP INT TERM
    wait_app
    echo "Private local backup: $target (not protection against NAS loss)."
    ;;
  restore-new)
    test "$#" = 3 || { echo 'restore-new <absolute private backup folder> <ho012_restore_suffix>'; exit 1; }
    source=$(cd "$2" && pwd -P)
    case "$source" in "$ROOT"/private/backups/*) ;; *) echo 'Use a backup belonging to this trial.'; exit 1;; esac
    target=$3
    case "$target" in ho012_restore_?*) ;; *) echo 'New database name must start ho012_restore_'; exit 1;; esac
    case "$target" in *[!a-z0-9_]*) exit 1;; esac
    test "${#target}" -le 50
    (cd "$source"; sha256sum -c SHA256SUMS >/dev/null)
    # CREATE must fail on an existing name. No DROP, --clean or switching the source application.
    sql "CREATE DATABASE \"$target\" OWNER homeoffice;" postgres
    sql "REVOKE ALL ON DATABASE \"$target\" FROM PUBLIC;" postgres
    dc exec -T database pg_restore -U postgres --role=homeoffice -d "$target" --no-owner --no-privileges --exit-on-error < "$source/database.dump"
    echo "Restored separate database $target. Source and running app unchanged; authenticated recovery must still be verified."
    ;;
  stop)
    dc stop
    ;;
  remove-containers)
    # Own project only. Retain volumes, private keys, backups and image archives by default.
    dc down
    echo 'Only trial containers/network removed; database/mail volumes and private files retained.'
    ;;
  *) echo 'validate | start | bootstrap | health | database-outage-check | metrics | restart | backup | restore-new | stop | remove-containers'; exit 2;;
esac
