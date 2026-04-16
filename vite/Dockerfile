FROM ghcr.io/ertu426/default:latest

# =============================================================================
# User Configuration
# =============================================================================
USER dev
WORKDIR /home/dev
RUN curl -fsSL https://vite.plus | bash

# =============================================================================
# Container Configuration
# =============================================================================
USER root
# Set working directory
WORKDIR /home/dev/workspace

# Expose ports
# 8080: Code Server web interface
# 2222: SSH server (internal)
EXPOSE 8080 2222

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Entrypoint
ENTRYPOINT ["/start.sh"]