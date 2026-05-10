#!/usr/bin/env bash
set -euo pipefail

if [ "$EUID" != "0" ]; then
    echo need to run as root
    exit 1
fi

if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO="${ID:-unknown}"
else
    DISTRO="unknown"
fi

PKGS_COMMON=(git wget curl neovim zsh ncdu fastfetch)

case "$DISTRO" in
    arch)
        pacman -S --noconfirm "${PKGS_COMMON[@]}" openssh
        ;;
    alpine)
        apk add --no-cache "${PKGS_COMMON[@]}" openssh
        ;;
    debian|ubuntu)
        apt update
        apt install -y "${PKGS_COMMON[@]}" openssh-client
        ;;
    *)
        echo "unknown distro: $DISTRO"
        echo please install these manually:
        echo "$PKGS_COMMON ssh"
        exit 2
        ;;
esac
