#!/usr/bin/env bash
set -euo pipefail

if [ "$EUID" != "0" ]; then
    echo need to run as root
    exit 1
fi

REPO="${REPO:-https://github.com/b1ek/config.git}"
d="$(mktemp -d)"
trap 'rm -rf "$d"' EXIT

if ! id blek &>/dev/null; then
    useradd blek
    usermod -p '$6$85TbEO1KakeWjKpo$bzR90G3SFrSP.EK855xe4jzQSMJfMPkqWOyRE2NEAXrTokV7R1n3gqSxAhdG2ZYosK7UN/09Q/XHClf0TaJRY0' blek
fi

if [ -f /etc/doas.conf ]; then
    grep -q '^permit blek$' /etc/doas.conf || echo 'permit blek' >> /etc/doas.conf
fi

if [ -d /etc/sudoers.d ]; then
    echo 'blek ALL=(ALL:ALL) ALL' > /etc/sudoers.d/blek
    chmod 440 /etc/sudoers.d/blek
elif [ -f /etc/sudoers ]; then
    grep -q '^blek' /etc/sudoers || printf 'blek\tALL=(ALL:ALL)\tALL\n' >> /etc/sudoers
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

if command -v zsh &>/dev/null; then
    usermod -s "$(command -v zsh)" blek
else
    echo "zsh not found, skipping shell change"
fi

mkdir -p /etc/ssh/sshd_config.d
cp $ROOTFS/etc/ssh/sshd_config.d/* /etc/ssh/sshd_config.d
systemctl reload sshd
