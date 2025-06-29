# Custom Caddy Build

A custom Caddy web server build with enhanced security, cloud integration, and enterprise features. This build includes carefully selected plugins for production deployments with advanced security, dynamic DNS, cloud storage, and monitoring capabilities.

## 🚀 Features

### Core Enhancements
- **Layer 4 Load Balancing** - TCP/UDP proxy capabilities via `caddy-l4`
- **Advanced Security** - Authentication, authorization, and security policies via `caddy-security`
- **JSON Schema Validation** - Configuration validation with `caddy-json-schema`

### Security & Protection
- **CrowdSec Integration** - Real-time threat protection with bouncer support for HTTP, Layer 4, and AppSec
- **Cloudflare IP Restoration** - Proper client IP handling behind Cloudflare

### DNS & Certificates
- **Dynamic DNS** - Automatic DNS record updates
- **Cloudflare DNS** - ACME DNS challenge support for Cloudflare
- **Multi-Storage Backends** - Flexible certificate storage options

### Storage Backends
- **Vault Storage** - HashiCorp Vault integration for secure certificate storage
- **Cloudflare KV Storage** - Cloudflare Workers KV for distributed storage
- **S3 Storage** - Amazon S3 compatible storage via CertMagic
- **Storage Loader** - Dynamic storage backend loading

## 📦 Installation

### Using Pre-built Binaries

Download the latest release for your platform:

```bash
# Linux AMD64
wget https://github.com/braccae/caddy/releases/latest/download/caddy-linux-amd64v1

# Linux ARM64
wget https://github.com/braccae/caddy/releases/latest/download/caddy-linux-arm64v8

# Linux ARM32v7
wget https://github.com/braccae/caddy/releases/latest/download/caddy-linux-arm32v7
```

Make it executable:
```bash
chmod +x caddy-linux-*
sudo mv caddy-linux-* /usr/local/bin/caddy
```

### Using Container (Recommended)

#### Podman Quadlet (Systemd)

1. Copy the `caddy.container` file to your systemd user directory:
```bash
mkdir -p ~/.config/containers/systemd/
cp caddy.container ~/.config/containers/systemd/
```

2. Create your Caddyfile configuration directory:
```bash
mkdir -p ~/caddyfile.d/
```

3. Configure secrets and environment variables in the container file

4. Reload systemd and start the service:
```bash
systemctl --user daemon-reload
systemctl --user enable --now caddy.service
```

#### Docker/Podman Run

```bash
docker run -d \
  --name caddy \
  -p 80:80 \
  -p 443:443 \
  -v caddy-data:/data \
  -v caddy-logs:/logs \
  -v ./caddyfile.d:/caddyfile.d:ro \
  -e EMAIL=your-email@example.com \
  -e CF_API_TOKEN=your-cloudflare-token \
  -e MODE=dev \
  ghcr.io/braccae/caddy:latest
```

## ⚙️ Configuration

### Environment Modes

The container supports three configuration modes:

- **`dev`** - Development mode with file storage and verbose logging
- **`staging`** - Staging mode with S3 storage backend
- **`prod`** - Production mode with Vault storage backend

### Environment Variables

#### Required
- `EMAIL` - Email address for ACME certificate registration
- `MODE` - Configuration mode (`dev`, `staging`, `prod`)

#### Cloudflare Integration
- `CF_API_TOKEN` - Cloudflare API token for DNS challenges

#### CrowdSec Security
- `CROWDSEC_API_URL` - CrowdSec API endpoint
- `CROWDSEC_API_KEY` - CrowdSec API key
- `CROWDSEC_TICKER_INTERVAL` - Update interval for CrowdSec rules
- `CROWDSEC_APPSEC_URL` - CrowdSec AppSec endpoint
- `CROWDSEC_ENABLE_HARD_FAILS` - Enable hard failures on CrowdSec errors

#### Production Storage (Vault)
- `VAULT_ADDR` - HashiCorp Vault server address
- `vault_token` - Vault authentication token (as secret)

#### Staging Storage (S3)
- `S3_HOST` - S3 endpoint hostname
- `S3_BUCKET` - S3 bucket name
- `S3_PREFIX` - S3 key prefix
- `S3_ACCESS_KEY` - S3 access key (as secret)
- `S3_SECRET_KEY` - S3 secret key (as secret)
- `S3_ENCRYPTION_KEY` - S3 encryption key (optional, as secret)

### Caddyfile Configuration

Place your site configurations in the `~/caddyfile.d/` directory with `.caddyfile` extension:

