#!/bin/sh
set -eu
server_ip=${1:?IPv4 address required}
python3 -c 'import ipaddress,sys; value=ipaddress.ip_address(sys.argv[1]); assert value.version == 4 and value.is_global' "$server_ip"
cd "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
openssl x509 -checkend 172800 -noout -in /etc/letsencrypt/live/innocence-api-ip/cert.pem
curl --fail --silent --show-error http://127.0.0.1:8080/actuator/health >/dev/null
target=/etc/nginx/conf.d/innocence-api-https.conf
backup="/opt/innocence/backups/innocence-api.$(date +%Y%m%d%H%M%S).conf"
if [ -f "$target" ]; then cp -a "$target" "$backup"; fi
sed "s/@SERVER_IP@/$server_ip/g" nginx/innocence-api-https.conf.template > "$target"
if ! nginx -t; then
    mv "$target" "$target.failed.$(date +%Y%m%d%H%M%S)"
    if [ -f "$backup" ]; then cp -a "$backup" "$target"; fi
    exit 1
fi
systemctl reload nginx
curl --fail --silent --show-error "https://$server_ip/healthz"
printf '\nPUBLIC_API_HTTPS_READY\n'
