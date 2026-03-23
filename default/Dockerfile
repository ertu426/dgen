FROM debian:latest

LABEL maintainer="one@2xat.net"

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8

COPY scripts /scripts
COPY scripts/start.sh /start.sh

RUN apt-get update && apt-get install -y ca-certificates && \
    rm -f /etc/apt/sources.list.d/debian.sources &&\
    rm -f /etc/apt/sources.list &&\
    chmod +x /scripts/*.sh &&\
    chmod +x /start.sh

COPY debian.sources /etc/apt/sources.list.d/

RUN apt-get update && apt-get install -y wget unzip lsof nload htop net-tools dnsutils openssh-server openssh-sftp-server zsh git curl sudo && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://code-server.dev/install.sh | sh

RUN useradd -m -s /bin/zsh dev && \
    echo "dev:dev" | chpasswd && \
    echo "dev ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

USER dev
WORKDIR /home/dev

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    /scripts/add-zsh-plugins.sh zsh-autosuggestions zsh-syntax-highlighting && \
    /scripts/set-zsh-env.sh && \
    echo 'setopt NO_AUTO_REMOVE_SLASH' >> ~/.zshrc && \
    mkdir -p ~/.oh-my-zsh/completions

WORKDIR /home/dev/workspace

USER root
RUN ["rm", "-rf", "/scripts"]

EXPOSE 8080 22
ENTRYPOINT ["/start.sh"]