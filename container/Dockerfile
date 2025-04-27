# Build arguments for architecture targeting
ARG TARGETPLATFORM
ARG TARGETARCH
ARG TARGETVARIANT

# Simple approach: Use Alpine 3 for ARM32 variants, 3.21.3 for others
FROM alpine:3.21.3

# Immediately redefine build arguments so they're available in this build stage
ARG TARGETARCH
ARG TARGETVARIANT
ARG CADDY_VERSION

RUN apk add --no-cache \
	ca-certificates \
	libcap \
	mailcap

RUN set -eux; \
	mkdir -p \
		/config/caddy \
		/data/caddy \
		/etc/caddy \
		/usr/share/caddy \
	; \
	wget -O /etc/caddy/Caddyfile "https://github.com/caddyserver/dist/raw/33ae08ff08d168572df2956ed14fbc4949880d94/config/Caddyfile"; \
	wget -O /usr/share/caddy/index.html "https://github.com/caddyserver/dist/raw/33ae08ff08d168572df2956ed14fbc4949880d94/welcome/index.html"

# Download the appropriate Caddy binary based on architecture
RUN set -eux; \
   # Use the updated naming convention
   case "${TARGETARCH}" in \
     amd64) binArch='amd64v1'; ;; \
     arm) case "${TARGETVARIANT}" in v7) binArch='arm32v7';; v6) binArch='arm32v6';; *) binArch='arm32v6';; esac; ;; \
     arm64) binArch='arm64v8'; ;; \
     riscv64) binArch='riscv64'; ;; \
     *) echo >&2 "error: unsupported architecture ${TARGETARCH}/${TARGETVARIANT}"; exit 1; ;; \
   esac; \
   echo "Downloading binary for architecture: ${binArch}"; \
   wget -O /usr/bin/caddy "https://github.com/braccae/caddy/releases/download/${CADDY_VERSION}/caddy-linux-${binArch}"; \
   chmod +x /usr/bin/caddy; \
   setcap cap_net_bind_service=+ep /usr/bin/caddy; \
   caddy version

# See https://caddyserver.com/docs/conventions#file-locations for details
ENV XDG_CONFIG_HOME=/config \
    XDG_DATA_HOME=/data

LABEL org.opencontainers.image.version=${CADDY_VERSION}
LABEL org.opencontainers.image.title=Caddy
LABEL org.opencontainers.image.description="a powerful, enterprise-ready, open source web server with automatic HTTPS written in Go"
LABEL org.opencontainers.image.url=https://caddyserver.com
LABEL org.opencontainers.image.documentation=https://caddyserver.com/docs
LABEL org.opencontainers.image.vendor="Light Code Labs"
LABEL org.opencontainers.image.licenses=Apache-2.0
LABEL org.opencontainers.image.source="https://github.com/braccae/caddy"

EXPOSE 80
EXPOSE 443
EXPOSE 443/udp
EXPOSE 2019

WORKDIR /srv

ENV MODE=prod
COPY *.Caddyfile /etc/caddy/

CMD ["caddy", "run", "--config", "/etc/caddy/$MODE.Caddyfile", "--adapter", "caddyfile"]