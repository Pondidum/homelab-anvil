#!/bin/sh

set -eu

json=$(cat '/openbao/config/server.json')
seal_file=$(echo "${json}" | jq -r '.seal.static.current_key | sub("^file://"; "")')

if ! [ -f "${seal_file}" ]; then
  echo "==> Generating unseal key"
  echo "    Key path: ${seal_file}"

  openssl rand -out "${seal_file}" 32
fi

exec /usr/local/bin/docker-entrypoint.sh "$@"
