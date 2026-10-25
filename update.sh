#!/bin/bash
set -e

sudo apt update
sudo apt upgrade -y

echo "pull gitlgbt/infa"
git pull

echo "pull gitlgbt/theme"
git submodule update --remote --merge

echo "pull docker file"
docker compose pull

echo "restart CT"
docker compose up -d --force-recreate

echo "all good"