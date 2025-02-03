#!/bin/sh

# ASCII art
set -e
curl -fsSL https://ascii.aloshy.ai | bash

echo "ENSURING COMPATIBILITY"
DETECTED="$(uname -s)-$(uname -m)"
[ "$(echo $DETECTED | tr '[:upper:]' '[:lower:]')" = "darwin-arm64" ] || { echo "INCOMPATIBLE SYSTEM DETECTED: $DETECTED" && exit 1; }

echo "INSTALLING NIX"
# curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate --force --no-confirm
curl -H "Cache-Control: no-cache" -L https://nixos.org/nix/install | sh -s -- --darwin-use-unencrypted-nix-store-volume --daemon


echo "SOURCING NIX"
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

echo "CLONING NIX FLAKES"
echo "${GITHUB_TOKEN:+USING AUTHENTICATED GITHUB REQUESTS}"
export DARWIN_CONFIG_DIR=$HOME/.config/nix-darwin
rm -rf $DARWIN_CONFIG_DIR
nix shell ${GITHUB_TOKEN:+--option access-tokens "github.com=${GITHUB_TOKEN}"} nixpkgs#git -c git clone -q https://github.com/aloshy-ai/nix $DARWIN_CONFIG_DIR
cd $DARWIN_CONFIG_DIR

echo "DELETE NIX-ENV PACKAGES"
sudo -i nix env --uninstall nix
sudo -i nix env --uninstall nss-cacert

echo "INSTALLING NIX-DARWIN"
echo "${GITHUB_TOKEN:+USING AUTHENTICATED GITHUB REQUESTS}"
nix ${GITHUB_TOKEN:+--option access-tokens "github.com=${GITHUB_TOKEN}"} run nix-darwin -- switch --flake .#ethermac --force
