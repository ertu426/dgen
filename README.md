# DGen — Development Containers

English | [中文](README_zh.md)

[![Build Images](https://github.com/ertu426/dgen/actions/workflows/build-images.yml/badge.svg)](https://github.com/ertu426/dgen/actions/workflows/build-images.yml)
[![Test & PR](https://github.com/ertu426/dgen/actions/workflows/test-and-pr.yml/badge.svg)](https://github.com/ertu426/dgen/actions/workflows/test-and-pr.yml)

> Production-ready Docker development containers based on **Debian 13 (Trixie)** with multi-arch support (amd64/arm64).

---

## Available Images

### Image Matrix

| Image | Tags | Description |
|-------|------|-------------|
| **default** | `base`, `ide`, `ssh`, `ide-ssh` | Universal dev environment |
| **cangjie** | `base`, `ide`, `ssh`, `ide-ssh`, `builder` | [Cangjie language][cangjie-lang] development |
| **vite** | `base`, `ide`, `ssh`, `ide-ssh` | Node.js / Vite / Nuxt frontend |

[ghcr-default]: https://ghcr.io/ertu426/default
[ghcr-cangjie]: https://ghcr.io/ertu426/cangjie
[ghcr-vite]: https://ghcr.io/ertu426/vite
[cangjie-lang]: https://cangjie-lang.cn

### Tag Variants

| Tag | Features | Use Case |
|-----|----------|----------|
| `base` | Minimal environment | Container-only development |
| `ide` | + Code Server | Browser-based IDE |
| `ssh` | + SSH server | Remote SSH development |
| `ide-ssh` | + Code Server + SSH | Both access methods |
| `builder` (cangjie only) | Build-only environment | CI/CD pipelines |

---

## Quick Start

### Prerequisites

- Docker 24+ or Docker Desktop
- Docker Compose v2.0+

### Pull Images

```bash
# Pull all default variants
docker pull ghcr.io/ertu426/default:base
docker pull ghcr.io/ertu426/default:ide
docker pull ghcr.io/ertu426/default:ssh
docker pull ghcr.io/ertu426/default:ide-ssh

# Pull cangjie variants
docker pull ghcr.io/ertu426/cangjie:latest
docker pull ghcr.io/ertu426/cangjie:builder

# Pull vite variants
docker pull ghcr.io/ertu426/vite:latest
```

---

## Development Methods

### 1. Container Development (`base` tag)

Run commands directly in the container:

```bash
# Run default base image
docker run -it --rm ghcr.io/ertu426/default:base

# Run cangjie base with project mounted
docker run -it --rm -v $(pwd):/home/dev/workspace ghcr.io/ertu426/cangjie:base

# Run vite base
docker run -it --rm -v $(pwd):/home/dev/workspace ghcr.io/ertu426/vite:base
```

**Features included:**
- Fish shell with Starship prompt
- Neovim editor
- Git + git-delta
- Modern CLI tools (bat, eza, zoxide, btop)

#### Using code-server (`ide` tag)

```bash
# Start code-server for default image
docker run -d -p 8080:8080 --name dev-ide ghcr.io/ertu426/default:ide

# Start code-server for cangjie image
docker run -d -p 8081:8080 --name cangjie-ide ghcr.io/ertu426/cangjie:ide

# Start code-server for vite image
docker run -d -p 8082:8080 --name vite-ide ghcr.io/ertu426/vite:ide

# Access in browser: http://localhost:8080 (default), 8081 (cangjie), 8082 (vite)
```

#### Using SSH (`ssh` tag)

```bash
# Start SSH for default image
docker run -d -p 2222:2222 --name dev-ssh ghcr.io/ertu426/default:ssh

# Start SSH for cangjie image
docker run -d -p 2223:2222 --name cangjie-ssh ghcr.io/ertu426/cangjie:ssh

# Start SSH for vite image
docker run -d -p 2224:2222 --name vite-ssh ghcr.io/ertu426/vite:ssh

# Connect via SSH
ssh -p 2222 dev@localhost  # default
ssh -p 2223 dev@localhost  # cangjie
ssh -p 2224 dev@localhost  # vite
# Password: dev
```

#### Using Container Development

```bash
# Container-only for default
docker run -it --rm ghcr.io/ertu426/default:base

# Container-only for cangjie
docker run -it --rm ghcr.io/ertu426/cangjie:base

# Container-only for vite
docker run -it --rm ghcr.io/ertu426/vite:base
```

### 2. SSH Development (`ssh` tag)

Develop remotely via SSH:

```bash
# Start SSH container
docker run -d -p 2222:2222 --name dev-ssh ghcr.io/ertu426/default:ssh

# Connect via SSH
ssh -p 2222 dev@localhost
# Password: dev

# With project mounted
docker run -d -p 2222:2222 -v $(pwd):/home/dev/workspace ghcr.io/ertu426/default:ssh

# VS Code Remote SSH
# Add to ~/.ssh/config:
# Host dev-container
#   HostName localhost
#   Port 2222
#   User dev
```

**SSH Configuration:**
- Port: 2222
- Default user: `dev`
- Default password: `dev`
- Passwordless sudo enabled

### 3. Code Server Development (`ide` tag)

Develop in browser-based VS Code:

```bash
# Start Code Server container
docker run -d -p 8080:8080 --name dev-ide ghcr.io/ertu426/default:ide

# Access in browser
open http://localhost:8080

# With project mounted and password
docker run -d \
  -p 8080:8080 \
  -v $(pwd):/home/dev/workspace \
  ghcr.io/ertu426/default:ide
```

**Code Server Features:**
- Port: 8080
- Authentication: disabled by default
- Chinese UI support
- Pre-configured settings

### 4. Combined: Code Server + SSH (`ide-ssh` tag)

Both access methods in one container:

```bash
# Start container with both services
docker run -d \
  -p 8080:8080 \
  -p 2222:2222 \
  -v $(pwd):/home/dev/workspace \
  --name dev-full \
  ghcr.io/ertu426/default:ide-ssh

# Access via browser: http://localhost:8080
# Access via SSH: ssh -p 2222 dev@localhost
```

---

## Project Structure

```
dgen/
├── default/
│   ├── base/          # Minimal base environment
│   ├── ide/           # + Code Server
│   ├── ssh/           # + SSH server
│   └── ide-ssh/       # + Code Server + SSH
├── cangjie/
│   ├── base/          # Cangjie SDK + uv
│   ├── ide/           # + Code Server
│   ├── ssh/           # + SSH
│   ├── ide-ssh/       # + Code Server + SSH
│   └── builder/       # Build-only environment
├── vite/
│   ├── base/          # Node.js + Vite
│   ├── ide/           # + Code Server
│   ├── ssh/           # + SSH
│   └── ide-ssh/       # + Code Server + SSH
├── .github/workflows/
│   ├── build-images.yml    # Multi-arch build pipeline
│   └── test-and-pr.yml     # Test and auto PR
└── README.md
```

---

## Pre-installed Tools

### Core Tools (all images)

| Category | Tools |
|----------|-------|
| Shell | Fish 3, Bash, Starship |
| Editors | Neovim, Nano |
| Git | Git, git-delta |
| CLI | bat, eza, fzf, ripgrep, zoxide, btop |
| Network | curl, wget |
| Locale | `zh_CN.UTF-8`, `en_US.UTF-8` |

### cangjie Image Additions

| Category | Tools |
|----------|-------|
| Cangjie | SDK 1.1.0, stdx 1.1.0 |
| Python | uv + Python 3.11 |
| Build | binutils, libc-dev, libc++-dev |

### vite Image Additions

| Category | Tools |
|----------|-------|
| Node.js | via vite.plus |
| Frontend | Vite, Nuxt tooling |

---

## CI / CD

### Build Pipeline

Automated builds run:
- On push to `main` branch
- On push to `develop` branch (test + auto PR)
- Daily at 22:00 CST

### Pipeline Flow

```
build-default-base → build-default-others (ide/ssh/ide-ssh)
                  → build-cangjie (base/ide/ssh/ide-ssh/builder)
                  → build-vite (base/ide/ssh/ide-ssh)
```

---

## Security Notes

- Default password `dev` should be changed for production use
- SSH host keys generated at runtime (not baked into image)
- `dev` user has passwordless sudo (development only)
- Code Server auth is disabled by default

---

## License

MIT — see [LICENSE.md](LICENSE.md)