#!/bin/bash
set -e

echo "pull gitlgbt/infa"
git pull

echo "pull gitlgbt/theme"
git submodule update --remote --merge

echo "pull docker file"
docker compose pull

echo "Starting git.lgbt"
docker compose up -d --force-recreate

echo "complete"


# tbh this is the same things as update i just think it look better to have to file lol