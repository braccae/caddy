# Define ARGs before FROM (required for Docker build system)
ARG TARGETARCH
ARG TARGETVARIANT
ARG CADDY_VERSION

# Base image selection
FROM alpine:3.22.1

# Redefine ARGs after FROM (required)
ARG TARGETARCH
ARG TARGETVARIANT
ARG CADDY_VERSION

RUN apk add --no-cache \
	ca-certificates \
	libcap \
	mailcap \
    curl

RUN set -eux; \
	mkdir -p \
		/config/caddy \
		/data/caddy \
		/etc/caddy \
		/usr/share/caddy \
	; \
	wget -O /etc/caddy/Caddyfile "https://github.com/caddyserver/dist/raw/33ae08ff08d168572df2956ed14fbc4949880d94/config/Caddyfile"; \
	wget -O /usr/share/caddy/index.html "https://github.com/caddyserver/dist/raw/33ae08ff08d168572df2956ed14fbc4949880d94/welcome/index.html"

# Switch to Alpine 3 for ARM32 variants and download the correct binary in one step
RUN set -eux; \
    # For ARM32, switch to Alpine 3 \
    if [ "${TARGETARCH}" = "arm" ]; then \
        echo "Using Alpine 3 for ARM32 variant: ${TARGETVARIANT}"; \
        sed -i 's/v3.21.3/v3/g' /etc/apk/repositories; \
    fi; \
    \
    # Determine which binary to download based on architecture \
    if [ "${TARGETARCH}" = "amd64" ]; then \
        ARCH=amd64v1; \
    elif [ "${TARGETARCH}" = "arm64" ]; then \
        ARCH=arm64v8; \
    elif [ "${TARGETARCH}" = "arm" ] && [ "${TARGETVARIANT}" = "v7" ]; then \
        ARCH=arm32v7; \
    elif [ "${TARGETARCH}" = "arm" ]; then \
        ARCH=arm32v6; \
    elif [ "${TARGETARCH}" = "riscv64" ]; then \
        ARCH=riscv64; \
    else \
        echo "Unknown architecture: ${TARGETARCH}/${TARGETVARIANT}"; \
        exit 1; \
    fi; \
    \
    echo "Downloading Caddy binary for ${ARCH}"; \
    wget -O /usr/bin/caddy "https://github.com/braccae/caddy/releases/download/${CADDY_VERSION}/caddy-linux-${ARCH}"; \
    chmod +x /usr/bin/caddy; \
    setcap cap_net_bind_service=+ep /usr/bin/caddy; \
    caddy version

# See https://caddyserver.com/docs/conventions#file-locations for details
ENV XDG_CONFIG_HOME=/config \
    XDG_DATA_HOME=/data

LABEL org.opencontainers.image.version=${CADDY_VERSION}
LABEL org.opencontainers.image.title=Caddy
LABEL org.opencontainers.image.description="a powerful, customized, enterprise-ready, open source web server with automatic HTTPS written in Go"
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

VOLUME [ "/config" ]
VOLUME [ "/data" ]
VOLUME [ "/caddyfile.d" ]

USER 1000
CMD caddy run --config /etc/caddy/$MODE.Caddyfile --adapter caddyfile