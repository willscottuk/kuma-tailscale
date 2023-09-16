FROM tailscale/tailscale:stable as tailscale
FROM louislam/uptime-kuma:latest

RUN apt-get update && apt-get install -y ca-certificates iptables \
    && rm -rf /var/lib/apt/lists/*

COPY --from=tailscale /usr/local/bin/tailscaled /usr/local/bin/tailscaled
COPY --from=tailscale /usr/local/bin/tailscale /usr/local/bin/tailscale

RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

ENV TS_HOSTNAME=uptime

EXPOSE 3001

VOLUME ["/app/data"]

HEALTHCHECK --interval=60s --timeout=30s --start-period=180s --retries=5 CMD curl --fail http://localhost:3001/healthcheck || exit 1

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/bin/sh", "-c", "/usr/local/bin/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock & /usr/local/bin/tailscale up --authkey=$TS_AUTHKEY --accept-routes --hostname=$TS_HOSTNAME --login-server=$TS_SERVER & node server/server.js"]
