#/bin/sh

mkcert \
  -cert-file certs/anvil.crt \
  -key-file certs/anvil.key \
  anvil anvil.verstas.xyz localhost 127.0.0.1
