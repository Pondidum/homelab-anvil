#!/bin/sh

set -eu

echo "==> External DNS Update"

domain="sammalmaa.fi"
record="5442797647"

external_ip=$(curl -sSL --url "https://api.ipify.org")
dns_ip=$(ovhcloud domain-zone record get "${domain}" "${record}" | jq -r ".target")

echo "    external ip: ${external_ip}"
echo "    dns ip:      ${dns_ip}"

if [ "${dns_ip}" = "${external_ip}" ]; then
  echo "--> Records match, exiting"
  exit 0
fi

echo "--> Updating DNS IP"
ovhcloud domain-zone record update "${domain}" "${record}" --target "${external_ip}" --ttl 300

echo "==> Done"
