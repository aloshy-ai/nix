#!/bin/sh
# Run `curl -fsSL https://darwin.aloshy.ai | bash` to run this script to automatically setup Mac (M Series)

set -e
REPO_HOST=${GITHUB_SERVER_URL:-https://github.com}
REPO_PATH=${GITHUB_REPOSITORY:-aloshy-ai/nix}
CURRENT_HOSTNAME=$(scutil --get LocalHostName)
CURRENT_USERNAME=$(whoami)

echo "STARTING SETUP FOR MAC ${CURRENT_HOSTNAME}"
curl -fsSL https://ascii.aloshy.ai | bash

echo "VERIFYING SYSTEM COMPATIBILITY"
DETECTED="$(uname -s)-$(uname -m)"
[ "$(echo $DETECTED | tr '[:upper:]' '[:lower:]')" = "darwin-arm64" ] || { echo "ERROR: SYSTEM MUST BE AN APPLE SILICON MAC (M1/M2/M3). DETECTED: $DETECTED" && exit 1; }

echo "CLEANING UP PREVIOUS NIX INSTALLATION"
sudo /nix/nix-installer uninstall -- --force 2>/dev/null || true

echo "INSTALLING NIX PACKAGE MANAGER"
[ ! -f /etc/bashrc.before-nix-darwin ] && sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
[ ! -f /etc/zshrc.before-nix-darwin ] && sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin

if ! curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --force --no-confirm; then
    echo "ERROR: NIX INSTALLATION FAILED. CHECK YOUR INTERNET CONNECTION AND TRY AGAIN" && exit 1
fi
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

echo "DOWNLOADING SYSTEM CONFIGURATION FROM ${REPO_HOST}/${REPO_PATH}"
DARWIN_CONFIG_DIR=${HOME}/.config/nix-darwin
[ -d "${DARWIN_CONFIG_DIR}" ] && echo "BACKING UP PREVIOUS CONFIGURATION TO ${DARWIN_CONFIG_DIR}.backup" && mv "${DARWIN_CONFIG_DIR}" "${DARWIN_CONFIG_DIR}.backup"
if ! nix shell ${GITHUB_TOKEN:+--option access-tokens "github.com=${GITHUB_TOKEN}"} nixpkgs#git -c git clone -q ${REPO_HOST}/${REPO_PATH} $DARWIN_CONFIG_DIR; then
    echo "ERROR: FAILED TO DOWNLOAD CONFIGURATION. CHECK YOUR INTERNET CONNECTION AND GITHUB ACCESS" && exit 1
fi

echo "CUSTOMIZING CONFIGURATION FOR ${CURRENT_USERNAME}@${CURRENT_HOSTNAME}"
FLAKE_HOSTNAME=$(grep -A 1 'hostnames = {' ${DARWIN_CONFIG_DIR}/flake.nix | grep 'darwin' | sed 's/.*darwin = "\([^"]*\)".*/\1/')
FLAKE_USERNAME=$(grep 'username = "' ${DARWIN_CONFIG_DIR}/flake.nix | sed 's/.*username = "\([^"]*\)".*/\1/')
[ -z "$FLAKE_HOSTNAME" ] && echo "ERROR: INVALID CONFIGURATION FILE. HOSTNAME NOT FOUND IN FLAKE.NIX" && exit 1
[ -z "$FLAKE_USERNAME" ] && echo "ERROR: INVALID CONFIGURATION FILE. USERNAME NOT FOUND IN FLAKE.NIX" && exit 1

echo "UPDATING SYSTEM IDENTIFIERS"
if ! sed -i '' "s/${FLAKE_HOSTNAME}/${CURRENT_HOSTNAME}/" ${DARWIN_CONFIG_DIR}/flake.nix || \
   ! sed -i '' "s/${FLAKE_USERNAME}/${CURRENT_USERNAME}/" ${DARWIN_CONFIG_DIR}/flake.nix; then
    echo "ERROR: FAILED TO UPDATE SYSTEM CONFIGURATION. CHECK FILE PERMISSIONS" && exit 1
fi

echo "BUILDING AND ACTIVATING SYSTEM CONFIGURATION"
cd ${DARWIN_CONFIG_DIR}
if ! nix ${GITHUB_TOKEN:+--option access-tokens "github.com=${GITHUB_TOKEN}"} run nix-darwin/master#darwin-rebuild -- switch --flake .#${CURRENT_HOSTNAME}; then
    echo "ERROR: SYSTEM BUILD FAILED. CHECK THE ERROR MESSAGE ABOVE" && exit 1
fi

echo "SYSTEM SETUP COMPLETED SUCCESSFULLY. RESTART TERMINAL"
