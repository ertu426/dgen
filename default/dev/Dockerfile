FROM ghcr.io/ertu426/default:latest

USER root

RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc

RUN echo "Types: deb" >> /etc/apt/sources.list.d/docker.sources && \
    echo "URIs: https://download.docker.com/linux/debian" >> /etc/apt/sources.list.d/docker.sources && \
    echo "Suites: $(. /etc/os-release && echo $VERSION_CODENAME)" >> /etc/apt/sources.list.d/docker.sources && \
    echo "Components: stable" >> /etc/apt/sources.list.d/docker.sources && \
    echo "Architectures: $(dpkg --print-architecture)" >> /etc/apt/sources.list.d/docker.sources && \
    echo "Signed-By: /etc/apt/keyrings/docker.asc" >> /etc/apt/sources.list.d/docker.sources

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        docker-ce-cli \
        docker-buildx-plugin \
        docker-compose-plugin

RUN groupadd -f docker && \
    usermod -aG docker dev

USER dev
WORKDIR /home/dev