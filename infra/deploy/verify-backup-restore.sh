#!/bin/sh
set -eu
backup_directory=$(realpath "${1:?Private backup directory required}")
case "$backup_directory" in /opt/innocence/backups/pre-online-*) ;; *) echo 'Unexpected backup path' >&2; exit 1 ;; esac
test -f "$backup_directory/innocence.sql"
cd /opt/innocence
container="innocence-restore-check-$(date +%Y%m%d%H%M%S)"
docker run --detach --rm --name "$container" --network none --memory 512m \
    --label innocence.purpose=restore-check --env-file /opt/innocence/.env \
    --env MYSQL_DATABASE=innocence --env MYSQL_USER=innocence mysql:8.4 \
    --innodb-buffer-pool-size=64M --performance-schema=OFF --max-connections=10 >/dev/null
cleanup() { docker stop "$container" >/dev/null 2>&1 || true; }
trap cleanup EXIT HUP INT TERM
ready=false
for attempt in $(seq 1 30); do
    if docker exec "$container" sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql --protocol=TCP --host=127.0.0.1 --user=root --execute="SELECT 1" >/dev/null 2>&1'; then
        ready=true
        break
    fi
    sleep 2
done
test "$ready" = true
docker exec -i "$container" sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysql --user=root --database=innocence' < "$backup_directory/innocence.sql"
for table in app_user user_auth user_profile daily_plan memo_record study_timer_record; do
    original=$(docker compose exec -T mysql sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysql --user=root --database=innocence --batch --skip-column-names --execute="$1"' sh "SELECT COUNT(*) FROM $table")
    restored=$(docker exec "$container" sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysql --user=root --database=innocence --batch --skip-column-names --execute="$1"' sh "SELECT COUNT(*) FROM $table")
    if [ "$original" != "$restored" ]; then echo "Restore row count differs for $table" >&2; exit 1; fi
done
restored_tables=$(docker exec "$container" sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysql --user=root --batch --skip-column-names --execute="SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=\"innocence\""')
test "$restored_tables" -gt 30
printf 'ISOLATED_BACKUP_RESTORE_PASS tables=%s checked_business_counts=6\n' "$restored_tables"
