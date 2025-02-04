#!/bin/sh
# Run `curl -fsSL https://darwin.aloshy.ai | bash` to run this script to automatically setup Mac (M Series)

set -e
REPO_HOST=${GITHUB_SERVER_URL:-https://github.com}
REPO_PATH=${GITHUB_REPOSITORY:-aloshy-ai/nix}
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
export HOSTNAME=$(grep 'darwin = "' ${DARWIN_CONFIG_DIR}/flake.nix | sed 's/.*darwin = "\([^"]*\)".*/\1/')

echo "ENSURING USER EXISTENCE"
echo "FETCHING USER CONFIG FROM FLAKE"
export USERNAME=$(grep 'username = "' ${DARWIN_CONFIG_DIR}/flake.nix | sed 's/.*username = "\([^"]*\)".*/\1/')
export FULLNAME=$(grep 'fullName = "' ${DARWIN_CONFIG_DIR}/flake.nix | sed 's/.*fullName = "\([^"]*\)".*/\1/')

echo "CREATING USER IF NOT EXISTS"
if ! dscl . -read /Users/$USERNAME &>/dev/null; then
  sudo dscl . -create /Users/$USERNAME
  sudo dscl . -create /Users/$USERNAME UserShell /bin/zsh
  sudo dscl . -create /Users/$USERNAME RealName "$FULLNAME"
  sudo dscl . -create /Users/$USERNAME UniqueID "501"
  sudo dscl . -create /Users/$USERNAME PrimaryGroupID 20
  sudo dscl . -create /Users/$USERNAME NFSHomeDirectory /Users/$USERNAME
  sudo mkdir -p /Users/$USERNAME
  sudo chown $USERNAME:staff /Users/$USERNAME
fi

echo "INSTALLING NIX-DARWIN ${GITHUB_TOKEN:+USING AUTHENTICATED GITHUB REQUESTS}"
cd $DARWIN_CONFIG_DIR
nix ${GITHUB_TOKEN:+--option access-tokens "github.com=${GITHUB_TOKEN}"} run nix-darwin/master#darwin-rebuild -- switch --flake .#${HOSTNAME}
