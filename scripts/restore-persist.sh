#!/usr/bin/env bash
# Restore user files from encrypted git backup
# Usage: ./restore-persist.sh [backup-repo-path]

set -euo pipefail

BACKUP_REPO="${1:-$HOME/.local/share/flake-persistent}"
AGE_KEY="$HOME/.config/agenix/key.txt"

if [ ! -f "$AGE_KEY" ]; then
  echo "Error: Age key not found at $AGE_KEY"
  echo "Make sure your age key is set up first."
  exit 1
fi

if [ ! -d "$BACKUP_REPO" ]; then
  echo "Error: Backup repo not found at $BACKUP_REPO"
  echo ""
  echo "To restore from a remote backup:"
  echo "  git clone git@gitlab.com:flammablebunny/flake-persistent.git $BACKUP_REPO"
  echo "  $0 $BACKUP_REPO"
  exit 1
fi

echo "Restoring from $BACKUP_REPO..."
echo ""

count=0
find "$BACKUP_REPO" -name "*.age" -type f | while read -r ENCRYPTED; do
  # Skip .git directory
  if [[ "$ENCRYPTED" == *"/.git/"* ]]; then
    continue
  fi

  REL_PATH="${ENCRYPTED#$BACKUP_REPO/}"
  DEST="$HOME/${REL_PATH%.age}"

  echo "  $REL_PATH -> ${REL_PATH%.age}"
  mkdir -p "$(dirname "$DEST")"
  age -d -i "$AGE_KEY" "$ENCRYPTED" | zstd -d -c > "$DEST"
  ((count++)) || true
done

echo ""
echo "Restore complete! Restored $count files."
