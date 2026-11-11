#!/bin/bash
set -e
set -o pipefail
cd "$(dirname "$0")"

if [ "$EUID" -ne 0 ]; then SUDO="sudo"; else SUDO=""; fi

PRIMARY="https://git.lgbt/gitlgbt"
FALLBACK="https://github.com/gitlgbt"  

$SUDO apt update
$SUDO apt upgrade -y

TMP=$(mktemp -d ./.update.XXXXXX)
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/theme"


fetch() {
    repo="$1"; dest="$2"; shift 2
    patterns=()
    for p in "$@"; do patterns+=("*/$p"); done

    for base in "$PRIMARY" "$FALLBACK"; do
        if [ "$base" = "$PRIMARY" ]; then
            url="$base/$repo/archive/main.tar.gz"
        else
            url="$base/$repo/archive/refs/heads/main.tar.gz"
        fi
        echo "downloading $repo from $base"
        if curl -fsSL --retry 2 "$url" \
            | tar -xz -C "$dest" --strip-components=1 --wildcards "${patterns[@]}"; then
            return 0
        fi
        echo "failed from $base, trying next"
    done
    echo "could not download $repo" >&2
    return 1
}

fetch infa  "$TMP"       docker-compose.yml update.sh install.sh
fetch theme "$TMP/theme" public templates options

for d in public templates options; do
    [ -d "$TMP/theme/$d" ] || { echo "theme/$d missing, aborting" >&2; exit 1; }
done
chmod +x "$TMP/update.sh" "$TMP/install.sh"


rm -rf theme
mv "$TMP/theme" theme
mv "$TMP/docker-compose.yml" docker-compose.yml
mv "$TMP/install.sh" install.sh
mv "$TMP/update.sh" update.sh   
echo "pull docker image"
docker compose pull

echo "restart CT"
docker compose up -d --force-recreate

docker image prune -f
echo "all good"