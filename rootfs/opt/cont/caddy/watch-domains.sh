#!/usr/bin/env sh

echo entered watch script

inotifywait -m -r -e create,modify,delete,moved_to,moved_from "/etc/caddy" |
while read -r dir event file; do
    if [ "$file" == "Caddyfile" ]; then
        continue
    fi
    echo detected $event on $dir$file, compiling...
    compile-caddyfile.sh
done
