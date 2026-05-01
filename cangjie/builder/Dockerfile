FROM debian:13-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        zip \
        curl \
        sudo \
        unzip \
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

RUN curl -LsSf https://raw.githubusercontent.com/ertu426/dgen/refs/heads/main/scripts/setup-cangjie.sh | bash

ENV HOME=/home/cangjie \
    CANGJIE_HOME=/home/cangjie/cangjie \
    CANGJIE_STDX_HOME=/home/cangjie/cangjie_stdx \
    PYTHON_3_11_HOME=/home/cangjie/.local/share/uv/python/cpython-3.11.15-linux-x86_64-gnu \
    PATH=/home/cangjie/cangjie/bin:/home/cangjie/cangjie/tools/bin:/home/cangjie/.local/bin:$PATH \
    LD_LIBRARY_PATH=/home/cangjie/cangjie/runtime/lib/linux_x86_64_cjnative:/home/cangjie/cangjie/tools/lib:/home/cangjie/cangjie_stdx/static/stdx:$PYTHON_3_11_HOME/lib

CMD ["/bin/bash"]
