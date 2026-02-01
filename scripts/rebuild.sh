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

# Only kill Caelestia Shell if it's currently running
if command -v caelestia-shell >/dev/null 2>&1; then
  if caelestia-shell list 2>/dev/null | grep -q "^Instance "; then
    caelestia-shell kill
  else
    echo "Caelestia Shell not running; skipping kill."
  fi
fi

# Remove Equicord settings.json so home-manager can recreate symlink
# (discord-streaming service will convert it back to a real file)
rm -f ~/.config/Equicord/settings/settings.json

sudo nixos-rebuild switch --flake /etc/nixos#"$HOST" --impure

# Relaunch Caelestia Shell if available
if command -v caelestia-shell >/dev/null 2>&1; then
  env QSG_RHI_BACKEND=opengl QSG_RENDER_LOOP=basic caelestia-shell -d
fi
echo "Done!"
