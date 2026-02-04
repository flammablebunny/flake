#!/usr/bin/env bash
# NixOS rebuild script

set -euo pipefail

# Detect which host to build based on username
if [[ "$USER" == "bunny" ]]; then
  HOST="pc"
else
  HOST="laptop"
fi

# Run backup before rebuild
echo "Backing up files before rebuild..."
if command -v flake-backup-now &>/dev/null; then
  flake-backup-now
else
  echo "flake-backup-now not found (run rebuild first to install it)"
fi

echo "Rebuilding NixOS for $HOST..."

# Remove Equicord settings.json so home-manager can recreate symlink
# (discord-streaming service will convert it back to a real file)
rm -f ~/.config/Equicord/settings/settings.json

sudo nixos-rebuild switch --flake /etc/nixos#"$HOST" --impure

# Run backup after rebuild
echo "Backing up files after rebuild..."
if command -v flake-backup-now &>/dev/null; then
  flake-backup-now
fi

echo "Done!"
