#!/bin/sh

set -e

# ASCII art
curl -fsSL https://ascii.aloshy.ai | bash

# Install nix (if not already installed)
if ! command -v nix >/dev/null 2>&1; then
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
fi

# Get current system using uname
case "$(uname -s)-$(uname -m)" in
 "Darwin-arm64") SYSTEM="aarch64-darwin" ;;
 "Darwin-x86_64") SYSTEM="x86_64-darwin" ;;
 "Linux-x86_64") SYSTEM="x86_64-linux" ;;
 "Linux-aarch64") SYSTEM="aarch64-linux" ;;
 *)
   echo "Unsupported system: $(uname -s)-$(uname -m)"
   exit 1
   ;;
esac

echo "Detected system: $SYSTEM"

case "$SYSTEM" in
 "aarch64-darwin" | "x86_64-darwin")
   echo "Setting up Darwin configuration..."
   nix shell --extra-experimental-features "nix-command flakes" \
     -c fh apply nix-darwin "aloshy-ai/nix/1.0.5"
   ;;
 "x86_64-linux" | "aarch64-linux")
   echo "Setting up NixOS configuration..."
   if [ ! -f /etc/nixos/hardware-configuration.nix ]; then
     sudo nixos-generate-config
   fi
   nix shell --extra-experimental-features "nix-command flakes" \
     -c sudo fh apply nixos "aloshy-ai/nix/1.0.5"
   ;;
esac
