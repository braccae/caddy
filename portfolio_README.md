---
title: Custom Caddy Build
publishDate: 2025-11-01 00:00:00
img: /assets/caddy-logo.png
img_alt: Caddy Web Server Logo
description: |
  Developed a custom Caddy web server build with enhanced security, cloud integration, and enterprise features,
  including carefully selected plugins for production deployments with advanced security, dynamic DNS,
  cloud storage, and monitoring capabilities.
tags:
  - Go
  - Caddy
  - Docker
  - Kubernetes
  - Cloudflare
  - Vault
  - AWS S3
  - CrowdSec
---

## Project Overview

This project involved creating a highly customized Caddy web server designed for robust production environments. The goal was to extend Caddy's core capabilities with advanced features for security, cloud integration, and flexible deployment, addressing common challenges in modern web infrastructure.

## Key Features & Technologies

### Core Enhancements
- **Layer 4 Load Balancing:** Implemented TCP/UDP proxy capabilities using the `caddy-l4` plugin, enabling Caddy to handle a wider range of network traffic beyond HTTP/S.
- **Advanced Security:** Integrated `caddy-security` for comprehensive authentication, authorization, and security policy enforcement, providing granular control over access to resources.
- **JSON Schema Validation:** Utilized `caddy-json-schema` to ensure configuration integrity and prevent common deployment errors through schema-based validation.

### Security & Protection
- **CrowdSec Integration:** Incorporated real-time threat protection with bouncer support for HTTP, Layer 4, and AppSec, significantly enhancing the server's resilience against malicious attacks.
- **Cloudflare IP Restoration:** Ensured accurate client IP handling when deployed behind Cloudflare, crucial for proper logging and security analysis.

### DNS & Certificates
- **Dynamic DNS:** Enabled automatic DNS record updates, simplifying certificate management and domain resolution in dynamic environments.
- **Cloudflare DNS:** Provided ACME DNS challenge support specifically for Cloudflare, streamlining automated HTTPS certificate provisioning.
- **Multi-Storage Backends:** Designed for flexible certificate storage with support for various backends.

### Storage Backends
- **Vault Storage:** Integrated HashiCorp Vault for secure and centralized certificate storage, ideal for Kubernetes and other secret management systems.
- **Cloudflare KV Storage:** Leveraged Cloudflare Workers KV for distributed certificate storage, offering high availability and global distribution.
- **S3 Storage:** Implemented Amazon S3 compatible storage via CertMagic, providing a reliable and scalable object storage solution for certificates.
- **Storage Loader:** Developed a dynamic storage backend loading mechanism, allowing easy switching between storage solutions based on environment needs.

## Deployment & Configuration

The project emphasizes containerized deployment, with a `Dockerfile` tailored for a custom Caddy build. It supports multiple environment modes (`dev`, `staging`, `prod`), each configured with a specific `Caddyfile` to optimize for different deployment scenarios:

- **`dev` Mode:** Uses local file system for certificate storage and verbose logging for easier debugging.
- **`staging` Mode:** Configured with S3 storage for certificates, mimicking a production-like environment without using sensitive production credentials. CrowdSec is enabled.
- **`prod` Mode:** Utilizes HashiCorp Vault for highly secure certificate storage, integrating with Kubernetes for token management. CrowdSec is fully enabled for real-time threat protection.

Environment variables are extensively used to manage configuration, including `EMAIL`, `CF_API_TOKEN`, `MODE`, and specific credentials for Vault, S3, and CrowdSec. This approach ensures flexibility and security across different deployment stages.

## Technical Achievements

- Successfully built a custom Caddy server with a comprehensive suite of plugins, extending its functionality beyond standard offerings.
- Implemented robust security measures, including CrowdSec integration and secure certificate storage solutions.
- Designed a flexible deployment strategy using Docker and environment-specific Caddyfiles, catering to development, staging, and production needs.
- Demonstrated proficiency in integrating various cloud services (Cloudflare, AWS S3, HashiCorp Vault) with Caddy for enhanced functionality and security.
