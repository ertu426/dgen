FROM debian:13-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        sudo \
        file \
        binutils \
        libc-dev \
        libc++-dev \
        libgcc-14-dev \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m cangjie && \
    echo "cangjie ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

USER cangjie
WORKDIR /home/cangjie

RUN ARCH="$(dpkg --print-architecture)" && \
    case "$ARCH" in \
        amd64) SDK_URL="https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-linux-x64-1.1.0.tar.gz&objectKey=69e9d50c21f5a8178d6fd219" ;; \
        arm64) SDK_URL="https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-linux-aarch64-1.1.0.tar.gz&objectKey=69e9d37021f5a8178d6fd216" ;; \
    esac && \
    curl -fSL "$SDK_URL" | tar -xz

RUN ARCH="$(dpkg --print-architecture)" && \
    case "$ARCH" in \
        amd64) STDX_URL="https://gitcode.com/Cangjie/cangjie_stdx/releases/download/v1.1.0.1/cangjie-stdx-linux-x64-1.1.0.1.zip" ;; \
        arm64) STDX_URL="https://gitcode.com/Cangjie/cangjie_stdx/releases/download/v1.1.0.1/cangjie-stdx-linux-aarch64-1.1.0.1.zip" ;; \
    esac && \
    curl -fSL -o cangjie_stdx.zip "$STDX_URL" && \
    unzip -q cangjie_stdx.zip -d cangjie_stdx && \
    rm cangjie_stdx.zip

RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    /home/cangjie/.local/bin/uv python install 3.11

ENV HOME=/home/cangjie \
    CANGJIE_HOME=/home/cangjie/cangjie \
    CANGJIE_STDX_HOME=/home/cangjie/cangjie_stdx \
    PYTHON_3_11_HOME=/home/cangjie/.local/share/uv/python/cpython-3.11.15-linux-x86_64-gnu \
    PATH=/home/cangjie/cangjie/bin:/home/cangjie/cangjie/tools/bin:/home/cangjie/.local/bin:$PATH \
    LD_LIBRARY_PATH=/home/cangjie/cangjie/runtime/lib/linux_x86_64_cjnative:/home/cangjie/cangjie/tools/lib:/home/cangjie/cangjie_stdx/static/stdx:$PYTHON_3_11_HOME/lib

CMD ["/bin/bash"]