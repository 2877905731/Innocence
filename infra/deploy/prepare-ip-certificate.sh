#!/bin/sh
set -eu
server_ip=${1:?IPv4 address required}
python3 -c 'import ipaddress,sys; value=ipaddress.ip_address(sys.argv[1]); assert value.version == 4 and value.is_global' "$server_ip"
cd "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
install -d -m 700 /opt/innocence/backups
install -d -m 755 /var/lib/innocence-acme/.well-known/acme-challenge
target=/etc/nginx/conf.d/innocence-acme.conf
if [ -f "$target" ]; then
    cp -a "$target" "/opt/innocence/backups/innocence-acme.$(date +%Y%m%d%H%M%S).conf"
fi
sed "s/@SERVER_IP@/$server_ip/g" nginx/innocence-acme.conf.template > "$target"
nginx -t
systemctl reload nginx
/opt/innocence-certbot/bin/certbot certonly --non-interactive \
    --agree-tos --register-unsafely-without-email \
    --preferred-profile shortlived --webroot --webroot-path /var/lib/innocence-acme \
    --ip-address "$server_ip" --cert-name innocence-api-ip --key-type rsa --rsa-key-size 2048
openssl x509 -in /etc/letsencrypt/live/innocence-api-ip/cert.pem \
    -noout -dates -ext subjectAltName
