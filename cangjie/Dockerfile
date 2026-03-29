FROM ghcr.io/ertu426/default:latest

LABEL org.opencontainers.image.source=https://github.com/ertu426/dgen
LABEL org.opencontainers.image.licenses=MIT

USER root
RUN apt-get update && apt-get install -y binutils libc-dev libc++-dev libgcc-14-dev build-essential && \
    rm -rf /var/lib/apt/lists/*


COPY --chown=dev:dev --chmod=u+x scripts/install_cangjie.sh /tmp/install_cangjie.sh
COPY --chown=dev:dev --chmod=u+x scripts/install_uv.sh /tmp/install_uv.sh

USER dev
WORKDIR /home/dev
RUN sudo chown dev:dev -R .
RUN /bin/zsh /tmp/install_uv.sh &&\
    /bin/zsh /tmp/install_cangjie.sh &&\
    rm -rf /tmp/install_cangjie.sh /tmp/install_uv.sh


USER root
EXPOSE 8080 22
CMD ["/scripts"]