#/bin/sh

mkcert \
  -cert-file certs/anvil.crt \
  -key-file certs/anvil.key \
  anvil "*.verstas.xyz" "*.incus" localhost 127.0.0.1

sudo cp certs/anvil.crt certs/anvil.key /var/lib/incus/storage-pools/tank/custom/default_certificates/
