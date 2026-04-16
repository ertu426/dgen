# DGen — Development Containers

English | [中文](README_zh.md)

> Production-ready Docker development containers based on **Debian 13 (Trixie)**, with Code Server, Fish Shell, SSH, and multi-arch support. Built for daily development via browser, SSH, or VS Code Dev Containers.

---

## Available Images

| Image | Based On | Description |
|-------|----------|-------------|
| [`default`][ghcr-default] | `debian:trixie-slim` | Universal dev environment with Code Server, Fish, and modern CLI tools |
| [`cangjie`][ghcr-cangjie] | `default` | [Cangjie language][cangjie-lang] SDK + stdx + uv / Python 3.11 |
| [`vite`][ghcr-vite] | `default` | Node.js / Vite / Nuxt frontend environment |

[ghcr-default]: https://ghcr.io/ertu426/default
[ghcr-cangjie]: https://ghcr.io/ertu426/cangjie
[ghcr-vite]: https://ghcr.io/ertu426/vite
[cangjie-lang]: https://cangjie-lang.cn

---

## Quick Start

### Prerequisites

- Docker 24+ or Docker Desktop
- Docker Compose v2.0+
- _(Optional)_ VS Code + [Dev Containers extension][devcontainers-ext]

[devcontainers-ext]: https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers

### Pull & Run

```bash
# Pull pre-built images from GHCR
docker pull ghcr.io/ertu426/default:latest
docker pull ghcr.io/ertu426/cangjie:latest
docker pull ghcr.io/ertu426/vite:latest
```

### Run with Docker Compose

```bash
# Clone the repository
git clone https://github.com/ertu426/dgen.git
cd dgen

# Copy environment template
cp .env.example .env
# Edit .env to set your password, ports, etc.

# Start containers
docker compose up -d

# View logs
docker compose logs -f

# Stop
docker compose down
```

---

## Access Methods

### 1. Browser — Code Server

| Container | URL | Default Password |
|-----------|-----|-----------------|
| default   | http://localhost:30080 | `dev123456` |
| cangjie   | http://localhost:30180 | `dev123456` |

> ⚠️ Change the password via `CODE_SERVER_PASSWORD` in `.env` before exposing to a network.

### 2. SSH

```bash
# Default container
ssh -p 30022 dev@localhost

# Cangjie container
ssh -p 30122 dev@localhost
```

SSH uses **password authentication** by default.  
To use key auth, mount your `authorized_keys` via the volume or copy it in at runtime.

### 3. VS Code Dev Containers

1. Open the project folder in VS Code
2. Press `F1` → **Dev Containers: Open Folder in Container**
3. Pick a config:
   - `.devcontainer/devcontainer.json` — default environment
   - `.devcontainer/devcontainer-cangjie.json` — Cangjie environment
   - `.devcontainer/devcontainer-vite.json` — Vite / Nuxt environment

---

## Configuration

### `.env` Reference

```env
# ── Image & Registry ──────────────────────────────────────
VERSION=latest
PULL_POLICY=if-not-present
GITHUB_ORG=ertu426

# ── Ports ─────────────────────────────────────────────────
DEFAULT_HTTP_PORT=30080
DEFAULT_SSH_PORT=30022
CANGJIE_HTTP_PORT=30180
CANGJIE_SSH_PORT=30122
VITE_HTTP_PORT=30280
VITE_SSH_PORT=30222

# ── Resources ─────────────────────────────────────────────
DEFAULT_CPU_LIMIT=2
DEFAULT_MEM_LIMIT=4G
CANGJIE_CPU_LIMIT=2
CANGJIE_MEM_LIMIT=4G
VITE_CPU_LIMIT=2
VITE_MEM_LIMIT=4G

# ── Timezone & Locale ─────────────────────────────────────
TZ=Asia/Shanghai

# ── Code Server ───────────────────────────────────────────
CODE_SERVER_PASSWORD=your_secure_password   # ← change this!
```

Copy `.env.example` as a starting point:

```bash
cp .env.example .env
```

### SSH Key Forwarding

Mount your host SSH keys (read-only) into the container — already configured in `docker-compose.yaml`:

```yaml
volumes:
  - ~/.ssh:/home/dev/.ssh:ro
```

For SSH agent forwarding, set `SSH_AUTH_SOCK` before starting:

```bash
# Linux / macOS
echo "SSH_AUTH_SOCK=$SSH_AUTH_SOCK" >> .env
docker compose up -d

# Windows (PowerShell — with OpenSSH agent running)
$env:SSH_AUTH_SOCK = "\\.\pipe\openssh-ssh-agent"
docker compose up -d
```

---

## Pre-installed Tools

### `default` Image

