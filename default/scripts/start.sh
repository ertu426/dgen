#!/bin/bash

set_password() {
    local user="$1"
    local password="$2"

    encrypted=$(openssl passwd -1 "$password")
    
    usermod -p "$encrypted" "$user"
}

if [ -n "$DEV_PASSWORD" ]; then
    set_password dev "$DEV_PASSWORD"
else
    set_password dev "dev"
fi

rm -rf /scripts
service ssh start

exec su -s /bin/bash -c "code-server --bind-addr 0.0.0.0:8080 --auth none /home/dev/workspace" dev