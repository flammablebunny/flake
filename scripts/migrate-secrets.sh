#!/usr/bin/env bash
# One-time migration: re-encrypt all secrets with passwordless age key

set -e

AGE_KEY="age1vt7xwl0rgxcn2dadz7cq33vq74wzvcf6n9c4c09wgca0hrdqsecssyth5t"
SSH_KEY="$HOME/.ssh/id_ed25519"
SECRETS_DIR="/etc/nixos/secrets"

echo "This will re-encrypt all secrets with your passwordless age key."
echo "You'll enter your SSH passphrase once (cached by ssh-agent)."
echo ""

# Use ssh-agent to cache passphrase
eval "$(ssh-agent -s)"
echo "Enter your SSH passphrase:"
ssh-add "$SSH_KEY"

echo ""
echo "Re-encrypting secrets..."

# Export SSH_AUTH_SOCK so nix-shell can use it
export SSH_AUTH_SOCK

# Re-encrypt with nix-shell providing age, keeping SSH_AUTH_SOCK
nix-shell -p age --keep SSH_AUTH_SOCK --run "
  cd $SECRETS_DIR

  for f in waywall-oauth.age paceman-key.age; do
    echo \"Re-encrypting \$f...\"
    age -d -i $SSH_KEY \"\$f\" | age -r $AGE_KEY -o \"\${f}.new\"
    mv \"\${f}.new\" \"\$f\"
  done

  for f in wallpapers/*.age; do
    echo \"Re-encrypting \$f...\"
    age -d -i $SSH_KEY \"\$f\" | age -r $AGE_KEY -o \"\${f}.new\"
    mv \"\${f}.new\" \"\$f\"
  done
"

# Kill ssh-agent
ssh-agent -k > /dev/null 2>&1 || true

echo ""
echo "Done! All secrets are now encrypted with your age key."
echo "Future rebuilds won't require any passphrase."
