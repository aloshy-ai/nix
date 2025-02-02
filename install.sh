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

echo "INSTALLING NIX"
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate --force --no-confirm

echo "SOURCING NIX"
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

echo "ADDING NIX-DARWIN CHANNEL"
sudo nix-channel --add https://github.com/LnL7/nix-darwin/archive/master.tar.gz darwin
sudo nix-channel --update

echo "INSTALLING NIX-DARWIN"
nix run  --extra-experimental-features "nix-command flakes" nix-darwin/master#darwin-rebuild -- switch

echo "APPLYING ETHERMAC CONFIG"
nix shell --extra-experimental-features "nix-command flakes" -c fh apply nix-darwin "aloshy-ai/nix/1.0.5#darwinConfigurations.ethermac"
nix shell --extra-experimental-features "nix-command flakes" -c fh apply nix-darwin "aloshy-ai/nix/1.0.5"
