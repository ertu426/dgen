FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=zh_CN.UTF-8 \
    TZ=Asia/Shanghai

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        fish \
        neovim \
        nano \
        unzip \
        locales \
    && echo "en_US.UTF-8 UTF-8\nzh_CN.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoremove -y --purge

RUN useradd -m -s /usr/bin/fish dev && \
    echo "dev:dev" | chpasswd && \
    echo "dev ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

COPY --chown=dev:dev files/starship.toml /home/dev/.config/starship.toml
COPY --chown=dev:dev files/config.fish /home/dev/.config/fish/config.fish

USER dev
ENV PATH=/home/dev/.local/bin:$PATH
WORKDIR /home/dev