#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    $SUDO apt update
    $SUDO apt install -y ca-certificates curl gnupg

    $SUDO install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    $SUDO chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      $SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null

    $SUDO apt update
    $SUDO apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    if [ -n "$SUDO" ]; then
        $SUDO usermod -aG docker $USER
    fi
    echo "Docker installed"
else
    echo "Docker is already installed skip"
fi

echo "pull gitlgbt/infa"
git pull


# here for some reason the submodule update is dumb or maybe i'm dumb just re add it
echo "cleaning up theme "
rm -rf theme

echo "pull gitlgbt/theme"
git submodule update --init --recursive --remote --merge

echo "pull docker file"
docker compose pull

echo "Starting git.lgbt"
docker compose up -d --force-recreate

echo "complete"