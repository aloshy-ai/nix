#!/bin/sh

set -e

# ASCII art
curl -fsSL https://ascii.aloshy.ai | bash

# Get current system using uname
case "$(uname -s)-$(uname -m)" in
 "Darwin-arm64") SYSTEM="aarch64-darwin" ;;
 "Darwin-x86_64") SYSTEM="x86_64-darwin" ;;
 *)
   echo "Unsupported system: $(uname -s)-$(uname -m)"
   exit 1
   ;;
esac

# Install nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate --force --no-confirm

# Setup Darwin configuration
# echo "Setting up Darwin configuration..."
# nix-env -iA nixos.pciutils
sudo nix-channel --add https://github.com/LnL7/nix-darwin/archive/master.tar.gz darwin
sudo nix-channel --update
nix run  --extra-experimental-features "nix-command flakes" nix-darwin/master#darwin-rebuild -- switch
nix shell --extra-experimental-features "nix-command flakes" -c fh apply nix-darwin "aloshy-ai/nix/1.0.5#darwinConfigurations.ethermac"
nix shell --extra-experimental-features "nix-command flakes" -c fh apply nix-darwin "aloshy-ai/nix/1.0.5"
