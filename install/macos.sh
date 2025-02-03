#!/bin/sh
# Run `curl -fsSL https://macos.aloshy.ai | bash` to run this script to automatically setup Mac (M Series)

set -e
REPO_HOST=${GITHUB_SERVER_URL:-https://github.com}
REPO_PATH=${GITHUB_REPOSITORY:-aloshy-ai/nix}
HOSTNAME=$(scutil --get LocalHostName)
curl -fsSL https://ascii.aloshy.ai | bash

echo "ENSURING MAC COMPATIBILITY"
DETECTED="$(uname -s)-$(uname -m)"
[ "$(echo $DETECTED | tr '[:upper:]' '[:lower:]')" = "darwin-arm64" ] || { echo "INCOMPATIBLE SYSTEM DETECTED: $DETECTED" && exit 1; }

echo "INSTALLING DETERMINATE NIX"
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --force --no-confirm
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

echo "FETCHING NIX-DARWIN CONFIG ${GITHUB_TOKEN:+USING AUTHENTICATED GITHUB REQUESTS}"
export DARWIN_CONFIG_DIR=$HOME/.config/nix-darwin
rm -rf $DARWIN_CONFIG_DIR
nix shell ${GITHUB_TOKEN:+--option access-tokens "github.com=${GITHUB_TOKEN}"} nixpkgs#git -c git clone -q ${REPO_HOST}/${REPO_PATH} $DARWIN_CONFIG_DIR
sed -i '' "s/macos/$HOSTNAME/" ${DARWIN_CONFIG_DIR}/flake.nix

echo "INSTALLING NIX-DARWIN ${GITHUB_TOKEN:+USING AUTHENTICATED GITHUB REQUESTS}"
cd $DARWIN_CONFIG_DIR
nix ${GITHUB_TOKEN:+--option access-tokens "github.com=${GITHUB_TOKEN}"} run nix-darwin/master#darwin-rebuild -- switch --flake .#${HOSTNAME}
