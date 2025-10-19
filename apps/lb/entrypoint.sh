#!/bin/sh

set -eu

export BAO_ADDR=https://safehouse.incus:8200

# trust the anvil certificate, as this is talking directly to safehouse as it needs to issue the cert for the lb
cat /etc/anvil/certificates/anvil.pem >> /etc/ssl/certs/ca-certificates.crt

eval $(bao kv get -format json kv/external/ovh/certificates | jq -r '.data.data | to_entries[] | "export OVH_\(.key | ascii_upcase)=\(.value)"')

exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
