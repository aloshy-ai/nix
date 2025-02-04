#!/bin/sh
# Run `curl -fsSL https://darwin.aloshy.ai | bash` to run this script to automatically setup Mac (M Series)

set -e
REPO_HOST=${GITHUB_SERVER_URL:-https://github.com}
REPO_PATH=${GITHUB_REPOSITORY:-aloshy-ai/nix}
CURRENT_HOSTNAME=$(scutil --get LocalHostName)
CURRENT_USERNAME=$(whoami)

curl -fsSL https://ascii.aloshy.ai | bash

echo "ENSURING MAC COMPATIBILITY"
DETECTED="$(uname -s)-$(uname -m)"
[ "$(echo $DETECTED | tr '[:upper:]' '[:lower:]')" = "darwin-arm64" ] || { echo "INCOMPATIBLE SYSTEM DETECTED: $DETECTED" && exit 1; }

echo "CHECKING FOR EXISTING BACKUPS"
[ -f /etc/bashrc.before-nix-darwin ] && echo "Backup /etc/bashrc.before-nix-darwin already exists" && exit 1
[ -f /etc/zshrc.before-nix-darwin ] && echo "Backup /etc/zshrc.before-nix-darwin already exists" && exit 1

echo "UNINSTALLING OLD NIX"
sudo /nix/nix-installer uninstall -- --force 2>/dev/null || true

echo "INSTALLING NEW NIX"
sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin

if ! curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --force --no-confirm; then
    echo "Failed to install Nix" && exit 1
fi
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

echo "FETCHING NIX-DARWIN CONFIG ${GITHUB_TOKEN:+USING AUTHENTICATED GITHUB REQUESTS}"
DARWIN_CONFIG_DIR=${HOME}/.config/nix-darwin
[ -d "${DARWIN_CONFIG_DIR}" ] && echo "Backing up existing config" && mv "${DARWIN_CONFIG_DIR}" "${DARWIN_CONFIG_DIR}.backup"
if ! nix shell ${GITHUB_TOKEN:+--option access-tokens "github.com=${GITHUB_TOKEN}"} nixpkgs#git -c git clone -q ${REPO_HOST}/${REPO_PATH} $DARWIN_CONFIG_DIR; then
    echo "Failed to clone repository" && exit 1
fi

echo "LOCALIZING NIX-DARWIN CONFIG"
FLAKE_HOSTNAME=$(grep -A 1 'hostnames = {' ${DARWIN_CONFIG_DIR}/flake.nix | grep 'darwin' | sed 's/.*darwin = "\([^"]*\)".*/\1/')
FLAKE_USERNAME=$(grep 'username = "' ${DARWIN_CONFIG_DIR}/flake.nix | sed 's/.*username = "\([^"]*\)".*/\1/')
[ -z "$FLAKE_HOSTNAME" ] && echo "Failed to extract hostname from flake.nix" && exit 1
[ -z "$FLAKE_USERNAME" ] && echo "Failed to extract username from flake.nix" && exit 1

if ! sed -i '' "s/${FLAKE_HOSTNAME}/${CURRENT_HOSTNAME}/" ${DARWIN_CONFIG_DIR}/flake.nix || \
   ! sed -i '' "s/${FLAKE_USERNAME}/${CURRENT_USERNAME}/" ${DARWIN_CONFIG_DIR}/flake.nix; then
    echo "Failed to update flake.nix configuration" && exit 1
fi

echo "INSTALLING NIX-DARWIN ${GITHUB_TOKEN:+USING AUTHENTICATED GITHUB REQUESTS}"
cd ${DARWIN_CONFIG_DIR}
if ! nix ${GITHUB_TOKEN:+--option access-tokens "github.com=${GITHUB_TOKEN}"} run nix-darwin/master#darwin-rebuild -- switch --flake .#${CURRENT_HOSTNAME}; then
    echo "Failed to build and activate configuration" && exit 1
fi

echo "INSTALLATION SUCCESSFUL"
