#!/bin/sh
# Run `curl -fsSL https://darwin.aloshy.ai | bash` to run this script to automatically setup Mac (M Series)

set -e
nixconfig() { echo "${HOME}/.config/nix-darwin"; }
REPO_HOST=${GITHUB_SERVER_URL:-https://github.com}
REPO_PATH=${GITHUB_REPOSITORY:-aloshy-ai/nix}
LEGACY_USERNAME=$USER
VOLUME_NAME="Nix Store"
SHELL=$(echo /bin/${SHELL:-zsh})
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
FLAKE_USERNAME=$(grep 'username = "' $(nixconfig)/flake.nix | sed 's/.*username = "\([^"]*\)".*/\1/')
[ -z "$FLAKE_HOSTNAME" ] && echo "ERROR: INVALID CONFIGURATION FILE. HOSTNAME NOT FOUND IN FLAKE.NIX" && exit 1
[ -z "$FLAKE_USERNAME" ] && echo "ERROR: INVALID CONFIGURATION FILE. USERNAME NOT FOUND IN FLAKE.NIX" && exit 1

echo "ASSERTING HOSTNAME TO: ${FLAKE_HOSTNAME}"
if [ "$(hostname)" != "${FLAKE_HOSTNAME}" ]; then
    echo "CHANGING HOSTNAMES FROM $(hostname) to ${FLAKE_HOSTNAME}"
    sudo scutil --set ComputerName "${FLAKE_HOSTNAME}"
    sudo scutil --set LocalHostName "${FLAKE_HOSTNAME}"
    sudo scutil --set HostName "${FLAKE_HOSTNAME}"
    echo "HOSTNAMES SET SUCCESSFULLY: $(hostname)"
fi

# echo "ASSERTING USERNAME TO: ${FLAKE_USERNAME}"
# if [ "$(whoami)" != "${FLAKE_USERNAME}" ]; then
#     echo "SETTING UP SUDO PRIVILEGES FOR: ${FLAKE_USERNAME}"
#     echo "${FLAKE_USERNAME} ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/${FLAKE_USERNAME}
#     echo "RENAMING $(whoami) TO ${FLAKE_USERNAME}"
#     sudo dscl . -change /Users/$(whoami) RecordName $(whoami) ${FLAKE_USERNAME}
#     echo "CHANGING HOME FOLDER FROM /Users/${LEGACY_USERNAME} TO /Users/$(whoami)"
#     sudo dscl . -change /Users/$(whoami) NFSHomeDirectory /Users/${LEGACY_USERNAME} /Users/$(whoami)
#     # echo "RENAMING HOME FOLDER FROM /Users/${LEGACY_USERNAME} TO /Users/$(whoami)"
#     # [ -d "/Users/${LEGACY_USERNAME}" ] && sudo mv /Users/${LEGACY_USERNAME} /Users/$(whoami)
#     # echo "GIVING PERMISSION ON /Users/$(whoami) FOR $(whoami)"
#     # sudo chown -R $(whoami):staff /Users/$(whoami)
#     # echo "RE-EXPORTING USER & HOME VARIABLE AS $(whoami) & /Users/$(whoami) RESPECTIVELY"
#     # export USER=$(whoami)
#     # export HOME="/Users/$(whoami)"
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
nix ${GITHUB_TOKEN:+--option access-tokens "github.com=${GITHUB_TOKEN}"} run nix-darwin/master#darwin-rebuild -- switch --flake .#$(hostname) --impure

echo "SYSTEM SETUP COMPLETED SUCCESSFULLY"
