#!/usr/bin/env bash
set -euo pipefail

REPO="${REPO:-https://github.com/b1ek/config.git}"
d="$(mktemp -d)"
trap "rm -rf $d" EXIT

if [ -d /opt/cont/caddy ]; then
    echo /opt/cont/caddy exists, refusing to install
    echo delete it manually if you want to install as this install overwrites it by design
    exit 1
fi

echo "cloning $REPO sparse"
git clone --filter=blob:none --no-checkout --depth=1 --branch "main" "$REPO" "$d"
git -C "$d" sparse-checkout set rootfs
git -C "$d" checkout

ROOTFS="$d/rootfs"

echo "populating /opt/cont/caddy"
mkdir -p /opt/cont
cp -r "$ROOTFS/opt/cont/caddy" /opt/cont/caddy

docker network create services 2>/dev/null || true

cd /opt/cont/caddy
docker compose up -d --build
