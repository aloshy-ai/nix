#!/bin/sh

set -e

# ASCII art
curl -fsSL https://ascii.aloshy.ai | bash

# Install nix (if not already installed)
if ! command -v nix >/dev/null 2>&1; then
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
fi

# Get current system using uname
case "$(uname -s)-$(uname -m)" in
 "Darwin-arm64") SYSTEM="aarch64-darwin" ;;
 "Darwin-x86_64") SYSTEM="x86_64-darwin" ;;
 *)
   echo "Unsupported system: $(uname -s)-$(uname -m)"
   exit 1
   ;;
esac

echo "Detected system: $SYSTEM"

# Setup Darwin configuration
echo "Setting up Darwin configuration..."
nix-env -iA nixos.pciutils
sudo nix-channel --add https://github.com/LnL7/nix-darwin/archive/master.tar.gz darwin
sudo nix-channel --update
nix run  --extra-experimental-features "nix-command flakes" nix-darwin/master#darwin-rebuild -- switch
nix shell --extra-experimental-features "nix-command flakes" -c fh apply nix-darwin "aloshy-ai/nix/1.0.5#darwinConfigurations.ethermac"
nix shell --extra-experimental-features "nix-command flakes" -c fh apply nix-darwin "aloshy-ai/nix/1.0.5"
