#!/bin/sh
set -e

CRT="/var/lib/postgresql/server.crt"
KEY="/var/lib/postgresql/server.key"

echo ">>> Generating self-signed certificate"
openssl req -new -x509 -days 3650 -nodes \
    -text -out "$CRT" -keyout "$KEY" \
    -subj "/CN=$(hostname)"    # CN は何でも可（IP でも FQDN でも）

chmod 600 "$KEY"
chown postgres:postgres "$CRT" "$KEY"

echo ">>> Enabling SSL in postgresql.conf"
cat >> "$PGDATA/postgresql.conf" <<EOF
ssl = on
ssl_cert_file = '$CRT'
ssl_key_file  = '$KEY'
EOF