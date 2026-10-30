#!/bin/sh
set -eu
cd "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

if [ "$(id -u)" -ne 0 ]; then
    echo 'Run as root on the server.' >&2
    exit 1
fi
if [ -e .env ]; then
    echo '.env already exists; preserved without changes. Edit it on the server.'
    exit 0
fi
sha256sum -c SHA256SUMS >/dev/null
umask 077
temporary=$(mktemp .env.tmp.XXXXXX)
trap 'rm -f "$temporary"' EXIT HUP INT TERM
root_password=$(od -An -N32 -tx1 /dev/urandom | tr -d ' \n')
db_password=$(od -An -N32 -tx1 /dev/urandom | tr -d ' \n')
redis_password=$(od -An -N32 -tx1 /dev/urandom | tr -d ' \n')
sed -e "s/__GENERATE_ROOT__/$root_password/" \
    -e "s/__GENERATE_DB__/$db_password/" \
    -e "s/__GENERATE_REDIS__/$redis_password/" .env.example > "$temporary"
chmod 600 "$temporary"
mv "$temporary" .env
echo 'Created private .env with random database/Redis passwords; none were printed.'
echo 'Next: edit INNOCENCE_ADMIN_EMAILS and your SMTP settings in .env on the server.'
