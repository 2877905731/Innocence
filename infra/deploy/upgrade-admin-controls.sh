#!/bin/sh
set -eu
candidate=$(realpath "${1:-/opt/innocence/admin-controls-candidate}")
test "$candidate" = /opt/innocence/admin-controls-candidate
cd "$candidate"
sha256sum -c innocence-deploy.tar.gz.sha256
tar -xzf innocence-deploy.tar.gz
sha256sum -c SHA256SUMS >/dev/null
expected_jar=$(sha256sum backend/server.jar | cut -d ' ' -f 1)
image_jar=$(docker run --rm --entrypoint sha256sum innocence-server:admin-controls-candidate /app/server.jar | cut -d ' ' -f 1)
test "$expected_jar" = "$image_jar"
cd /opt/innocence
docker compose config --quiet
backup=$(sh /opt/innocence/backup-before-upgrade.sh | awk '/^PRIVATE_BACKUP_READY / {print $2}')
case "$backup" in /opt/innocence/backups/pre-online-*) ;; *) exit 1 ;; esac
test -s "$backup/server.jar"
tar -czf "$backup/admin-web.tar.gz" -C /opt/innocence/admin-web .
chmod 600 "$backup/admin-web.tar.gz"
python3 -c 'import json,pathlib,sys; names=list(json.load(open("manifest.json"))["files"])+["manifest.json","SHA256SUMS"]; assert all(not pathlib.PurePosixPath(n).is_absolute() and ".." not in pathlib.PurePosixPath(n).parts and not n.startswith("-") for n in names); sys.stdout.buffer.write(b"\0".join(n.encode() for n in names)+b"\0")' > "$backup/deployment-files.list"
tar -czf "$backup/deployment-files.tar.gz" -C /opt/innocence --null -T "$backup/deployment-files.list"
success=false
rollback() {
    code=$?
    trap - EXIT
    if [ "$success" != true ]; then
        printf 'ADMIN_UPGRADE_FAILED_ROLLING_BACK\n' >&2
        tar -xzf "$backup/deployment-files.tar.gz" -C /opt/innocence
        docker image tag "$(cat "$backup/previous-image-id.txt")" innocence-server:local
        docker compose up -d --no-deps --force-recreate --wait --wait-timeout 240 backend || true
        tar -xzf "$backup/admin-web.tar.gz" -C /opt/innocence/admin-web
    fi
    exit "$code"
}
trap rollback EXIT
docker compose exec -T mysql sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysql --user=root --database=innocence' < "$candidate/database/20261031-admin-account-controls.sql"
cp -p "$candidate/backend/server.jar" /opt/innocence/backend/server.jar
docker image tag innocence-server:admin-controls-candidate innocence-server:local
docker compose up -d --no-deps --force-recreate --wait --wait-timeout 240 backend
curl --fail --silent --show-error http://127.0.0.1:8080/actuator/health
# Keep old hashed assets for tabs that were opened before this update.
cp -a "$candidate/admin-web/assets/." /opt/innocence/admin-web/assets/
cp "$candidate/admin-web/index.html" /opt/innocence/admin-web/index.html.new
mv /opt/innocence/admin-web/index.html.new /opt/innocence/admin-web/index.html
tar -xzf "$candidate/innocence-deploy.tar.gz" --exclude='admin-web*' -C /opt/innocence
sha256sum -c SHA256SUMS >/dev/null
curl --fail --silent --show-error https://85.189.40.87/healthz
success=true
printf '\nADMIN_CONTROLS_UPGRADED backup=%s\n' "$backup"
