#!/bin/sh
# Run `curl -fsSL https://darwin.aloshy.ai | bash` to run this script to automatically setup Mac (M Series)

set -e
nixconfig() { echo "${HOME}/.config/nix-darwin"; }
REPO_HOST=${GITHUB_SERVER_URL:-https://github.com}
REPO_PATH=${GITHUB_REPOSITORY:-aloshy-ai/nix}
IS_CI=$([ "${CI}" = "true" ] && echo true || echo false)

curl -fsSL https://ascii.aloshy.ai | sh
echo "DETECTED $([ "$IS_CI" = true ] && echo "" || echo "NON-")CI ENVIRONMENT"

echo "VERIFYING SYSTEM COMPATIBILITY"
DETECTED="$(uname -s)-$(uname -m)"
[ "$(echo "${DETECTED}" | tr '[:upper:]' '[:lower:]')" = "darwin-arm64" ] || { echo "ERROR: SYSTEM MUST BE AN APPLE SILICON MAC (M1/M2/M3). DETECTED: ${DETECTED}" && exit 1; }

echo "DOWNLOADING SYSTEM CONFIGURATION FROM ${REPO_HOST}/${REPO_PATH}"
sudo rm -rf "$(nixconfig)"
git clone -q ${REPO_HOST}/${REPO_PATH} $(nixconfig)

echo "CHECKING SYSTEM IDENTIFIERS"
FLAKE_HOSTNAME=$(grep -A 1 'hostnames = {' $(nixconfig)/flake.nix | grep 'darwin' | sed 's/.*darwin = "\([^"]*\)".*/\1/')
[ -z "$FLAKE_HOSTNAME" ] && echo "ERROR: INVALID CONFIGURATION FILE. HOSTNAME NOT FOUND IN FLAKE.NIX" && exit 1

# echo "ASSERTING HOSTNAME TO: ${FLAKE_HOSTNAME}"
# if [ "$(hostname)" != "${FLAKE_HOSTNAME}" ]; then
#     echo "CHANGING HOSTNAMES FROM $(hostname) to ${FLAKE_HOSTNAME}"
#     sudo scutil --set ComputerName "${FLAKE_HOSTNAME}"
#     sudo scutil --set LocalHostName "${FLAKE_HOSTNAME}"
#     sudo scutil --set HostName "${FLAKE_HOSTNAME}"
#     echo "HOSTNAMES SET SUCCESSFULLY: $(hostname)"
# fi

echo "CLEANING UP PREVIOUS INSTALLATION"
nix --extra-experimental-features "nix-command flakes" run nix-darwin#darwin-uninstaller 2>/dev/null || true
sudo /nix/nix-installer uninstall -- --force 2>/dev/null || true
echo "CLEANING UP PREVIOUS NIX INSTALLATION"
[ -d "/Volumes/Nix Store" ] && sudo diskutil apfs deleteVolume "/Volumes/Nix Store" 2>/dev/null || true
security delete-generic-password -l "Nix Store" -s "Encrypted volume password" 2>/dev/null || true

echo "INSTALLING NIX"
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --force --no-confirm
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

echo "BACKING UP SHELL PROFILES"
[ ! -f /etc/bashrc.before-nix-darwin ] && sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
[ ! -f /etc/zshrc.before-nix-darwin ] && sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin

echo "BUILDING AND ACTIVATING SYSTEM CONFIGURATION"
cd $(nixconfig) 
nix ${GITHUB_TOKEN:+--option access-tokens "github.com=${GITHUB_TOKEN}"} run nix-darwin/master#darwin-rebuild -- switch --flake .#${FLAKE_HOSTNAME} --impure

echo "SYSTEM SETUP COMPLETED SUCCESSFULLY"
