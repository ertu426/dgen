FROM debian:latest

LABEL maintainer="one@2xat.net"

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8

COPY scripts /scripts

# --- 基础系统配置 ---
RUN apt-get update && apt-get install -y ca-certificates && \
    rm -f /etc/apt/sources.list.d/debian.sources &&\
    rm -f /etc/apt/sources.list &&\
    chmod +x /scripts/*.sh

COPY debian.sources /etc/apt/sources.list.d/

RUN apt-get update && apt-get install -y wget unzip lsof nload htop net-tools dnsutils openssh-server zsh git curl && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

# 准备 SSH 目录
#RUN mkdir /var/run/sshd

RUN curl -fsSL https://code-server.dev/install.sh | sh

# --- 用户创建 ---
# 创建 dev 用户，并设置 zsh 为默认 shell
RUN useradd -m -s /bin/zsh dev && \
    echo "dev:dev" | chpasswd && \
    echo "dev ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

# --- Dev 用户环境配置 ---
USER dev
WORKDIR /home/dev

# 为 dev 用户安装 Oh My Zsh 和插件
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    /scripts/add-zsh-plugins.sh zsh-autosuggestions zsh-syntax-highlighting && \
    /scripts/set-zsh-env.sh && \
    echo 'setopt NO_AUTO_REMOVE_SLASH' >> ~/.zshrc && \
    mkdir -p ~/.oh-my-zsh/completions

# 设置工作目录并修改权限
WORKDIR /home/dev/workspace

EXPOSE 8080 22


CMD ["/scripts/start.sh"]
