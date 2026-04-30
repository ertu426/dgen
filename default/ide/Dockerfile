FROM ghcr.io/ertu426/default:latest

USER root
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN mkdir -p /home/dev/.config/code-server && chown -R dev:dev /home/dev

COPY --chown=dev:dev files/config.yaml /home/dev/.config/code-server/config.yaml

USER dev
EXPOSE 8080
CMD ["code-server", "--config", "/home/dev/.config/code-server/config.yaml"]