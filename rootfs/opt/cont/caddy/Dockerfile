FROM caddy:builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare

FROM caddy:alpine

RUN apk add --no-cache inotify-tools

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY compile-caddyfile.sh /usr/bin/compile-caddyfile.sh
COPY watch-domains.sh /usr/bin/watch-domains.sh
RUN chmod +x /usr/bin/compile-caddyfile.sh /usr/bin/watch-domains.sh

CMD ["/bin/sh", "-c", "compile-caddyfile.sh && watch-domains.sh & caddy run --config /etc/caddy/Caddyfile"]
