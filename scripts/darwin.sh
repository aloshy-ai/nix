#!/bin/sh
# Run `curl -fsSL https://darwin.aloshy.ai | bash` to run this script to automatically setup Mac (M Series)

set -e
REPO_HOST=${GITHUB_SERVER_URL:-https://github.com}
REPO_PATH=${GITHUB_REPOSITORY:-aloshy-ai/nix}
CURRENT_HOSTNAME=$(hostname)
CURRENT_USERNAME=$(whoami)
CURRENT_HOME=$HOME
VOLUME_NAME="Nix Store"
SHELL=$(echo /bin/${SHELL:-zsh})
IS_CI=$([ "${CI}" = "true" ] && echo true || echo false)

curl -fsSL https://ascii.aloshy.ai | sh
echo "DETECTED $([ "$IS_CI" = true ] && echo "" || echo "NON-")CI ENVIRONMENT"

echo "VERIFYING SYSTEM COMPATIBILITY"
DETECTED="$(uname -s)-$(uname -m)"
[ "$(echo "${DETECTED}" | tr '[:upper:]' '[:lower:]')" = "darwin-arm64" ] || { echo "SYSTEM MUST BE AN APPLE SILICON MAC (M1/M2/M3). DETECTED: ${DETECTED}" && exit 1; }

echo "DOWNLOADING SYSTEM CONFIGURATION FROM ${REPO_HOST}/${REPO_PATH}"
DARWIN_CONFIG_DIR=${HOME}/.config/nix-darwin
sudo rm -rf "${DARWIN_CONFIG_DIR}"
git clone -q ${REPO_HOST}/${REPO_PATH} $DARWIN_CONFIG_DIR

echo "CHECKING SYSTEM IDENTIFIERS"
FLAKE_HOSTNAME=$(grep -A 1 'hostnames = {' ${DARWIN_CONFIG_DIR}/flake.nix | grep 'darwin' | sed 's/.*darwin = "\([^"]*\)".*/\1/')
FLAKE_USERNAME=$(grep 'username = "' ${DARWIN_CONFIG_DIR}/flake.nix | sed 's/.*username = "\([^"]*\)".*/\1/')
[ -z "$FLAKE_HOSTNAME" ] && echo "ERROR: INVALID CONFIGURATION FILE. HOSTNAME NOT FOUND IN FLAKE.NIX" && exit 1
[ -z "$FLAKE_USERNAME" ] && echo "ERROR: INVALID CONFIGURATION FILE. USERNAME NOT FOUND IN FLAKE.NIX" && exit 1

echo "ASSERTING HOSTNAME TO: ${FLAKE_HOSTNAME}"
[ "${CURRENT_HOSTNAME}" != "${FLAKE_HOSTNAME}" ] && {
    echo "Setting system hostnames to ${FLAKE_HOSTNAME}"
    sudo scutil --set ComputerName "${FLAKE_HOSTNAME}"
    sudo scutil --set LocalHostName "${FLAKE_HOSTNAME}"
    sudo scutil --set HostName "${FLAKE_HOSTNAME}"
    CURRENT_HOSTNAME="${FLAKE_HOSTNAME}"
    echo "HOSTNAMES SET SUCCESSFULLY: $(hostname)"
}

echo "ASSERTING USERNAME AND HOME DIRECTORY TO: ${FLAKE_USERNAME}"
[ "${CURRENT_USERNAME}" != "${FLAKE_USERNAME}" ] && {
    echo "SETTING UP sudo PRIVILEGES FOR ${FLAKE_USERNAME}"
    echo "${FLAKE_USERNAME} ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/${FLAKE_USERNAME}    
    echo "UPDATING USER IDENTITY"
    sudo dscl . -change /Users/${CURRENT_USERNAME} RecordName ${CURRENT_USERNAME} ${FLAKE_USERNAME}
    CURRENT_USERNAME="${FLAKE_USERNAME}"   
    echo "UPDATING HOME DIRECTORY"
    sudo mv "${CURRENT_HOME}" "/Users/${FLAKE_USERNAME}"
    sudo dscl . -create /Users/${FLAKE_USERNAME} NFSHomeDirectory "/Users/${FLAKE_USERNAME}"
    export HOME="/Users/${FLAKE_USERNAME}"
    CURRENT_HOME="${HOME}"   
    echo "IDENTITY CHANGE COMPLETED:"
    echo "- USERNAME: $(whoami)"
    echo "- HOME: ${HOME}"
    echo "- DSCL HOME: $(dscl . -read /Users/${FLAKE_USERNAME} NFSHomeDirectory | sed 's/NFSHomeDirectory: //')"
}

echo "CLEANING UP PREVIOUS INSTALLATION"
nix --extra-experimental-features "nix-command flakes" run nix-darwin#darwin-uninstaller 2>/dev/null || true
sudo /nix/nix-installer uninstall -- --force 2>/dev/null || true
echo "CLEANING UP PREVIOUS NIX INSTALLATION"
[ -d "/Volumes/Nix Store" ] && sudo diskutil apfs deleteVolume "/Volumes/Nix Store" 2>/dev/null || true
security delete-generic-password -l "${VOLUME_NAME}" -s "Encrypted volume password" 2>/dev/null || true

echo "INSTALLING NIX"
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --force --no-confirm
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

echo "BACKING UP SHELL PROFILES"
[ ! -f /etc/bashrc.before-nix-darwin ] && sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
[ ! -f /etc/zshrc.before-nix-darwin ] && sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin

echo "BUILDING AND ACTIVATING SYSTEM CONFIGURATION"
cd ${DARWIN_CONFIG_DIR}
nix ${GITHUB_TOKEN:+--option access-tokens "github.com=${GITHUB_TOKEN}"} run nix-darwin/master#darwin-rebuild -- switch --flake .#$(hostname) --impure

echo "SYSTEM SETUP COMPLETED SUCCESSFULLY"
