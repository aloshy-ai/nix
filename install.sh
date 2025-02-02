#!/bin/sh

set -e

# ASCII art
curl -fsSL https://ascii.aloshy.ai | bash

# Install nix (if not already installed)
if ! command -v nix >/dev/null 2>&1; then
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
fi

# Install the correct flake
case "$(nix run github:nix-systems/current-system)" in
 "aarch64-darwin" | "x86_64-darwin")
   nix-shell -p fh --run 'fh apply nix-darwin "flakehub://aloshy-ai/nix/*#ethermac"'
   ;;
 "x86_64-linux" | "aarch64-linux")
   nix-shell -p fh --run 'fh apply nixos "flakehub://aloshy-ai/nix/*#ethernix"'
   ;;
 *)
   echo "Unsupported system"
   exit 1
   ;;
esac