#!/usr/bin/env bash
# NixOS rebuild script

set -e

echo "Rebuilding NixOS..."
sudo nixos-rebuild switch --flake /etc/nixos#default --impure
echo "Done!"
