#!/usr/bin/env bash
set -euo pipefail

if [ "$EUID" != "0" ]; then
    echo need to run as root
    exit 1
fi

REPO="${REPO:-https://github.com/b1ek/config.git}"
d="$(mktemp -d)"
trap "rm -rf $d" EXIT

useradd blek
usermod -p '$6$85TbEO1KakeWjKpo$bzR90G3SFrSP.EK855xe4jzQSMJfMPkqWOyRE2NEAXrTokV7R1n3gqSxAhdG2ZYosK7UN/09Q/XHClf0TaJRY0' blek

if [ -f /etc/doas.conf ]; then
    echo 'permit blek' >> /etc/doas.conf
fi

if [ -f /etc/sudoers ]; then
    printf 'blek\tALL=(ALL:ALL)\tALL\n' >> /etc/sudoers
fi

echo "cloning $REPO sparse"
git clone --filter=blob:none --no-checkout --depth=1 --branch "main" "$REPO" "$d"
git -C "$d" sparse-checkout set rootfs
git -C "$d" checkout

ROOTFS="$d/rootfs"

cp "$ROOTFS/home/blek" /home/blek -r
chown blek:blek /home/blek -R
chmod 600 /home/blek/.ssh -R
chmod 700 /home/blek/.ssh

zsh -c 'echo' > /dev/null

if [ "$?" == "0" ]; then
    usermod -s $(which zsh) blek
else
    echo not going to set zsh as default because theres no zsh on the system
fi
