FROM debian:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8

USER root
WORKDIR /

COPY --chmod=+x files/start.sh /start.sh

# ==========================================
# 1. 基础系统配置与 APT 软件安装
# ==========================================
RUN apt-get update &&\
    apt-get install -y ca-certificates &&\
    rm -rf /var/lib/apt/lists/* /etc/apt/sources.list


COPY files/debian.sources /etc/apt/sources.list.d/debian.sources
RUN apt-get update &&\
    apt-get install -y wget curl unzip zip btop openssh-server openssh-sftp-server zsh git zsh-autosuggestions zsh-syntax-highlighting bat fd-find ripgrep jq fzf eza neovim nano && \
    apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/*
RUN ssh-keygen -A

# ==========================================
# 2. 安装 CLI 工具
# ==========================================
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN curl -fSL -o /tmp/sudo.tar.gz https://github.com/trifectatechfoundation/sudo-rs/releases/download/v0.2.13/sudo-0.2.13.tar.gz &&\
    curl -fSL -o /tmp/su.tar.gz https://github.com/trifectatechfoundation/sudo-rs/releases/download/v0.2.13/su-0.2.13.tar.gz &&\
    tar -C /usr/local -xvf /tmp/sudo.tar.gz && tar -C /usr/local -xvf /tmp/su.tar.gz &&\
    rm -rf /tmp/sudo.tar.gz /tmp/su.tar.gz &&\
    chmod 4755 /usr/local/bin/sudo && \
    chmod 4755 /usr/local/bin/su

# ==========================================
# 3. 创建用户并配置环境变量
# ==========================================
RUN useradd -m -s /bin/zsh dev && \
    echo "dev:dev" | chpasswd && \
    echo "dev ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN mkdir -p /home/dev/.local/bin && \
    ln -sf "$(which batcat)" /home/dev/.local/bin/bat && \
    ln -sf "$(which fdfind)" /home/dev/.local/bin/fd && \
    chown -R dev:dev /home/dev/.local/bin

USER dev
WORKDIR /home/dev

RUN curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

COPY files/.zshrc .zshrc
COPY files/starship.toml .config/starship.toml
COPY files/config.yaml .config/code-server/config.yaml

WORKDIR /home/dev/workspace

USER root
EXPOSE 8080 22
ENTRYPOINT ["/usr/bin/zsh", "/start.sh"]
