FROM ghcr.io/ertu426/default:latest

LABEL org.opencontainers.image.source=https://github.com/ertu426/dgen
LABEL org.opencontainers.image.licenses=MIT

USER root
RUN ["/usr/bin/fish", "-c", "apt-get update && apt-get install -y binutils libc-dev libc++-dev libgcc-14-dev build-essential && rm -rf /var/lib/apt/lists/*"]


COPY --chown=dev:dev --chmod=u+x scripts /tmp/scripts

USER dev
WORKDIR /home/dev

# 显式设置 SHELL 环境变量为 fish，确保脚本中的 get_shell_rc()
# 能正确识别 fish 并写入 ~/.config/fish/config.fish
ENV SHELL=/usr/bin/fish

# 使用 sh 执行 POSIX 脚本（shebang 是 sh），同时继承 SHELL=fish 环境变量
RUN SHELL=/usr/bin/fish sh /tmp/scripts/install_uv.sh
RUN SHELL=/usr/bin/fish sh /tmp/scripts/install_cangjie.sh

# 通过 ENV 将关键路径写入镜像元数据，两个作用：
#   1. 非交互式容器启动（如 CMD 执行程序）时无需 source 配置文件即可访问
#   2. fish 交互登录时，config.fish 中的 set -gx 会覆盖这些值（完全兼容）
ENV CANGJIE_HOME=/home/dev/cangjie
ENV CANGJIE_SDKX_HOME=/home/dev/cangjie_sdkx
ENV PATH=/home/dev/cangjie/bin:/home/dev/cangjie/tools/bin:/home/dev/.local/bin:/home/dev/.cargo/bin:/home/dev/.cjpm/bin:$PATH

RUN rm -rf /tmp/scripts

USER root
EXPOSE 8080 22
CMD ["/scripts"]