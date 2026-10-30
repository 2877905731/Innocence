#!/bin/sh
set -eu
cd "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

if [ "$(id -u)" -ne 0 ] || [ "$(pwd -P)" != /opt/innocence ]; then
    echo 'Extract this first-deployment bundle to /opt/innocence and run as root.' >&2
    exit 1
fi
sha256sum -c SHA256SUMS >/dev/null
if [ ! -f .env ]; then
    echo 'Run sh prepare.sh and edit .env on the server first.' >&2
    exit 1
fi
if grep -q '__GENERATE_' .env; then
    echo 'Unconfigured database/Redis password placeholders remain.' >&2
    exit 1
fi
chmod 600 .env
docker compose config --quiet

if ! docker volume inspect innocence-server_mysql_data >/dev/null 2>&1; then
    if [ "${1:-}" != --initialize-empty-database ]; then
        echo 'No existing database volume. For a deliberately NEW empty database, run:' >&2
        echo 'sh start.sh --initialize-empty-database' >&2
        echo 'For migration, stop here and prepare the agreed backup/restore procedure.' >&2
        exit 1
    fi
fi

target=/etc/nginx/conf.d/innocence-local.conf
if [ -e "$target" ] && ! cmp -s nginx/innocence-local.conf "$target"; then
    echo 'An existing different Innocence Nginx config was preserved; review it manually.' >&2
    exit 1
fi
docker compose pull mysql redis
docker compose build backend
docker compose up -d --wait --wait-timeout 300

chmod 755 /opt/innocence admin-web
install -m 644 nginx/innocence-local.conf "$target"
if ! nginx -t; then
    mv "$target" "$target.failed.$(date +%Y%m%d%H%M%S)"
    echo 'Nginx config check failed; the candidate was moved aside. No reload occurred.' >&2
    exit 1
fi
systemctl reload nginx
curl --fail --silent --show-error http://127.0.0.1:8080/actuator/health
printf '\n'
curl --fail --silent --show-error --output /dev/null http://127.0.0.1:18081/
status=$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' \
    http://127.0.0.1:18081/api/admin/v1/auth/me)
if [ "$status" != 401 ]; then
    echo 'Expected HTTP 401 for an unauthenticated admin request; inspection required.' >&2
    exit 1
fi
echo 'Backend health and static page checks passed; unauthenticated admin access returned 401.'
echo 'Admin is available through the SSH tunnel to server port 18081.'
echo 'SMTP delivery, account creation/login, backups and public HTTPS still require verification.'
