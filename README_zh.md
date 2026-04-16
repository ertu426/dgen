# DGen — 开发容器

[English](README.md) | 中文

> 基于 **Debian 13 (Trixie)** 的生产级 Docker 开发容器，预装 Code Server、Fish Shell、SSH 和多架构支持。支持通过浏览器、SSH 或 VS Code Dev Containers 进行日常开发。

---

## 可用镜像

| 镜像 | 基础镜像 | 说明 |
|------|---------|------|
| [`default`][ghcr-default] | `debian:trixie-slim` | 通用开发环境，内含 Code Server、Fish 和现代化 CLI 工具 |
| [`cangjie`][ghcr-cangjie] | `default` | [仓颉语言][cangjie-lang] SDK + stdx + uv / Python 3.11 |
| [`vite`][ghcr-vite] | `default` | Node.js / Vite / Nuxt 前端开发环境 |

[ghcr-default]: https://ghcr.io/ertu426/default
[ghcr-cangjie]: https://ghcr.io/ertu426/cangjie
[ghcr-vite]: https://ghcr.io/ertu426/vite
[cangjie-lang]: https://cangjie-lang.cn

---

## 快速开始

### 前置要求

- Docker 24+ 或 Docker Desktop
- Docker Compose v2.0+
- _（可选）_ VS Code + [Dev Containers 扩展][devcontainers-ext]

[devcontainers-ext]: https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers

### 拉取镜像

```bash
# 从 GHCR 拉取预构建镜像
docker pull ghcr.io/ertu426/default:latest
docker pull ghcr.io/ertu426/cangjie:latest
docker pull ghcr.io/ertu426/vite:latest
```

### 使用 Docker Compose 运行

```bash
# 克隆仓库
git clone https://github.com/ertu426/dgen.git
cd dgen

# 复制环境变量模板
cp .env.example .env
# 编辑 .env，设置密码、端口等

# 启动容器
docker compose up -d

# 查看日志
docker compose logs -f

# 停止
docker compose down
```

---

## 访问方式

### 1. 浏览器 — Code Server

| 容器 | 地址 | 默认密码 |
|------|------|---------|
| default   | http://localhost:30080 | `dev123456` |
| cangjie   | http://localhost:30180 | `dev123456` |
| vite      | http://localhost:30280 | `dev123456` |

> ⚠️ 对外暴露服务前，请通过 `.env` 中的 `CODE_SERVER_PASSWORD` 修改密码。

### 2. SSH 连接

```bash
# 连接 default 容器
ssh -p 30022 dev@localhost

# 连接 cangjie 容器
ssh -p 30122 dev@localhost

# 连接 vite 容器
ssh -p 30222 dev@localhost
```

默认使用**密码认证**。如需密钥认证，可通过 volume 挂载或在运行时复制 `authorized_keys`。

### 3. VS Code Dev Containers

1. 在 VS Code 中打开项目文件夹
2. 按 `F1` → **Dev Containers: Open Folder in Container**
3. 选择配置文件：
   - `.devcontainer/devcontainer.json` — 默认开发环境
   - `.devcontainer/devcontainer-cangjie.json` — 仓颉开发环境
   - `.devcontainer/devcontainer-vite.json` — Vite / Nuxt 开发环境

---

## 配置

### `.env` 参数说明

```env
# ── 镜像与注册表 ──────────────────────────────────────────
VERSION=latest
PULL_POLICY=if-not-present
GITHUB_ORG=ertu426

# ── 端口 ──────────────────────────────────────────────────
DEFAULT_HTTP_PORT=30080
DEFAULT_SSH_PORT=30022
CANGJIE_HTTP_PORT=30180
CANGJIE_SSH_PORT=30122
VITE_HTTP_PORT=30280
VITE_SSH_PORT=30222

# ── 资源限制 ───────────────────────────────────────────────
DEFAULT_CPU_LIMIT=2
DEFAULT_MEM_LIMIT=4G
CANGJIE_CPU_LIMIT=2
CANGJIE_MEM_LIMIT=4G
VITE_CPU_LIMIT=2
VITE_MEM_LIMIT=4G

# ── 时区与语言 ─────────────────────────────────────────────
TZ=Asia/Shanghai

# ── Code Server ───────────────────────────────────────────
CODE_SERVER_PASSWORD=your_secure_password   # ← 请修改此处！
```

从模板开始：

```bash
cp .env.example .env
```

### SSH 密钥转发

宿主机 SSH 密钥已通过 `docker-compose.yaml` 以只读方式挂载：

```yaml
volumes:
  - ~/.ssh:/home/dev/.ssh:ro
```

如需 SSH Agent 转发，启动前设置 `SSH_AUTH_SOCK`：

```bash
# Linux / macOS
echo "SSH_AUTH_SOCK=$SSH_AUTH_SOCK" >> .env
docker compose up -d

# Windows (PowerShell — 需启动 OpenSSH Agent 服务)
$env:SSH_AUTH_SOCK = "\\.\pipe\openssh-ssh-agent"
docker compose up -d
```

---

## 预装工具

### `default` 镜像

