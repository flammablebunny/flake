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

# Only kill Quickshell if it's currently running
if command -v quickshell >/dev/null 2>&1; then
  if quickshell list 2>/dev/null | grep -q "^Instance "; then
    quickshell kill
  else
    echo "Quickshell not running; skipping kill."
  fi
fi

# Remove Equicord settings.json so home-manager can recreate symlink
# (discord-streaming service will convert it back to a real file)
rm -f ~/.config/Equicord/settings/settings.json

sudo nixos-rebuild switch --flake /etc/nixos#"$HOST" --impure

# Relaunch Quickshell if available
if command -v quickshell >/dev/null 2>&1; then
  env QSG_RHI_BACKEND=opengl QSG_RENDER_LOOP=basic quickshell -d
fi
echo "Done!"
