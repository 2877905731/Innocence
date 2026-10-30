#!/bin/sh
set -eu
backup_directory=$(realpath "${1:?Verified pre-upgrade backup directory required}")
case "$backup_directory" in /opt/innocence/backups/pre-online-*) ;; *) exit 1 ;; esac
test -s "$backup_directory/innocence.sql.gz"
test -s "$backup_directory/server.jar"
gzip -t "$backup_directory/innocence.sql.gz"
cd /opt/innocence/online-staging
sha256sum -c innocence-deploy.tar.gz.sha256
tar -xzf innocence-deploy.tar.gz -C /opt/innocence
cd /opt/innocence
sha256sum -c SHA256SUMS >/dev/null
docker compose config --quiet
docker compose build backend
docker compose up -d --no-deps --wait --wait-timeout 240 backend
curl --fail --silent --show-error http://127.0.0.1:8080/actuator/health
printf '\nONLINE_BACKEND_UPGRADE_READY\n'
