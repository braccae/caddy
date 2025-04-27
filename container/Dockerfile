ARG TARGETPLATFORM
ARG TARGETARCH
ARG TARGETVARIANT
ARG CADDY_VERSION

# Simple approach: Use Alpine 3 for ARM/ARM32, 3.21.3 for others
FROM alpine:3.21.3

# Switch to Alpine 3 for ARM32 variants
RUN if [ "${TARGETARCH}" = "arm" ]; then \
      echo "Using Alpine 3 for ARM32 (${TARGETVARIANT})"; \
      sed -i 's/v3.21.3/v3/g' /etc/apk/repositories; \
    fi

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
    if [ "${TARGETARCH}" = "amd64" ]; then \
        ARCH="amd64v1"; \
    elif [ "${TARGETARCH}" = "arm64" ]; then \
        ARCH="arm64v8"; \
    elif [ "${TARGETARCH}" = "arm" ]; then \
        if [ "${TARGETVARIANT}" = "v7" ]; then \
            ARCH="arm32v7"; \
        else \
            ARCH="arm32v6"; \
        fi; \
    elif [ "${TARGETARCH}" = "riscv64" ]; then \
        ARCH="riscv64"; \
    else \
        echo "Unsupported architecture: ${TARGETARCH}/${TARGETVARIANT}"; \
        exit 1; \
    fi; \
    echo "Downloading Caddy for architecture: ${ARCH}"; \
    wget -O /usr/bin/caddy "https://github.com/braccae/caddy/releases/download/${CADDY_VERSION}/caddy-linux-${ARCH}"; \
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