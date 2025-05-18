#!/bin/sh
set -eu
apk add --no-cache openssl

CRT="$PGDATA/server.crt"
KEY="$PGDATA/server.key"

openssl req -new -x509 -nodes -days 3650 \
    -subj "/CN=$(hostname)" -out "$CRT" -keyout "$KEY"

chmod 600 "$KEY"
chown postgres:postgres "$CRT" "$KEY"

cat >> "$PGDATA/postgresql.conf" <<EOF
ssl = on
ssl_cert_file = '$CRT'
ssl_key_file  = '$KEY'
EOF

cat > "$PGDATA/pg_hba.conf" <<EOF
hostssl all all 0.0.0.0/0 scram-sha-256
hostnossl all all 0.0.0.0/0 reject
EOF
