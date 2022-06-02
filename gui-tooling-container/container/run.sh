#!/usr/bin/env bash

USERNAME="lbdo"
PASSWORD="libredevopspassword"

start_xrdp_services() {
    # Preventing xrdp startup failure
    rm -rf /var/run/xrdp-sesman.pid
    rm -rf /var/run/xrdp.pid
    rm -rf /var/run/xrdp/xrdp-sesman.pid
    rm -rf /var/run/xrdp/xrdp.pid

    # Use exec ... to forward SIGNAL to child processes
    xrdp-sesman && exec xrdp -n
}

stop_xrdp_services() {
    xrdp --kill
    xrdp-sesman --kill
    exit 0
}


echo Entryponit script is Running...

addgroup ${USERNAME}
useradd -m -s /bin/bash -g ${USERNAME} ${USERNAME}
wait
#getent passwd | grep foo
echo ${USERNAME}:${PASSWORD} | chpasswd
wait
usermod -aG sudo ${USERNAME}
usermod -aG podman ${USERNAME}
echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/usr/local/go:/usr/local/go/dev/bin:/usr/local/bin/python3:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.local/bin" >> /home/${USERNAME}/.bashrc
chown -R ${USERNAME} /home/linuxbrew
wait
echo "user '${USERNAME}' is added"

echo -e "This script is ended\n"

echo -e "starting xrdp services...\n"

trap "stop_xrdp_services" SIGKILL SIGTERM SIGHUP SIGINT EXIT
start_xrdp_services
