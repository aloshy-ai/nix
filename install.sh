#!/bin/sh

set -e

# ASCII art
curl -fsSL https://ascii.aloshy.ai | bash

echo "ENSURING COMPATIBILITY"
DETECTED="$(uname -s)-$(uname -m)"
[ "$(echo $DETECTED | tr '[:upper:]' '[:lower:]')" = "darwin-arm64" ] || { echo "INCOMPATIBLE SYSTEM DETECTED: $DETECTED" && exit 1; }

echo "INSTALLING NIX"
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate --force --no-confirm

echo "SOURCING NIX"
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

echo "ADDING NIX-DARWIN CHANNEL"
sudo nix-channel --add https://github.com/LnL7/nix-darwin/archive/master.tar.gz darwin
sudo nix-channel --update

echo "CLONING NIX FLAKES"
export DARWIN_CONFIG_DIR=$HOME/.config/nix-darwin
rm -rf $DARWIN_CONFIG_DIR
nix shell nixpkgs#git -c git clone -q https://github.com/aloshy-ai/nix $DARWIN_CONFIG_DIR
cd $DARWIN_CONFIG_DIR

echo "INSTALLING NIX-DARWIN"
echo "${GITHUB_TOKEN:+USING AUTHENTICATED GITHUB REQUESTS}"
nix run nix-darwin -- switch --flake .#ethermac ${GITHUB_TOKEN:+--option access-tokens "github.com=${GITHUB_TOKEN}"}