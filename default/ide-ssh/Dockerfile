FROM ghcr.io/ertu426/default:latest

USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends openssh-server && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd && \
    sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config && \
    ssh-keygen -A

EXPOSE 8080 2222
CMD ["/bin/bash", "-c", "/usr/sbin/sshd -D -p 2222 & code-server --config /home/dev/.config/code-server/config.yaml"]