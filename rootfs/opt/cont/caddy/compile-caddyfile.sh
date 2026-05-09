#!/usr/bin/env sh

CADDY_CONFIG=${CADDY_CONFIG:-/etc/caddy}
BASE="$CADDY_CONFIG/Caddyfile.base"
DOMAINS_DIR="$CADDY_CONFIG/domains"
OUT="$CADDY_CONFIG/Caddyfile"

echo "# This file is auto generated. Don't edit it directly!" > "$OUT"
echo "# You prolly want to edit Caddyfile.base" >> "$OUT"
echo >> "$OUT"

cat "$BASE" >> "$OUT"

if [ -d "$DOMAINS_DIR" ]; then
    for domain_dir in "$DOMAINS_DIR"/w.*; do
        [ -d "$domain_dir" ] || continue

        dirname=$(basename "$domain_dir")
        domain="${dirname#w.}"

        echo "" >> "$OUT"
        echo "*.$domain {" >> "$OUT"
        echo -e "\timport global" >> "$OUT"
        echo >> "$OUT"

        for sub_file in "$domain_dir"/*; do
            [ -f "$sub_file" ] || continue
            sub=$(basename "$sub_file")

            echo -e "\t@$sub host $sub.$domain" >> "$OUT"
            echo -e "\thandle @$sub {" >> "$OUT"
            while IFS= read -r line; do
                echo "        $line" >> "$OUT"
            done < "$sub_file"
            echo -e "\t}" >> "$OUT"
        done

        echo -e "\trespond \"404 not found\"" >> "$OUT"

        echo "}" >> "$OUT"
    done
fi

if caddy reload --config "$OUT" 2>/dev/null; then
    echo "caddy reloaded"
else
    echo "couldn't reload caddy"
    echo "this is expected on container startup and is an issue if container is already running"
fi
