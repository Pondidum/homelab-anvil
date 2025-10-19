FROM docker.io/caddy:2.10.2-builder-alpine AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/ovh

FROM docker.io/caddy:2.10.2-alpine

RUN apk add openbao jq --no-cache

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
COPY ./Caddyfile /etc/caddy/Caddyfile

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
