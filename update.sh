#!/bin/bash
set -e
set -o pipefail
cd "$(dirname "$0")"

if [ "$EUID" -ne 0 ]; then SUDO="sudo"; else SUDO=""; fi

PRIMARY="https://git.lgbt/gitlgbt"
FALLBACK="https://github.com/gitlgbt"
MONO_PRIMARY="https://git.lgbt/Fryrvo/forgejo_template"
MONO_FALLBACK="https://github.com/fryrvos/forgejo_template"

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

fetch_frontends() {
    for url in "$MONO_PRIMARY/archive/main.tar.gz" "$MONO_FALLBACK/archive/refs/heads/main.tar.gz"; do
        rm -rf "$TMP/mono" "$TMP/frontends"
        mkdir -p "$TMP/mono" "$TMP/frontends"
        echo "downloading forgejo_template from ${url%/archive/*}"
        if curl -fsSL --retry 2 "$url" | tar -xz -C "$TMP/mono" --strip-components=1; then
            for d in "$TMP/mono"/*/; do
                if [ -d "${d}templates" ] || [ -d "${d}public" ]; then
                    cp -r "$d" "$TMP/frontends/$(basename "$d")"
                fi
            done
            return 0
        fi
        echo "failed from ${url%/archive/*}, trying next"
    done
    return 1
}

fetch infa  "$TMP"       docker-compose.yml update.sh install.sh
fetch theme "$TMP/theme" public templates options

for d in public templates options; do
    [ -d "$TMP/theme/$d" ] || { echo "theme/$d missing, aborting" >&2; exit 1; }
done
chmod +x "$TMP/update.sh" "$TMP/install.sh"

if ! fetch_frontends; then
    echo "forgejo_template not available or empty, keeping current frontends" >&2
    rm -rf "$TMP/frontends"
    mkdir -p "$TMP/frontends"
    if [ -d theme/fryrvo_template_switcher ]; then
        cp -r theme/fryrvo_template_switcher/. "$TMP/frontends/"
    fi
fi
mv "$TMP/frontends" "$TMP/theme/fryrvo_template_switcher"
echo "frontends: $(ls "$TMP/theme/fryrvo_template_switcher" | tr '\n' ' ')"


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