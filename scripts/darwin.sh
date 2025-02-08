#!/bin/sh
# Run `curl -fsSL https://darwin.aloshy.ai | bash` to run this script to automatically setup Mac (M Series)

set -e
nixconfig() { echo "${HOME}/.config/nix-darwin"; }
REPO_HOST=${GITHUB_SERVER_URL:-https://github.com}
REPO_PATH=${GITHUB_REPOSITORY:-aloshy-ai/nix}
RUNNER_USERNAME=$(whoami)
IS_CI=$([ "${CI}" = "true" ] && echo true || echo false)

curl -fsSL https://ascii.aloshy.ai | sh
echo "DETECTED $([ "$IS_CI" = true ] && echo "" || echo "NON-")CI ENVIRONMENT"
echo "FOUND $([ -n "${GITHUB_TOKEN}" ] && echo "" || echo "NO ")GITHUB_TOKEN"

echo "VERIFYING SYSTEM COMPATIBILITY"
DETECTED="$(uname -s)-$(uname -m)"
[ "$(echo "${DETECTED}" | tr '[:upper:]' '[:lower:]')" = "darwin-arm64" ] || { echo "ERROR: SYSTEM MUST BE AN APPLE SILICON MAC (M1/M2/M3). DETECTED: ${DETECTED}" && exit 1; }

echo "INSTALLING NIX"
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --force --no-confirm
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

echo "BACKING UP SHELL PROFILES BEFORE NIX DARWIN"
[ ! -f /etc/bashrc.before-nix-darwin ] && sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
[ ! -f /etc/zshrc.before-nix-darwin ] && sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin

echo "DOWLOADING NIX-DARWIN FLAKE CONFIGS"
mkdir -p "$(nixconfig)"
curl -sSLO "${REPO_HOST}/${REPO_PATH}/archive/refs/heads/main.zip"
unzip -qq main.zip
mv nix-main/* "$(nixconfig)/"
rm -rf main.zip nix-main

echo "BUILDING AND ACTIVATING SYSTEM CONFIGURATION"
cd $(nixconfig)
FLAKE_HOSTNAME=$(grep -A 1 'hostnames = {' $(nixconfig)/flake.nix | grep 'darwin' | sed 's/.*darwin = "\([^"]*\)".*/\1/')

[ -n "${GITHUB_TOKEN}" ] && export NIX_CONFIG="access-tokens = github.com=${GITHUB_TOKEN}"
nix run nix-darwin/master#darwin-rebuild -- switch --flake .#${FLAKE_HOSTNAME} --impure
echo "SYSTEM SETUP COMPLETED SUCCESSFULLY"

[ "$IS_CI" = true ] && {
    echo "REVERTING GITHUB ACTIONS USERNAME BACK TO ${RUNNER_USERNAME} FOR GRACEFUL CLEANUP"
    CURRENT_USERNAME=$(whoami)
    echo "SETTING UP SUDO PRIVILEGES FOR ${RUNNER_USERNAME}"
    echo "${RUNNER_USERNAME} ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/${RUNNER_USERNAME}
    echo "RENAMING USER ${CURRENT_USERNAME} TO ${RUNNER_USERNAME}"
    sudo dscl . -change /Users/${CURRENT_USERNAME} RecordName ${CURRENT_USERNAME} ${RUNNER_USERNAME}
    echo "MOVING HOME FOLDER /Users/${CURRENT_USERNAME} TO /Users/${RUNNER_USERNAME}"
    [ -d "/Users/${CURRENT_USERNAME}" ] && sudo mv /Users/${CURRENT_USERNAME} /Users/${RUNNER_USERNAME}
    sudo dscl . -change /Users/${RUNNER_USERNAME} NFSHomeDirectory /Users/${CURRENT_USERNAME} /Users/${RUNNER_USERNAME}
    echo "UPDATING ENVIRONMENT VARIABLES [USER=${RUNNER_USERNAME} HOME=/Users/${RUNNER_USERNAME} LOGNAME=${RUNNER_USERNAME}]"
    export USER="${RUNNER_USERNAME}"
    export HOME="/Users/${RUNNER_USERNAME}"
    export LOGNAME="${RUNNER_USERNAME}"
}
