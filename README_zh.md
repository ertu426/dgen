# DGen Development Containers

[English](README.md) | 中文

# 中文

## 概述

DGen 提供生产级别的 Docker 开发容器，针对现代化软件开发工作流进行了优化。

### 特性

- 🚀 **多架构支持**: 同时构建 `amd64` (x86_64) 和 `arm64` (aarch64) 架构
- 🐚 **现代化 Shell 体验**: Fish Shell + Starship 提示符 + 智能别名
- 💻 **VS Code 集成**: 预配置 Code Server，支持扩展和中文界面
- 🔐 **安全 SSH 访问**: 密钥认证，支持密钥转发
- 🌍 **国际化**: 完整的中英文语言支持
- 🔧 **Dev Containers 就绪**: 完全兼容 VS Code Remote - Containers

### 可用镜像

| 镜像 | 描述 | 基础系统 |
|------|------|---------|
| `default` | 通用开发环境，预装 Code Server | Debian 13 (Trixie) |
| `cangjie` | 仓颉编程语言开发环境 | Debian 13 (Trixie) |

## 快速开始

### 前置要求

- Docker 20.10+ 或 Docker Desktop
- Docker Compose v2.0+
- （可选）VS Code + Dev Containers 扩展

### 使用 Docker Compose

```bash
# 克隆仓库
git clone https://github.com/ertu426/dgen.git
cd dgen

# 构建并启动所有容器
docker compose up -d --build

# 查看日志
docker compose logs -f

# 停止容器
docker compose down
```

### 使用 VS Code Dev Containers

1. 安装 [Dev Containers 扩展](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. 在 VS Code 中打开项目
3. 按 `F1` 选择 **"Dev Containers: Open Folder in Container"**
4. 选择 `.devcontainer/devcontainer.json` 使用默认环境
5. 或选择 `.devcontainer/devcontainer-cangjie.json` 使用仓颉环境

### SSH 连接

```bash
# SSH 连接（密码：dev123456）
ssh -p 30022 dev@localhost

# 带密钥转发
ssh -p 30022 -A dev@localhost
```

### 访问 Code Server

1. 浏览器打开: http://localhost:30080
2. 默认密码: `dev123456`
3. 可在 `files/config.yaml` 中修改密码

## 配置

### 环境变量

创建 `.env` 文件来自定义设置：

```env
# 版本
VERSION=latest

# GitHub 组织（用于 GHCR）
GITHUB_ORG=ertu426

# 拉取策略
PULL_POLICY=if-not-present

# 端口
DEFAULT_HTTP_PORT=30080
DEFAULT_SSH_PORT=30022
CANGJIE_HTTP_PORT=30180
CANGJIE_SSH_PORT=30122

# 资源限制
DEFAULT_CPU_LIMIT=2
DEFAULT_MEM_LIMIT=4G
CANGJIE_CPU_LIMIT=2
CANGJIE_MEM_LIMIT=4G

# 时区
TZ=Asia/Shanghai

# Code Server 密码
CODE_SERVER_PASSWORD=your_secure_password
```

### SSH 密钥转发

在容器中使用宿主机的 SSH 密钥：

```bash
# Linux/macOS
export SSH_AUTH_SOCK=$SSH_AUTH_SOCK
docker compose up -d

# Windows (PowerShell)
$env:SSH_AUTH_SOCK = (Get-Process ssh-agent | Select-Object -First 1).MainModule.FileName
docker compose up -d
```

## 项目结构

```
dgen/
├── .devcontainer/           # Dev Container 配置
│   ├── devcontainer.json   # 默认环境配置
│   └── devcontainer-cangjie.json  # 仓颉环境配置
├── .github/
│   └── workflows/          # CI/CD 流水线
│       └── build-images.yml
├── cangjie/                # 仓颉语言容器
│   ├── Dockerfile
│   ├── docker-compose.yaml
│   ├── files/              # 配置文件
│   └── scripts/            # 安装脚本
├── default/                # 默认开发容器
│   ├── Dockerfile
│   ├── docker-compose.yaml
│   └── files/              # 配置文件
├── docker-compose.yaml     # 根目录 compose 文件
├── .dockerignore
└── README.md
```

## 容器端口

| 服务 | 内部端口 | 默认外部端口 |
|------|---------|------------|
| Code Server (默认) | 8080 | 30080 |
| SSH (默认) | 2222 | 30022 |
| Code Server (仓颉) | 8080 | 30180 |
| SSH (仓颉) | 2222 | 30122 |

## 预装工具

### 默认镜像

| 类别 | 工具 |
|------|------|
| Shell | Fish, Bash, Zsh |
| 编辑器 | Neovim, Nano, Vim |
| Git 工具 | Git, LazyGit, Git Delta |
| CLI 工具 | fzf, ripgrep, fd, bat, jq, zoxide |
| 系统 | htop, btop, tree, ncdu |
| Code Server | v4.115.0 |

### 仓颉镜像

包含**默认镜像**的所有工具，并额外安装：

| 类别 | 工具 |
|------|------|
| 语言 SDK | 仓颉 SDK 1.1.0-beta.25 |
| 标准库 | 仓颉 stdx |
| 包管理器 | uv + Python 3.11 |

## GitHub Actions

自动化构建每天北京时间 22:00 执行，包含：

- 多架构构建 (amd64, arm64)
- 层缓存加速构建
- OCI 注解丰富元数据
- SBOM 和出处证明

### 手动触发

1. 进入仓库 **Actions** 标签页
2. 选择 **"Build and Push Docker Images"**
3. 点击 **"Run workflow"**
4. 可选：指定自定义标签或仅构建默认镜像

## 安全注意

⚠️ **重要**:

1. **生产环境请修改默认密码**
2. **尽量使用 SSH 密钥认证**
3. **通过 docker-compose.yml 限制资源使用**
4. **定期重新构建以获取更新**

## 故障排除

### 容器无法启动

```bash
# 查看日志
docker compose logs default-develop

# 无缓存重建
docker compose build --no-cache default-develop
```

### SSH 连接失败

```bash
# 在容器内重新生成 SSH 密钥
docker exec -it dgen-default-dev ssh-keygen -A
docker restart dgen-default-dev
```

### Code Server 显示空白页

```bash
# 清除扩展缓存
docker exec -it dgen-default-dev rm -rf ~/.cache/code-server
docker restart dgen-default-dev
```

## 贡献

欢迎贡献！提交 PR 前请阅读贡献指南。

## 许可证

MIT 许可证 - 参见 [LICENSE.md](LICENSE.md)