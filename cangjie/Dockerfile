# =============================================================================
# cangjie — Cangjie Programming Language Development Environment
# =============================================================================
# Supported Architectures: amd64 (x86_64), arm64 (aarch64)
# Base: DGen Default Development Container
# =============================================================================

# Multi-stage build for smaller final image
FROM ghcr.io/ertu426/default:latest

# OCI Annotations (enriched)
LABEL org.opencontainers.image.title="DGen Cangjie Development Environment"
LABEL org.opencontainers.image.title.zh="DGen 仓颉开发环境"
LABEL org.opencontainers.image.description="Development container for Cangjie programming language with SDK, stdx, and uv Python management. Supports x86_64 and ARM64 architectures."
LABEL org.opencontainers.image.description.zh="仓颉编程语言开发容器，预装 SDK、标准库和 uv Python 管理工具。支持 x86_64 和 ARM64 架构。"
LABEL org.opencontainers.image.source="https://github.com/ertu426/dgen"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.created="2024-01-01T00:00:00Z"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.vendor="DGen"
LABEL org.opencontainers.image.base.name="ghcr.io/ertu426/default"

# =============================================================================
# Download Cangjie SDK (x86_64)
# =============================================================================
WORKDIR /tmp/cangjie
RUN ARCH="$(dpkg --print-architecture)" && \
    case "$ARCH" in \
        amd64) \
            SDK_URL="https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-linux-x64-1.1.0-beta.25.tar.gz&objectKey=69cb718e6e8ed61e6e07fd42" && \
            SDKX_URL="https://gitcode.com/Cangjie/cangjie_stdx/releases/download/v1.1.0-beta.25/cangjie-stdx-linux-x64-1.1.0-beta.25.1.zip" ;; \
        arm64) \
            SDK_URL="https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-linux-aarch64-1.1.0-beta.25.tar.gz&objectKey=69cb74a76e8ed61e6e07fd45" && \
            SDKX_URL="https://gitcode.com/Cangjie/cangjie_stdx/releases/download/v1.1.0-beta.25/cangjie-stdx-linux-aarch64-1.1.0-beta.25.1.zip" ;; \
        *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac && \
    curl -L --fail --show-error -o sdk.tar.gz "$SDK_URL" && \
    curl -L --fail --show-error -o sdkx.zip "$SDKX_URL"

WORKDIR /tmp
RUN curl -L --fail --show-error -o cangjie-vscode.tar.gz "https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-vscode-1.1.0-beta.25.tar.gz&objectKey=69cb70e16e8ed61e6e07fd3e"

# =============================================================================
# Build Stage: Extract and Prepare Cangjie SDK
# =============================================================================
WORKDIR /tmp/cangjie-install
RUN mkdir -p /home/dev/cangjie /home/dev/cangjie_sdkx /tmp/cangjie-vscode && \
    tar -xzf /tmp/cangjie/sdk.tar.gz -C /home/dev/cangjie --strip-components=1 && \
    unzip -q /tmp/cangjie/sdkx.zip -d /home/dev/cangjie_sdkx && \
    chown -R dev:dev /home/dev/cangjie /home/dev/cangjie_sdkx && \
    rm -rf /tmp/cangjie /tmp/cangjie-install


# =============================================================================
# Runtime Stage
# =============================================================================
# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      binutils \
      libc-dev \
      libc++-dev \
      libgcc-14-dev \
      build-essential && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Configure environment
USER dev
WORKDIR /home/dev

# =============================================================================
# Install uv + Python
# =============================================================================
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    /home/dev/.local/bin/uv python install 3.11
ENV PATH="/root/.local/bin:$PATH"

# Configure Cangjie environment in fish
RUN mkdir -p ~/.config/fish && \
    echo '' >> ~/.config/fish/config.fish && \
    echo '# 仓颉 SDK (Cangjie SDK)' >> ~/.config/fish/config.fish && \
    echo 'set -gx CANGJIE_HOME /home/dev/cangjie' >> ~/.config/fish/config.fish && \
    echo 'set -gx CANGJIE_SDKX_HOME /home/dev/cangjie_sdkx' >> ~/.config/fish/config.fish && \
    echo 'set -gx PATH $CANGJIE_HOME/bin $CANGJIE_HOME/tools/bin $HOME/.cjpm/bin $HOME/.local/bin $HOME/.cargo/bin $PATH' >> ~/.config/fish/config.fish && \
    echo 'set -gx LD_LIBRARY_PATH $CANGJIE_HOME/runtime/lib/linux_x86_64_cjnative $CANGJIE_HOME/tools/lib $CANGJIE_SDKX_HOME/linux_x86_64_cjnative/static/stdx /home/dev/.local/share/uv/python/cpython-3.11.15-linux-x86_64-gnu/lib $LD_LIBRARY_PATH' >> ~/.config/fish/config.fish

# Configure uv + Python environment
RUN echo '' >> ~/.config/fish/config.fish && \
    echo '# uv + Python (Python Package Manager)' >> ~/.config/fish/config.fish && \
    echo 'set -gx PATH $HOME/.local/bin $HOME/.cargo/bin $PATH' >> ~/.config/fish/config.fish && \
    echo 'uv generate-shell-completion fish | source' >> ~/.config/fish/config.fish

# PATH
ENV PATH=/home/dev/cangjie/bin:/home/dev/cangjie/tools/bin:/home/dev/.local/bin:/home/dev/.cargo/bin:/home/dev/.cjpm/bin:$PATH
ENV CANGJIE_HOME=/home/dev/cangjie
ENV CANGJIE_SDKX_HOME=/home/dev/cangjie_sdkx

# Working directory
WORKDIR /home/dev/workspace
RUN tar -xzf /tmp/cangjie-vscode.tar.gz -C /home/dev/workspace --strip-components=1

USER root

EXPOSE 8080 2222

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Entry point - starts SSH and serves as general container
ENTRYPOINT ["/start.sh"]