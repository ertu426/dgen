FROM debian:13-slim

ARG TARGETARCH=amd64

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl \
      sudo \
      file \
      unzip \
      binutils \
      libc-dev \
      libc++-dev \
      libgcc-14-dev \
      ca-certificates \
      build-essential&& \
    rm -rf /var/lib/apt/lists/*


RUN useradd -m cangjie && \
    echo "cangjie ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
USER cangjie

# =============================================================================
# Install Cangjie SDK * Cangjie STDX
# =============================================================================
WORKDIR /home/cangjie

# Download Cangjie SDK and extract it
RUN ARCH="$(dpkg --print-architecture)" && \
    case "$ARCH" in \
        amd64) SDK_URL="https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-linux-x64-1.1.0.tar.gz&objectKey=69e9d50c21f5a8178d6fd219" ;; \
        arm64) SDK_URL="https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-linux-aarch64-1.1.0.tar.gz&objectKey=69e9d37021f5a8178d6fd216" ;; \
        *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac && \
    curl -fSL "$SDK_URL" | tar -xz

# Download Cangjie STDX
RUN bash -c "$(curl -fsSL https://raw.gitcode.com/Cangjie/cangjie_stdx/raw/dev/downloader.sh)" -- 1.1.0.1 && \
    mv cangjie-stdx* cangjie_stdx && \
    rm -rf .cangjie_stdx

RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    /home/cangjie/.local/bin/uv python install 3.11

ENV HOME=/home/cangjie
ENV CANGJIE_HOME=/home/cangjie/cangjie
ENV CANGJIE_STDX_HOME=/home/cangjie/cangjie_stdx
ENV PYTHON_3_11_HOME=/home/cangjie/.local/share/uv/python/cpython-3.11.15-linux-x86_64-gnu
ENV PATH=$CANGJIE_HOME/bin:$CANGJIE_HOME/tools/bin:$CANGJIE_STDX_HOME/static/stdx:$HOME/.local/bin:$PATH
ENV LD_LIBRARY_PATH=$CANGJIE_HOME/runtime/lib/linux_x86_64_cjnative:$CANGJIE_HOME/tools/lib:$CANGJIE_STDX_HOME/static/stdx:$PYTHON_3_11_HOME/lib
ENV LIBRARY_PATH=$CANGJIE_HOME/runtime/lib/linux_x86_64_cjnative:$CANGJIE_HOME/tools/lib:$CANGJIE_STDX_HOME/static/stdx:$PYTHON_3_11_HOME/lib

CMD ["/bin/bash"]