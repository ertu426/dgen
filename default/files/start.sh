#!/bin/bash
# =============================================================================
# start.sh — Container Entry Point
# =============================================================================
# Starts SSH daemon and Code Server for remote development
# =============================================================================

set -e

echo "========================================"
echo "  DGen Development Container"
echo "  Starting services..."
echo "========================================"

# Fix ownership for mounted volumes and any root-owned files in home
echo "[Setup] Fixing directory permissions..."
# Fix all files in home directory that might be owned by root (from bind mounts)
find /home/dev -mindepth 1 ! -user dev -exec chown -R dev:dev {} + 2>/dev/null || true
# Ensure critical directories exist with correct permissions
mkdir -p /home/dev/workspace /home/dev/.config /home/dev/.ssh /home/dev/.cache /home/dev/.local
chown -R dev:dev /home/dev

# Generate SSH host keys if they don't exist
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    echo "[SSH] Generating host keys..."
    ssh-keygen -A
fi

# Start SSH daemon in background
echo "[SSH] Starting SSH server on port 2222..."
mkdir -p /var/run/sshd
/usr/sbin/sshd -D -p 2222 &
SSH_PID=$!

# Set locale for Chinese support
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8

# Start Code Server as dev user
echo "[Code Server] Starting on port 8080..."
cd /home/dev
sudo -u dev code-server --config /home/dev/.config/code-server/config.yaml &

# Welcome message
echo ""
echo "========================================"
echo "  Services Started Successfully!"
echo "========================================"
echo ""
echo "  SSH Server:  localhost:2222"
echo "  Code Server: localhost:8080"
echo ""
echo "  Connection Methods:"
echo "  1. VS Code Remote SSH:"
echo "     ssh -p 2222 dev@localhost"
echo ""
echo "  2. Browser Access:"
echo "     http://localhost:8080"
echo ""
echo "========================================"
echo ""

# Wait for all background processes
wait