| Category | Tools |
|----------|-------|
| **Shell** | Fish 3, Bash, Starship prompt |
| **Editors** | Neovim, Nano |
| **Code Server** | v4.115.0 (with Chinese UI) |
| **Git** | Git, git-delta (side-by-side diff) |
| **CLI** | bat, eza, fzf, ripgrep, zoxide, btop |
| **Archives** | zip, unzip |
| **Build** | build-essential, pkg-config |
| **Network** | curl, wget, openssh-client/server |
| **Locale** | `zh_CN.UTF-8` + `en_US.UTF-8` |

### `cangjie` Image

Everything in **default**, plus:

| Category | Tools |
|----------|-------|
| **Cangjie SDK** | 1.1.0-beta.25 (x86_64 & aarch64) |
| **Cangjie stdx** | 1.1.0-beta.25.1 |
| **Cangjie VS Code ext** | Bundled in workspace |
| **Python** | uv + Python 3.11 |
| **Build libs** | binutils, libc-dev, libc++-dev, libgcc-14-dev |

### `vite` Image

Everything in **default**, plus:

| Category | Tools |
|----------|-------|
| **Node.js** | via vite.plus bootstrap |
| **Frontend** | Vite, Nuxt tooling |

---

## Project Structure

```
dgen/
├── .devcontainer/
│   ├── devcontainer.json            # default Dev Containers config
│   ├── devcontainer-cangjie.json   # Cangjie Dev Containers config
│   └── devcontainer-vite.json      # Vite / Nuxt Dev Containers config
├── .github/
│   └── workflows/
│       └── build-images.yml        # CI: matrix build (amd64 + arm64)
├── cangjie/
│   ├── Dockerfile                  # FROM ghcr.io/ertu426/default → +Cangjie SDK + uv
│   ├── docker-compose.yaml
│   └── scripts/                    # SDK installation helpers
├── default/
│   ├── Dockerfile                  # FROM debian:trixie-slim
│   ├── docker-compose.yaml
│   └── files/
│       ├── config.fish             # Fish shell config + aliases
│       ├── config.yaml             # Code Server config
│       ├── starship.toml           # Starship prompt theme
│       └── start.sh                # Container entrypoint
├── vite/
│   ├── Dockerfile                  # FROM ghcr.io/ertu426/default → +Node.js + Vite
│   └── docker-compose.yaml
├── .dockerignore
├── .env.example                    # Environment variable template
├── docker-compose.yaml             # Root compose (default + cangjie + vite)
└── README.md
```

---

## Port Reference

| Container | Service | Internal | External (default) |
|-----------|---------|----------|--------------------|
| default   | Code Server | 8080 | `DEFAULT_HTTP_PORT` = 30080 |
| default   | SSH | 2222 | `DEFAULT_SSH_PORT` = 30022 |
| cangjie   | Code Server | 8080 | `CANGJIE_HTTP_PORT` = 30180 |
| cangjie   | SSH | 2222 | `CANGJIE_SSH_PORT` = 30122 |
| vite      | Code Server | 8080 | `VITE_HTTP_PORT` = 30280 |
| vite      | SSH | 2222 | `VITE_SSH_PORT` = 30222 |

---

## CI / CD

Automated builds run daily at **22:00 CST** and on every push to `main`.

**Pipeline flow:**

```
push / schedule / workflow_dispatch
        │
  [build-base]       build default  (amd64 + arm64)
        │
  [build-images]     matrix: cangjie · vite  (concurrent, amd64 + arm64)
        │
  [summary]          report build status (all 3 images)
```

**Features:**
- Matrix strategy — adding a new image only requires one `include` entry
- GHCR registry cache (`mode=max`) — shared across runners, survives re-runs
- `docker/metadata-action` — automatic tag + label generation
- OCI provenance + SBOM attestations
- Manual trigger with custom tag / selective build (`all | default | downstream`)

---

## Troubleshooting

### Container won't start

```bash
docker compose logs default-develop
docker compose build --no-cache default-develop
```

### 8080 not responding

```bash
# Check if Code Server is running inside the container
docker exec dgen-default-dev ps aux | grep code-server
docker exec dgen-default-dev cat /proc/1/fd/1   # stdout logs
```

### SSH connection refused

```bash
# Regenerate SSH host keys and restart
docker exec dgen-default-dev ssh-keygen -A
docker restart dgen-default-dev
```

### Home directory owned by root

This can happen when Docker creates bind-mount directories as root before the container starts.  
The entrypoint (`start.sh`) automatically runs `chown` to fix ownership on each boot.  
If it persists, run manually:

```bash
docker exec -u root dgen-default-dev chown -R dev:dev /home/dev
```

### Code Server blank page

```bash
docker exec dgen-default-dev rm -rf /home/dev/.cache/code-server
docker restart dgen-default-dev
```

---

## Security Notes

- **Change the default password** (`dev123456`) before exposing containers to any network
- SSH host keys are generated **at runtime** — not baked into the image
- Host SSH keys are mounted **read-only** (`~/.ssh:/home/dev/.ssh:ro`)
- `dev` user has passwordless `sudo` — suitable for development, **not for production**

---

## License

MIT — see [LICENSE.md](LICENSE.md)
