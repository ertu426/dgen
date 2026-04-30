FROM ghcr.io/ertu426/default:latest

USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        file \
        binutils \
        libc-dev \
        libc++-dev \
        libgcc-14-dev && \
    rm -rf /var/lib/apt/lists/*

USER dev
WORKDIR /home/dev

RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    /home/dev/.local/bin/uv python install 3.11

RUN ARCH="$(dpkg --print-architecture)" && \
    case "$ARCH" in \
        amd64) SDK_URL="https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-linux-x64-1.1.0.tar.gz&objectKey=69e9d50c21f5a8178d6fd219" ;; \
        arm64) SDK_URL="https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-linux-aarch64-1.1.0.tar.gz&objectKey=69e9d37021f5a8178d6fd216" ;; \
    esac && \
    curl -fSL "$SDK_URL" | tar -xz

RUN bash -c "$(curl -fsSL https://raw.gitcode.com/Cangjie/cangjie_stdx/raw/dev/downloader.sh)" -- 1.1.0.1 && \
    mv cangjie-stdx* cangjie_stdx

ENV HOME=/home/dev
ENV CANGJIE_HOME=$HOME/cangjie
ENV CANGJIE_STDX_HOME=$HOME/cangjie_stdx
ENV PYTHON_3_11_HOME=$HOME/.local/share/uv/python/cpython-3.11.15-linux-x86_64-gnu
ENV PATH=$HOME/cangjie/bin:$HOME/cangjie/tools/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.cjpm/bin:$PATH
ENV LD_LIBRARY_PATH=$HOME/cangjie/runtime/lib/linux_x86_64_cjnative:$HOME/cangjie/tools/lib:$HOME/cangjie_stdx/static/stdx:$PYTHON_3_11_HOME/lib

WORKDIR /home/dev/workspace