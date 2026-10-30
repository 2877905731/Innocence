#!/bin/sh
set -eu
cd /opt/innocence
umask 077
directory="/opt/innocence/backups/pre-online-$(date +%Y%m%d%H%M%S)"
mkdir -p "$directory"
docker compose exec -T mysql sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysqldump --user=root --single-transaction --routines --triggers --events --no-tablespaces innocence' > "$directory/innocence.sql"
gzip -c "$directory/innocence.sql" > "$directory/innocence.sql.gz"
gzip -t "$directory/innocence.sql.gz"
docker compose exec -T backend tar -czf - -C /app/data/uploads/avatars . > "$directory/avatars.tar.gz"
tar -tzf "$directory/avatars.tar.gz" >/dev/null
cp -p backend/server.jar "$directory/server.jar"
docker image inspect innocence-server:local --format '{{.Id}}' > "$directory/previous-image-id.txt"
docker image tag innocence-server:local "innocence-server:before-online-$(date +%Y%m%d%H%M%S)"
chmod 600 "$directory"/*
printf 'PRIVATE_BACKUP_READY %s\n' "$directory"
