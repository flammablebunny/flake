#!/usr/bin/env bash
# NixOS rebuild script

set -euo pipefail

echo "Rebuilding NixOS..."

# Only kill Caelestia Shell if it's currently running (avoid failing the rebuild when it's not).
if command -v caelestia-shell >/dev/null 2>&1; then
  if caelestia-shell list 2>/dev/null | grep -q "^Instance "; then
    caelestia-shell kill
  else
    echo "Caelestia Shell not running; skipping kill."
  fi
fi

sudo nixos-rebuild switch --flake /etc/nixos#iusenixbtw --impure

# Relaunch Caelestia Shell if available
if command -v caelestia-shell >/dev/null 2>&1; then
  env QSG_RENDER_LOOP=basic caelestia-shell -d
fi
echo "Done!"
