FROM ghcr.io/ertu426/default:dev

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

RUN curl -LsSf https://raw.githubusercontent.com/ertu426/dgen/refs/heads/main/scripts/setup-cangjie.sh | bash

ENV HOME=/home/dev
ENV CANGJIE_HOME=$HOME/cangjie
ENV CANGJIE_STDX_HOME=$HOME/cangjie_stdx
ENV PYTHON_3_11_HOME=$HOME/.local/share/uv/python/cpython-3.11.15-linux-x86_64-gnu
ENV PATH=$HOME/cangjie/bin:$HOME/cangjie/tools/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.cjpm/bin:$PATH
ENV LD_LIBRARY_PATH=$HOME/cangjie/runtime/lib/linux_x86_64_cjnative:$HOME/cangjie/tools/lib:$HOME/cangjie_stdx/static/stdx:$PYTHON_3_11_HOME/lib

WORKDIR /home/dev/workspace