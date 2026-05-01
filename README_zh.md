# DGen — 开发容器

[English](README.md) | 中文

[![Build Images](https://github.com/ertu426/dgen/actions/workflows/build-images.yml/badge.svg)](https://github.com/ertu426/dgen/actions/workflows/build-images.yml)

> 基于 **Debian 13 (Trixie)** 的生产级 Docker 开发容器，支持多架构（amd64/arm64）。

---

## 可用镜像

### 镜像矩阵

```
ghcr.io/ertu426/default
├── base
├── ide
└── ssh

ghcr.io/ertu426/cangjie
├── base
├── ide
├── ssh
└── builder

ghcr.io/ertu426/vite
├── base
├── ide
└── ssh
```

| 镜像 | 说明 |
|------|------|
| **default** | 通用开发环境（Debian 13 + Fish + Neovim + CLI 工具） |
| **cangjie** | [仓颉语言][cangjie-lang]开发环境（SDK 1.1.0 + stdx 1.1.0） |
| **vite** | Node.js / Vite / Nuxt 前端开发环境 |

[ghcr-default]: https://ghcr.io/ertu426/default
[ghcr-cangjie]: https://ghcr.io/ertu426/cangjie
[ghcr-vite]: https://ghcr.io/ertu426/vite
[cangjie-lang]: https://cangjie-lang.cn

### 标签变体

| 标签 | 特性 | 使用场景 |
|------|------|----------|
| `base` | 最小化环境 | 纯容器开发 |
| `ide` | + Code Server | 浏览器 IDE |
| `ssh` | + SSH 服务 | 远程 SSH 开发 |
| `builder`（仅 cangjie） | 仅构建环境 | CI/CD 流水线 |

---

## 快速开始

### 前置要求

- Docker 24+ 或 Docker Desktop
- Docker Compose v2.0+

### 拉取镜像

```bash
# 拉取 default 所有变体
docker pull ghcr.io/ertu426/default:base
docker pull ghcr.io/ertu426/default:ide
docker pull ghcr.io/ertu426/default:ssh

# 拉取 cangjie 所有变体
docker pull ghcr.io/ertu426/cangjie:base
docker pull ghcr.io/ertu426/cangjie:ide
docker pull ghcr.io/ertu426/cangjie:ssh
docker pull ghcr.io/ertu426/cangjie:builder

# 拉取 vite 所有变体
docker pull ghcr.io/ertu426/vite:base
docker pull ghcr.io/ertu426/vite:ide
docker pull ghcr.io/ertu426/vite:ssh
```

---

## 开发方式

### 1. 容器开发（`base` 标签）

直接在容器内运行命令：

```bash
# 运行默认基础镜像
docker run -it --rm ghcr.io/ertu426/default:base

# 挂载项目运行 cangjie
docker run -it --rm -v $(pwd):/home/dev/workspace ghcr.io/ertu426/cangjie:base

# 挂载项目运行 vite
docker run -it --rm -v $(pwd):/home/dev/workspace ghcr.io/ertu426/vite:base
```

**包含特性：**
- Fish shell + Starship 提示符
- Neovim 编辑器
- Git + git-delta
- 现代 CLI 工具（bat, eza, zoxide, btop）

#### 使用 code-server（`ide` 标签）

```bash
# 启动 default 镜像的 code-server
docker run -d -p 8080:8080 --name dev-ide ghcr.io/ertu426/default:ide

# 启动 cangjie 镜像的 code-server
docker run -d -p 8081:8080 --name cangjie-ide ghcr.io/ertu426/cangjie:ide

# 启动 vite 镜像的 code-server
docker run -d -p 8082:8080 --name vite-ide ghcr.io/ertu426/vite:ide

# 在浏览器访问: http://localhost:8080 (default), 8081 (cangjie), 8082 (vite)
```

#### 使用 SSH（`ssh` 标签）

```bash
# 启动 default 镜像的 SSH
docker run -d -p 2222:2222 --name dev-ssh ghcr.io/ertu426/default:ssh

# 启动 cangjie 镜像的 SSH
docker run -d -p 2223:2222 --name cangjie-ssh ghcr.io/ertu426/cangjie:ssh

# 启动 vite 镜像的 SSH
docker run -d -p 2224:2222 --name vite-ssh ghcr.io/ertu426/vite:ssh

# 连接 SSH
ssh -p 2222 dev@localhost  # default
ssh -p 2223 dev@localhost  # cangjie
ssh -p 2224 dev@localhost  # vite
# 密码: dev
```

#### 使用容器开发

```bash
# 仅容器运行 default
docker run -it --rm ghcr.io/ertu426/default:base

# 仅容器运行 cangjie
docker run -it --rm ghcr.io/ertu426/cangjie:base

# 仅容器运行 vite
docker run -it --rm ghcr.io/ertu426/vite:base
```

### 2. SSH 开发（`ssh` 标签）

通过 SSH 远程开发：

```bash
# 启动 SSH 容器
docker run -d -p 2222:2222 --name dev-ssh ghcr.io/ertu426/default:ssh

# 连接 SSH
ssh -p 2222 dev@localhost
# 密码: dev

# 挂载项目
docker run -d -p 2222:2222 -v $(pwd):/home/dev/workspace ghcr.io/ertu426/default:ssh

# VS Code Remote SSH 配置
# 添加到 ~/.ssh/config:
# Host dev-container
#   HostName localhost
#   Port 2222
#   User dev
```

**SSH 配置：**
- 端口：2222
- 默认用户：`dev`
- 默认密码：`dev`
- 无密码 sudo

### 3. Code Server 开发（`ide` 标签）

在浏览器中使用 VS Code 开发：

```bash
# 启动 Code Server 容器
docker run -d -p 8080:8080 --name dev-ide ghcr.io/ertu426/default:ide

# 在浏览器中访问
open http://localhost:8080

# 挂载项目
docker run -d \
  -p 8080:8080 \
  -v $(pwd):/home/dev/workspace \
  ghcr.io/ertu426/default:ide
```

**Code Server 特性：**
- 端口：8080
- 默认关闭认证
- 支持中文界面
- 预配置设置

---

## 项目结构

```
dgen/
├── default/
│   ├── base/          # 最小化基础环境
│   ├── ide/           # + Code Server
│   └── ssh/           # + SSH 服务
├── cangjie/
│   ├── base/          # 仓颉 SDK + uv
│   ├── ide/           # + Code Server
│   ├── ssh/           # + SSH
│   └── builder/       # 仅构建环境
├── vite/
│   ├── base/          # Node.js + Vite
│   ├── ide/           # + Code Server
│   └── ssh/           # + SSH
├── .github/workflows/
│   └── build-images.yml    # 多架构构建流水线
└── README.md
```

---

## 预装工具

### 核心工具（所有镜像）

| 类别 | 工具 |
|------|------|
| Shell | Fish 3, Bash, Starship |
| 编辑器 | Neovim, Nano |
| Git | Git, git-delta |
| CLI | bat, eza, fzf, ripgrep, zoxide, btop |
| 网络 | curl, wget |
| 语言环境 | `zh_CN.UTF-8`, `en_US.UTF-8` |

### cangjie 镜像附加工具

| 类别 | 工具 |
|------|------|
| 仓颉 | SDK 1.1.0, stdx 1.1.0 |
| Python | uv + Python 3.11 |
| 构建 | binutils, libc-dev, libc++-dev |

### vite 镜像附加工具

| 类别 | 工具 |
|------|------|
| Node.js | via vite.plus |
| 前端 | Vite, Nuxt 工具链 |

---

## CI / CD

### 构建流水线

自动构建触发条件：
- 推送到 `main` 分支
- 推送到 `develop` 分支（仅测试）
- 每天北京时间 22:00

### 流水线流程

```
build-default-base → build-default-others (ide/ssh)
                  → build-cangjie (base/ide/ssh/builder)
                  → build-vite (base/ide/ssh)
```

---

## 安全注意

- 默认密码 `dev` 应在生产环境中修改
- SSH 主机密钥在运行时生成（不写入镜像）
- `dev` 用户拥有无密码 sudo（仅用于开发）
- Code Server 默认关闭认证

---

## 许可证

MIT — 参见 [LICENSE.md](LICENSE.md)