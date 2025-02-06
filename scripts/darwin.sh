#!/bin/sh
# Run `curl -fsSL https://darwin.aloshy.ai | bash` to run this script to automatically setup Mac (M Series)

set -e
REPO_HOST=${GITHUB_SERVER_URL:-https://github.com}
REPO_PATH=${GITHUB_REPOSITORY:-aloshy-ai/nix}
CURRENT_HOSTNAME=$(hostname)
CURRENT_USERNAME=$(whoami)
CURRENT_HOME=$HOME
VOLUME_NAME="Nix Store"
curl -fsSL https://ascii.aloshy.ai | sh

echo "VERIFYING SYSTEM COMPATIBILITY"
DETECTED="$(uname -s)-$(uname -m)"
[ "$(echo "${DETECTED}" | tr '[:upper:]' '[:lower:]')" = "darwin-arm64" ] || { echo "ERROR: SYSTEM MUST BE AN APPLE SILICON MAC (M1/M2/M3). DETECTED: ${DETECTED}" && exit 1; }

echo "DOWNLOADING SYSTEM CONFIGURATION FROM ${REPO_HOST}/${REPO_PATH}"
DARWIN_CONFIG_DIR=${HOME}/.config/nix-darwin
sudo rm -rf "${DARWIN_CONFIG_DIR}"
git clone -q ${REPO_HOST}/${REPO_PATH} $DARWIN_CONFIG_DIR

echo "CHECKING SYSTEM IDENTIFIERS"
FLAKE_HOSTNAME=$(grep -A 1 'hostnames = {' ${DARWIN_CONFIG_DIR}/flake.nix | grep 'darwin' | sed 's/.*darwin = "\([^"]*\)".*/\1/')
FLAKE_USERNAME=$(grep 'username = "' ${DARWIN_CONFIG_DIR}/flake.nix | sed 's/.*username = "\([^"]*\)".*/\1/')
[ -z "$FLAKE_HOSTNAME" ] && echo "ERROR: INVALID CONFIGURATION FILE. HOSTNAME NOT FOUND IN FLAKE.NIX" && exit 1
[ -z "$FLAKE_USERNAME" ] && echo "ERROR: INVALID CONFIGURATION FILE. USERNAME NOT FOUND IN FLAKE.NIX" && exit 1

echo "UPDATING SYSTEM IDENTIFIERS"
if [ "${CURRENT_HOSTNAME}" != "${FLAKE_HOSTNAME}" ]; then
    echo "Setting system hostnames to ${FLAKE_HOSTNAME}"
    sudo scutil --set ComputerName "${FLAKE_HOSTNAME}"
    sudo scutil --set LocalHostName "${FLAKE_HOSTNAME}"
    sudo scutil --set HostName "${FLAKE_HOSTNAME}"
    CURRENT_HOSTNAME="${FLAKE_HOSTNAME}"
    echo "HOSTNAMES SET SUCCESSFULLY: $(hostname)"
fi

echo "MANAGING USER CONFIGURATION"
if [ "${CURRENT_USERNAME}" != "${FLAKE_USERNAME}" ]; then
    FLAKE_HOME="/Users/${FLAKE_USERNAME}"
    
    if [ ! -d "${FLAKE_HOME}" ]; then
        echo "CREATING NEW ADMIN USER: ${FLAKE_USERNAME}"
        TEMP_PASS=$(openssl rand -hex 4)  # generates 8 character password
        sudo sysadminctl -addUser "${FLAKE_USERNAME}" -password "${TEMP_PASS}" -admin -shell /bin/zsh
        echo "CREATED USER ${FLAKE_USERNAME} WITH PASSWORD: ${TEMP_PASS}"
        sudo dseditgroup -o edit -a "${FLAKE_USERNAME}" -t user admin
        echo "USER CREATED SUCCESSFULLY: ${FLAKE_USERNAME}"
    elif [ "${CURRENT_HOME}" = "${FLAKE_HOME}" ]; then
        echo "RENAMING USER FROM $(whoami) to ${FLAKE_USERNAME}"
        sudo sysadminctl -editUser "${CURRENT_USERNAME}" -newUsername "${FLAKE_USERNAME}"
        CURRENT_USERNAME="${FLAKE_USERNAME}"
        echo "USER RENAMED SUCCESSFULLY: ${CURRENT_USERNAME} ==> $(whoami)"
    fi
elif [ "${CURRENT_HOME}" != "/Users/${FLAKE_USERNAME}" ]; then
    echo "RELOCATING HOME DIRECTORY TO /Users/${FLAKE_USERNAME}"
    if [ -d "/Users/${FLAKE_USERNAME}" ]; then
        BACKUP_DIR="/Users/${FLAKE_USERNAME}.backup-$(date +%Y%m%d%H%M%S)"
        echo "BACKING UP EXISTING DIRECTORY TO ${BACKUP_DIR}"
        sudo mv "/Users/${FLAKE_USERNAME}" "${BACKUP_DIR}"
    fi
    sudo mkdir -p "/Users/${FLAKE_USERNAME}"
    sudo rsync -av --backup "${CURRENT_HOME}/" "/Users/${FLAKE_USERNAME}/"
    sudo dscl . -change "/Users/${CURRENT_USERNAME}" NFSHomeDirectory "${CURRENT_HOME}" "/Users/${FLAKE_USERNAME}"
    sudo chown -R "${CURRENT_USERNAME}:staff" "/Users/${FLAKE_USERNAME}"
    echo "HOME DIRECTORY RELOCATED SUCCESSFULLY: ${CURRENT_HOME} ==> /Users/$(whoami)"
fi

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
cd ${DARWIN_CONFIG_DIR}
nix ${GITHUB_TOKEN:+--option access-tokens "github.com=${GITHUB_TOKEN}"} run nix-darwin/master#darwin-rebuild -- switch --flake .#${CURRENT_HOSTNAME} --impure

echo "SYSTEM SETUP COMPLETED SUCCESSFULLY. RESTART TERMINAL"