FROM debian:latest

LABEL org.opencontainers.image.source=https://github.com/ertu426/dgen
LABEL org.opencontainers.image.licenses=MIT

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8

USER root
WORKDIR /

COPY --chmod=+x files/start.sh /start.sh

# ==========================================
# 1. 基础系统配置与 APT 软件安装
# ==========================================
RUN sed -i 's/http:\/\/deb.debian.org/https:\/\/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources &&\
    apt-get update &&\
    apt-get install -y wget curl neovim nano unzip zip openssh-server openssh-sftp-server git build-essential fish bat fd-find ripgrep jq fzf btop zoxide eza tealdeer git-delta lazygit  && \
    apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/*
RUN ssh-keygen -A

# ==========================================
# 2. 安装 CLI 工具
# ==========================================
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes
RUN curl -fsSL https://code-server.dev/install.sh | sh

# ==========================================
# 3. 创建用户并配置环境变量
# ==========================================
RUN useradd -m -s /usr/bin/fish dev && \
    echo "dev:dev" | chpasswd && \
    echo "dev ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

USER dev
WORKDIR /home/dev

COPY --chown=dev:dev files/starship.toml .config/starship.toml
COPY --chown=dev:dev files/config.yaml .config/code-server/config.yaml

RUN mkdir -p /home/dev/.local/bin &&\
    ln -sf "$(which batcat)" /home/dev/.local/bin/bat &&\
    ln -sf "$(which fdfind)" /home/dev/.local/bin/fd &&\
    git config --global core.pager delta &&\
    git config --global interactive.diffFilter "delta --color-only" &&\
    git config --global delta.navigate true &&\
    git config --global delta.dark true &&\
    git config --global delta.line-numbers true &&\
    git config --global delta.side-by-side true &&\
    git config --global merge.conflictstyle diff3 &&\
    git config --global diff.colorMoved default &&\
    echo "source (starship init fish --print-full-init | psub)" >> ~/.config/fish/config.fish

ENV PATH=/home/dev/.local/bin:$PATH

WORKDIR /home/dev/workspace

USER root
EXPOSE 8080 22
ENTRYPOINT ["/start.sh"]