| 类别 | 工具 |
|------|------|
| **Shell** | Fish 3、Bash、Starship 提示符 |
| **编辑器** | Neovim、Nano |
| **Code Server** | v4.115.0（支持中文界面） |
| **Git** | Git、git-delta（并排 diff） |
| **CLI 工具** | bat、eza、fzf、ripgrep、zoxide、btop |
| **压缩工具** | zip、unzip |
| **构建工具** | build-essential、pkg-config |
| **网络工具** | curl、wget、openssh-client/server |
| **语言环境** | `zh_CN.UTF-8` + `en_US.UTF-8` |

### `cangjie` 镜像

包含 **default** 的全部工具，额外新增：

| 类别 | 工具 |
|------|------|
| **仓颉 SDK** | 1.1.0-beta.25（x86_64 & aarch64） |
| **仓颉 stdx** | 1.1.0-beta.25.1 |
| **VS Code 扩展** | 仓颉官方扩展（预置于 workspace） |
| **Python** | uv + Python 3.11 |
| **构建依赖** | binutils、libc-dev、libc++-dev、libgcc-14-dev |

### `vite` 镜像

包含 **default** 的全部工具，额外新增：

| 类别 | 工具 |
|------|------|
| **Node.js** | 通过 vite.plus 引导安装 |
| **前端工具** | Vite、Nuxt 相关工具链 |

---

## 项目结构

```
dgen/
├── .devcontainer/
│   ├── devcontainer.json            # default Dev Containers 配置
│   ├── devcontainer-cangjie.json   # 仓颉 Dev Containers 配置
│   └── devcontainer-vite.json      # Vite / Nuxt Dev Containers 配置
├── .github/
│   └── workflows/
│       └── build-images.yml        # CI：矩阵构建（amd64 + arm64）
├── cangjie/
│   ├── Dockerfile                  # FROM ghcr.io/ertu426/default → +仓颉 SDK + uv
│   ├── docker-compose.yaml
│   └── scripts/                    # SDK 安装辅助脚本
├── default/
│   ├── Dockerfile                  # FROM debian:trixie-slim
│   ├── docker-compose.yaml
│   └── files/
│       ├── config.fish             # Fish Shell 配置与别名
│       ├── config.yaml             # Code Server 配置
│       ├── starship.toml           # Starship 主题
│       └── start.sh                # 容器入口脚本
├── vite/
│   ├── Dockerfile                  # FROM ghcr.io/ertu426/default → +Node.js + Vite
│   └── docker-compose.yaml
├── .dockerignore
├── .env.example                    # 环境变量模板
├── docker-compose.yaml             # 根目录 Compose（default + cangjie + vite）
└── README.md
```

---

## 端口说明

| 容器 | 服务 | 内部端口 | 外部端口（默认） |
|------|------|---------|----------------|
| default | Code Server | 8080 | `DEFAULT_HTTP_PORT` = 30080 |
| default | SSH | 2222 | `DEFAULT_SSH_PORT` = 30022 |
| cangjie | Code Server | 8080 | `CANGJIE_HTTP_PORT` = 30180 |
| cangjie | SSH | 2222 | `CANGJIE_SSH_PORT` = 30122 |
| vite | Code Server | 8080 | `VITE_HTTP_PORT` = 30280 |
| vite | SSH | 2222 | `VITE_SSH_PORT` = 30222 |

---

## CI / CD

自动构建在每天**北京时间 22:00** 及每次推送到 `main` 分支时触发。

**流水线流程：**

```
push / schedule / workflow_dispatch
        │
  [build-base]       构建 default（amd64 + arm64）
        │
  [build-images]     矩阵并发：cangjie · vite（amd64 + arm64）
        │
  [summary]          汇总构建状态（全部 3 个镜像）
```

**特性：**
- 矩阵策略 — 新增镜像只需在 `include` 中添加一行
- GHCR 注册表缓存（`mode=max`）— 跨 runner 共享，重跑复用
- `docker/metadata-action` — 自动生成标签和标注
- OCI 出处证明 + SBOM 软件物料清单
- 手动触发支持自定义标签及选择性构建（`all | default | downstream`）

---

## 故障排查

### 容器无法启动

```bash
docker compose logs default-develop
docker compose build --no-cache default-develop
```

### 8080 端口无响应

```bash
# 检查容器内 Code Server 是否运行
docker exec dgen-default-dev ps aux | grep code-server
```

### SSH 连接被拒绝

```bash
# 重新生成 SSH 主机密钥并重启
docker exec dgen-default-dev ssh-keygen -A
docker restart dgen-default-dev
```

### 家目录文件属于 root

Docker 在容器启动前以 root 身份创建 bind-mount 目录会导致此问题。  
入口脚本（`start.sh`）每次启动时会自动执行 `chown` 修复权限。  
若问题持续，可手动执行：

```bash
docker exec -u root dgen-default-dev chown -R dev:dev /home/dev
```

### Code Server 显示空白页

```bash
docker exec dgen-default-dev rm -rf /home/dev/.cache/code-server
docker restart dgen-default-dev
```

---

## 安全注意

- **修改默认密码**（`dev123456`），任何对外暴露前必须执行
- SSH 主机密钥在**运行时**生成，不写入镜像
- 宿主机 SSH 密钥以**只读方式**挂载（`~/.ssh:/home/dev/.ssh:ro`）
- `dev` 用户拥有无密码 `sudo` 权限 — 仅适用于开发环境，**不适合生产**

---

## 许可证

MIT — 参见 [LICENSE.md](LICENSE.md)
