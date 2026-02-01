#!/usr/bin/env bash
# NixOS rebuild script

set -euo pipefail

# Detect which host to build based on username
if [[ "$USER" == "bunny" ]]; then
  HOST="pc"
else
  HOST="laptop"
fi

echo "Rebuilding NixOS for $HOST..."

# Remove Equicord settings.json so home-manager can recreate symlink
# (discord-streaming service will convert it back to a real file)
rm -f ~/.config/Equicord/settings/settings.json

sudo nixos-rebuild switch --flake /etc/nixos#"$HOST" --impure

echo "Done!"
