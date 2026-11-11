#!/bin/bash
set -e
cd "$(dirname "$0")"

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
        $SUDO usermod -aG docker "$USER"
    fi
    echo "Docker installed"
else
    echo "Docker is already installed skip"
fi

echo "running update.sh"

if [ -n "$SUDO" ] && ! docker info &> /dev/null; then
    sg docker -c "./update.sh"
else
    ./update.sh
fi

echo "cleaning up files"
rm -rf .git .gitmodules .gitignore .dockerignore README.md LICENSE

echo "complete"