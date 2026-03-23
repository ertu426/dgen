FROM ghcr.io/ertu426/default:latest

COPY --chown=dev:dev --chmod=u+x scripts/install_cangjie.sh /tmp/install_cangjie.sh
COPY --chown=dev:dev --chmod=u+x scripts/install_uv.sh /tmp/install_uv.sh

USER dev
RUN /tmp/install_cangjie.sh
RUN /tmp/install_uv.sh 

USER root
RUN apt-get update && apt-get install -y binutils libc-dev libc++-dev libgcc-14-dev && \
    rm -rf /tmp/cangjie_src /tmp/install_cangjie.sh /var/lib/apt/lists/*

EXPOSE 8080 22
CMD ["/scripts"]