```caddyfile
# ~/caddyfile.d/example.caddyfile
example.com {
    reverse_proxy localhost:8080

    # Enable security features
    security {
        authentication portal myportal {
            crypto default token lifetime 3600
            backends {
                local_backend {
                    method local
                    path /etc/caddy/auth/local/users.json
                }
            }
        }
    }

    # CrowdSec protection
    crowdsec {
        api_url {$CROWDSEC_API_URL}
        api_key {$CROWDSEC_API_KEY}
    }
}
```

## 🏗️ Building from Source

### Prerequisites
- Go 1.24.2 or later
- Git

### Build Process

1. Clone the repository:
```bash
git clone https://github.com/braccae/caddy.git
cd caddy
```

2. Build the binary:
```bash
cd src
go build -o ../caddy .
```

3. Run the custom Caddy:
```bash
./caddy run --config Caddyfile
```

### Cross-compilation

Build for different platforms:

```bash
# Linux ARM64
GOOS=linux GOARCH=arm64 go build -o caddy-linux-arm64 .

# Windows AMD64
GOOS=windows GOARCH=amd64 go build -o caddy-windows-amd64.exe .

# macOS ARM64
GOOS=darwin GOARCH=arm64 go build -o caddy-darwin-arm64 .
```

## 🔧 Development

### Project Structure

```
├── src/                    # Go source code
│   ├── main.go            # Main entry point with plugin imports
│   ├── go.mod             # Go module dependencies
│   └── go.sum             # Dependency checksums
├── container/             # Container configurations
│   ├── Dockerfile         # Multi-arch container build
│   ├── rootless.Dockerfile # Rootless container variant
│   ├── dev.Caddyfile      # Development configuration
│   ├── staging.Caddyfile  # Staging configuration
│   └── prod.Caddyfile     # Production configuration
├── .github/workflows/     # CI/CD pipelines
└── caddy.container        # Podman Quadlet configuration
```

### Adding New Plugins

1. Add the plugin import to `src/main.go`:
```go
import (
    // ... existing imports
    _ "github.com/example/caddy-plugin"
)
```

2. Update dependencies:
```bash
cd src
go mod tidy
```

3. Test the build:
```bash
go build .
```

### CI/CD Pipeline

The project includes automated GitHub Actions workflows:

- **Build and Release** - Multi-architecture binary builds on push to main
- **Container Publishing** - Automated container builds and publishing to GHCR
- **Rootless Container** - Separate rootless container builds

## 📚 Plugin Documentation

### Core Plugins

- [Caddy L4](https://github.com/mholt/caddy-l4) - Layer 4 load balancing
- [Caddy Security](https://github.com/greenpau/caddy-security) - Authentication and authorization
- [Caddy JSON Schema](https://github.com/abiosoft/caddy-json-schema) - Configuration validation

### DNS & Certificates

- [Caddy Dynamic DNS](https://github.com/mholt/caddy-dynamicdns) - Dynamic DNS updates
- [Caddy DNS Cloudflare](https://github.com/caddy-dns/cloudflare) - Cloudflare DNS provider

### Security

- [CrowdSec Bouncer](https://github.com/hslatman/caddy-crowdsec-bouncer) - CrowdSec integration
- [Cloudflare IP](https://github.com/WeidiDeng/caddy-cloudflare-ip) - Real IP restoration

### Storage

- [Vault Storage](https://github.com/gerolf-vent/caddy-vault-storage) - HashiCorp Vault backend
- [Cloudflare KV Storage](https://github.com/mentimeter/caddy-storage-cf-kv) - Cloudflare Workers KV
- [CertMagic S3](https://github.com/techknowlogick/certmagic-s3) - S3 storage backend
- [Storage Loader](https://github.com/mohammed90/caddy-storage-loader) - Dynamic storage loading

## 🔒 Security Considerations

### Container Security

- Runs as non-root user (`proxy`)
- Uses minimal Alpine Linux base image
- Implements health checks
- Supports rootless container deployment

### Network Security

- Proxy Protocol support for real client IPs
- TLS termination with automatic HTTPS
- CrowdSec integration for threat protection
- Cloudflare IP restoration

### Storage Security

- Multiple secure storage backends
- Vault integration for production secrets
- S3 encryption support
- Secure secret management via container secrets

## 📊 Monitoring & Health Checks

### Health Endpoint

The container includes a built-in health check endpoint:

```
GET http://localhost/healthz
```

Returns `200 OK` when the service is healthy.

### Logging

- Structured JSON logging in production
- Configurable log levels
- Integration with systemd journal
- Container log aggregation support

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- [Caddy Community Forum](https://caddy.community/)
- [GitHub Issues](https://github.com/braccae/caddy/issues)
- [Caddy Documentation](https://caddyserver.com/docs/)

## 🙏 Acknowledgments

- [Caddy Server](https://caddyserver.com/) - The amazing web server this build is based on
- All plugin authors for their excellent contributions to the Caddy ecosystem
- The open-source community for continuous improvements and feedback
