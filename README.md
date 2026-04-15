# DGen Development Containers

English | [中文](README_zh.md)

# English

## Overview

DGen provides production-ready Docker development containers optimized for modern software development workflows.

### Features

- 🚀 **Multi-Architecture Support**: Builds for both `amd64` (x86_64) and `arm64` (aarch64)
- 🐚 **Modern Shell Experience**: Fish Shell with Starship prompt and intelligent aliases
- 💻 **VS Code Integration**: Pre-configured Code Server with extensions and Chinese UI
- 🔐 **Secure SSH Access**: Passwordless authentication with key forwarding
- 🌍 **Internationalization**: Full Chinese and English language support
- 🔧 **Dev Containers Ready**: Compatible with VS Code Remote - Containers

### Available Images

| Image | Description | Base |
|-------|-------------|------|
| `default` | Universal development environment with Code Server | Debian 13 (Trixie) |
| `cangjie` | Cangjie programming language development environment | Debian 13 (Trixie) |

## Quick Start

### Prerequisites

- Docker 20.10+ or Docker Desktop
- Docker Compose v2.0+
- (Optional) VS Code with Dev Containers extension

### Using Docker Compose

```bash
# Clone the repository
git clone https://github.com/ertu426/dgen.git
cd dgen

# Build and start all containers
docker compose up -d --build

# View logs
docker compose logs -f

# Stop containers
docker compose down
```

### Using with VS Code Dev Containers

1. Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. Open the project in VS Code
3. Press `F1` and select **"Dev Containers: Open Folder in Container"**
4. Select `.devcontainer/devcontainer.json` for default environment
5. Or select `.devcontainer/devcontainer-cangjie.json` for Cangjie environment

### SSH Connection

```bash
# Connect via SSH (password: dev123456)
ssh -p 30022 dev@localhost

# With key forwarding
ssh -p 30022 -A dev@localhost
```

### Accessing Code Server

1. Open browser: http://localhost:30080
2. Default password: `dev123456`
3. Change password in `files/config.yaml`

## Configuration

### Environment Variables

Create a `.env` file to customize settings:

```env
# Version
VERSION=latest

# GitHub Organization (for GHCR)
GITHUB_ORG=ertu426

# Pull Policy
PULL_POLICY=if-not-present

# Ports
DEFAULT_HTTP_PORT=30080
DEFAULT_SSH_PORT=30022
CANGJIE_HTTP_PORT=30180
CANGJIE_SSH_PORT=30122

# Resources
DEFAULT_CPU_LIMIT=2
DEFAULT_MEM_LIMIT=4G
CANGJIE_CPU_LIMIT=2
CANGJIE_MEM_LIMIT=4G

# Timezone
TZ=Asia/Shanghai

# Code Server Password
CODE_SERVER_PASSWORD=your_secure_password
```

### SSH Key Forwarding

To use your host's SSH keys in the container:

```bash
# Linux/macOS
export SSH_AUTH_SOCK=$SSH_AUTH_SOCK
docker compose up -d

# Windows (PowerShell)
$env:SSH_AUTH_SOCK = (Get-Process ssh-agent | Select-Object -First 1).MainModule.FileName
docker compose up -d
```

## Project Structure

```
dgen/
├── .devcontainer/           # Dev Container configurations
│   ├── devcontainer.json   # Default environment config
│   └── devcontainer-cangjie.json  # Cangjie environment config
├── .github/
│   └── workflows/          # CI/CD pipelines
│       └── build-images.yml
├── cangjie/                # Cangjie language container
│   ├── Dockerfile
│   ├── docker-compose.yaml
│   ├── files/              # Config files
│   └── scripts/            # Installation scripts
├── default/                # Default development container
│   ├── Dockerfile
│   ├── docker-compose.yaml
│   └── files/              # Config files
├── docker-compose.yaml     # Root compose file
├── .dockerignore
└── README.md
```

## Container Ports

| Service | Internal Port | Default External Port |
|---------|--------------|---------------------|
| Code Server (default) | 8080 | 30080 |
| SSH (default) | 2222 | 30022 |
| Code Server (cangjie) | 8080 | 30180 |
| SSH (cangjie) | 2222 | 30122 |

## Pre-installed Tools

### Default Image

| Category | Tools |
|----------|-------|
| Shell | Fish, Bash, Zsh |
| Editor | Neovim, Nano, Vim |
| Git Tools | Git, LazyGit, Git Delta |
| CLI Utilities | fzf, ripgrep, fd, bat, jq, zoxide |
| System | htop, btop, tree, ncdu |
| Code Server | v4.115.0 |

### Cangjie Image

Includes everything in **Default**, plus:

| Category | Tools |
|----------|-------|
| Language SDK | Cangjie SDK 1.1.0-beta.25 |
| Standard Library | Cangjie stdx |
| Package Manager | uv + Python 3.11 |

## GitHub Actions

Automated builds run daily at 22:00 (Beijing time) with:

- Multi-architecture builds (amd64, arm64)
- Layer caching for faster builds
- OCI annotations for rich metadata
- SBOM and provenance attestations

### Manual Trigger

1. Go to repository **Actions** tab
2. Select **"Build and Push Docker Images"**
3. Click **"Run workflow"**
4. Optional: Specify custom tag or build default only

## Security Notes

⚠️ **Important**:

1. **Change default passwords** in production
2. **Use SSH keys** instead of passwords when possible
3. **Limit resource usage** via `docker-compose.yml`
4. **Keep images updated** by rebuilding regularly

## Troubleshooting

### Container won't start

```bash
# Check logs
docker compose logs default-develop

# Rebuild without cache
docker compose build --no-cache default-develop
```

### SSH connection fails

```bash
# Regenerate SSH keys in container
docker exec -it dgen-default-dev ssh-keygen -A
docker restart dgen-default-dev
```

### Code Server shows blank page

```bash
# Clear extensions cache
docker exec -it dgen-default-dev rm -rf ~/.cache/code-server
docker restart dgen-default-dev
```

## Contributing

Contributions welcome! Please read our contributing guidelines before submitting PRs.

## License

MIT License - see [LICENSE.md](LICENSE.md)