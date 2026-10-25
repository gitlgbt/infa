#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

$SUDO apt update
$SUDO apt upgrade -y

echo "pull gitlgbt/infa"
git pull
# delete and re add to be safe
echo "cleaning up theme"
rm -rf theme

echo "pull gitlgbt/theme"
git submodule update --init --recursive --remote --merge

echo "pull docker file"
docker compose pull

echo "restart CT"
docker compose up -d --force-recreate

echo "all good"