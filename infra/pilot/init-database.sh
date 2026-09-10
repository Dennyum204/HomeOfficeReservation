#!/usr/bin/env bash
set -eu
# Only runs on a new volume. Runtime/EF owner has no cluster administration rights.
export HO_DB_PASSWORD="$(cat "$HO_DATABASE_PASSWORD_FILE")"
psql -v ON_ERROR_STOP=1 --username postgres --dbname postgres <<'SQL'
\getenv app_password HO_DB_PASSWORD
CREATE ROLE homeoffice LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE PASSWORD :'app_password';
CREATE DATABASE homeoffice OWNER homeoffice;
REVOKE ALL ON DATABASE homeoffice FROM PUBLIC;
SQL
unset HO_DB_PASSWORD
