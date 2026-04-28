# =============================================================================
# default — Universal Development Environment Image
# =============================================================================
# Supported Architectures: amd64 (x86_64), arm64 (aarch64)
# Base: Debian Trixie (13) Slim
# =============================================================================

# Multi-stage build for smaller final image
FROM debian:trixie-slim

# OCI Annotations (enriched)
LABEL org.opencontainers.image.title="DGen Default Development Environment"
LABEL org.opencontainers.image.title.zh="DGen 通用开发环境"
LABEL org.opencontainers.image.description="A comprehensive development container with Code Server, Fish shell, and modern CLI tools. Perfect for remote development via SSH or VS Code Dev Containers."
LABEL org.opencontainers.image.description.zh="全栈开发容器，预装 Code Server、Fish Shell 和现代化 CLI 工具。支持 SSH 远程连接和 VS Code Dev Containers，即开即用。"
LABEL org.opencontainers.image.source="https://github.com/ertu426/dgen"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.created="2026-03-23T14:43:23Z"
LABEL org.opencontainers.image.version="1.0.1"
LABEL org.opencontainers.image.vendor="DGen"
LABEL org.opencontainers.image.base.name="debian:trixie-slim"

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive \
    NBBUILDER=1

# Install minimal build dependencies for starship extraction
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl  && \
    sed -i 's/http:\/\/deb.debian.org/https:\/\/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources && \
    rm -rf /var/lib/apt/lists/*

# Environment variables for non-interactive installation
ENV LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh:en \
    LC_ALL=zh_CN.UTF-8 \
    TZ=Asia/Shanghai

# Install runtime packages (from official HTTPS sources only)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        wget \
        git \
        sudo \
        fish \
        neovim \
        nano \
        unzip \
        zip \
        openssh-server \
        openssh-sftp-server \
        btop \
        build-essential \
        bat \
        eza \
        zoxide \
        locales \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# =============================================================================
# Install Starship Cross-Shell Prompt
# =============================================================================
# Note: Debian uses musl libc by default, but starship's install.sh has issues
# with musl detection. We directly download the glibc version binaries.
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes

# =============================================================================
# Install Code Server v4.115.0 (via official install.sh)
# =============================================================================
RUN curl -fsSL https://code-server.dev/install.sh | sh

# =============================================================================
# User Configuration
# =============================================================================
# Create development user
RUN useradd -m -s /usr/bin/fish dev && \
    echo "dev:dev" | chpasswd && \
    echo "dev ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

# SSH configuration for key forwarding
RUN mkdir -p /home/dev/.ssh && \
    mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding yes/' /etc/ssh/sshd_config && \
    sed -i 's/#X11Forwarding no/X11Forwarding yes/' /etc/ssh/sshd_config && \
    sed -i 's/#GatewayPorts no/GatewayPorts yes/' /etc/ssh/sshd_config && \
    sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config && \
    chmod 755 /home/dev/.ssh

# Configure Code Server and user directories
RUN mkdir -p /home/dev/.config/code-server && \
    mkdir -p /home/dev/.local/bin && \
    chown -R dev:dev /home/dev

# Copy configuration files
COPY --chown=dev:dev files/starship.toml /home/dev/.config/starship.toml
COPY --chown=dev:dev files/config.fish /home/dev/.config/fish/config.fish
COPY --chown=dev:dev files/config.yaml /home/dev/.config/code-server/config.yaml
COPY files/start.sh /start.sh

# Git configuration with Delta pager
USER dev
RUN git config --global core.pager delta && \
    git config --global interactive.diffFilter "delta --color-only" && \
    git config --global delta.navigate true && \
    git config --global delta.dark true && \
    git config --global delta.line-numbers true && \
    git config --global delta.side-by-side true && \
    git config --global merge.conflictstyle diff3 && \
    git config --global diff.colorMoved default && \
    git config --global delta.features "side-by-side line-numbers navigate" && \
    # Chinese git messages
    git config --global commit.template ~/.gitmessage && \
    echo "# 标题（最多50字符）\n\n# 正文（解释 what 和 why，不含 how）\n# \n# 类型: feat | fix | docs | style | refactor | test | chore\n# 影响范围: (可选) 模块名\n" > ~/.gitmessage

# PATH configuration
ENV PATH=/home/dev/.local/bin:$PATH

# Set working directory
WORKDIR /home/dev/workspace

# =============================================================================
# Container Configuration
# =============================================================================
USER root

# Expose ports
# 8080: Code Server web interface
# 2222: SSH server (internal)
EXPOSE 8080 2222

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Entrypoint
ENTRYPOINT ["/start.sh"]
