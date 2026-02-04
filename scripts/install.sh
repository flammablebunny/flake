#!/usr/bin/env bash

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

REPO_URL="https://github.com/flammablebunny/flake.git"
VENTOY_KEY="/mnt/Ventoy/secrets/key.txt"
# Will be set properly after we know the username
AGE_KEY_DEST=""
# Set to true if no age key found (other users using this config)
PUBLIC_MODE=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}::${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn()    { echo -e "${YELLOW}!${NC} $1"; }
error()   { echo -e "${RED}✗${NC} $1"; exit 1; }
step()    { echo -e "\n${BOLD}==> $1${NC}"; }

# ============================================================================
# Detect Environment
# ============================================================================

detect_environment() {
    step "Detecting environment"

    # Check if running from installer (has /mnt with mounted system)
    if mountpoint -q /mnt 2>/dev/null; then
        INSTALL_MODE="fresh"
        TARGET="/mnt"
        NIXOS_DIR="/mnt/etc/nixos"
        info "Mode: Fresh install (target: /mnt)"
    else
        INSTALL_MODE="existing"
        TARGET=""
        NIXOS_DIR="/etc/nixos"
        info "Mode: Existing system rebuild"
    fi

    # Detect host type
    # Check for username.txt on Ventoy first
    local ventoy_username="/mnt/Ventoy/secrets/username.txt"
    if [[ -f "$ventoy_username" ]]; then
        USERNAME=$(tr -d '\n' < "$ventoy_username")
        if [[ "$USERNAME" == "bunny" ]]; then
            HOST="pc"
        else
            HOST="laptop"
        fi
        info "Found username on Ventoy: $USERNAME"
    elif [[ -d /mnt/home/bunny ]] || [[ -d /home/bunny ]]; then
        # PC detected (bunny's home exists)
        HOST="pc"
        USERNAME="bunny"
    else
        HOST="laptop"
        # Always ask for laptop username (can't trust $USER when running as root)
        echo ""
        echo "Laptop installation detected."
        read -rp "Enter your laptop username: " USERNAME
        if [[ -z "$USERNAME" ]]; then
            error "Username cannot be empty"
        fi
    fi

    info "Host: $HOST (user: $USERNAME)"

    # Set age key destination based on actual username
    if [[ "$INSTALL_MODE" == "fresh" ]]; then
        AGE_KEY_DEST="/mnt/home/$USERNAME/.config/agenix/key.txt"
    else
        AGE_KEY_DEST="/home/$USERNAME/.config/agenix/key.txt"
    fi
}

# ============================================================================
# Age Key Setup
# ============================================================================

find_age_key() {
    # Search for key.txt in common locations and mounted media

    # Check home directory first (existing install)
    local home_locations=(
        "$HOME/.config/agenix/key.txt"
        "/home/bunny/.config/agenix/key.txt"
        "/home/nixos/.config/agenix/key.txt"
    )

    for loc in "${home_locations[@]}"; do
        if [[ -f "$loc" ]]; then
            echo "$loc"
            return 0
        fi
    done

    # Search mounted media directories (up to 4 levels deep)
    local search_dirs=("/run/media" "/mnt" "/media")

    for base in "${search_dirs[@]}"; do
        [[ -d "$base" ]] || continue

        while IFS= read -r -d '' keyfile; do
            if [[ -f "$keyfile" ]]; then
                echo "$keyfile"
                return 0
            fi
        done < <(find "$base" -maxdepth 4 -name "key.txt" -type f -print0 2>/dev/null)
    done

    return 1
}

setup_age_key() {
    step "Setting up age key"

    # Already have key?
    if [[ -f "$AGE_KEY_DEST" ]]; then
        success "Age key already exists at $AGE_KEY_DEST"
        return 0
    fi

    # Search for key on any mounted USB/media
    info "Searching for age key on mounted drives..."
    local found_key
    if found_key=$(find_age_key); then
        info "Found age key at: $found_key"
        sudo mkdir -p "$(dirname "$AGE_KEY_DEST")"
        sudo cp "$found_key" "$AGE_KEY_DEST"
        sudo chmod 600 "$AGE_KEY_DEST"
        if [[ "$INSTALL_MODE" == "fresh" ]]; then
            sudo chown 1000:users "$AGE_KEY_DEST"
        else
            sudo chown "$USERNAME:users" "$AGE_KEY_DEST"
        fi
        success "Age key copied to $AGE_KEY_DEST"
        return 0
    fi

    # No key found - enter public mode
    PUBLIC_MODE=true
    echo ""
    info "No age key found - installing in PUBLIC MODE"
    info "This installs the NixOS config without personal secrets/files"
    info "You'll get the full desktop environment, but:"
    info "  - Encrypted secrets won't be available"
    info "  - Personal file backup won't be restored"
    info "  - You may need to set up your own SSH keys, etc."
    echo ""
}

# ============================================================================
# Repository Setup
# ============================================================================

setup_repo() {
    step "Setting up NixOS configuration"

    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Running from a clone (e.g., /tmp/nix)?
    if [[ -f "$script_dir/../flake.nix" ]]; then
        local source_dir
        source_dir="$(dirname "$script_dir")"

        if [[ "$source_dir" != "$NIXOS_DIR" ]]; then
            info "Installing config from $source_dir"

            # Backup existing config
            if [[ -d "$NIXOS_DIR" ]]; then
                sudo mv "$NIXOS_DIR" "${NIXOS_DIR}.backup.$(date +%Y%m%d%H%M%S)"
            fi

            sudo cp -r "$source_dir" "$NIXOS_DIR"
            sudo chown -R "$USER:users" "$NIXOS_DIR" 2>/dev/null || true
            success "Configuration installed"
            return 0
        fi
    fi

    # Config already exists?
    if [[ -d "$NIXOS_DIR/.git" ]]; then
        success "Configuration exists at $NIXOS_DIR"
        return 0
    fi

    # Fresh clone
    info "Cloning repository..."
    if [[ -d "$NIXOS_DIR" ]]; then
        sudo mv "$NIXOS_DIR" "${NIXOS_DIR}.backup.$(date +%Y%m%d%H%M%S)"
    fi

    sudo mkdir -p "$(dirname "$NIXOS_DIR")"
    sudo git clone "$REPO_URL" "$NIXOS_DIR"
    sudo chown -R "$USER:users" "$NIXOS_DIR" 2>/dev/null || true
    success "Repository cloned"
}

# ============================================================================
# Username Setup (for laptop)
# ============================================================================

setup_username() {
    step "Setting up username"

    local username_file="$NIXOS_DIR/username.txt"

    # Only needed for laptop
    if [[ "$HOST" == "pc" ]]; then
        success "PC uses hardcoded username (bunny)"
        return 0
    fi

    # Create username.txt for laptop
    echo "$USERNAME" > "$username_file"
    success "Created username.txt with: $USERNAME"
}

# ============================================================================
# Hardware Configuration
# ============================================================================

setup_hardware_config() {
    step "Setting up hardware configuration"

    local hw_config="$NIXOS_DIR/hosts/$HOST/hardware-configuration.nix"

    if [[ "$INSTALL_MODE" == "fresh" ]]; then
        # Generate hardware config for new install
        info "Generating hardware configuration..."
        nixos-generate-config --root /mnt --show-hardware-config > "$hw_config"
        success "Hardware configuration generated"
    elif [[ ! -f "$hw_config" ]]; then
        warn "No hardware-configuration.nix found for $HOST"
        warn "Run: nixos-generate-config --show-hardware-config > $hw_config"
    else
        success "Hardware configuration exists"
    fi
}

# ============================================================================
# Install/Rebuild
# ============================================================================

run_install() {
    step "Installing NixOS"

    if [[ "$INSTALL_MODE" == "fresh" ]]; then
        info "Running nixos-install for $HOST..."
        sudo nixos-install --flake "$NIXOS_DIR#$HOST" --impure --no-root-passwd
    else
        info "Rebuilding NixOS for $HOST..."
        sudo nixos-rebuild switch --flake "$NIXOS_DIR#$HOST" --impure
    fi

    success "Installation complete!"
}

# ============================================================================
# Restore User Files from Encrypted Backup
# ============================================================================

BACKUP_REPO_URL="git@gitlab.com:flammablebunny/flake-persistent.git"

# ============================================================================
# SSH Key Setup (decrypt from agenix using age key)
# ============================================================================

setup_ssh_key() {
    step "Setting up SSH key from agenix secrets"

    # Skip in public mode
    if [[ "$PUBLIC_MODE" == "true" ]]; then
        info "Skipping SSH key setup (public mode)"
        return 0
    fi

    local home_dir
    local ssh_dir
    local age_key

    if [[ "$INSTALL_MODE" == "fresh" ]]; then
        home_dir="/mnt/home/$USERNAME"
        age_key="/mnt/home/$USERNAME/.config/agenix/key.txt"
    else
        home_dir="/home/$USERNAME"
        age_key="/home/$USERNAME/.config/agenix/key.txt"
    fi

    ssh_dir="$home_dir/.ssh"
    local ssh_private="$ssh_dir/id_ed25519"
    local ssh_public="$ssh_dir/id_ed25519.pub"

    # Already have SSH key?
    if [[ -f "$ssh_private" ]]; then
        success "SSH key already exists at $ssh_private"
        return 0
    fi

    # Need age key to decrypt
    if [[ ! -f "$age_key" ]]; then
        warn "No age key found - cannot decrypt SSH key"
        warn "SSH key setup skipped"
        return 0
    fi

    # Find encrypted SSH keys in nixos config
    local encrypted_private="$NIXOS_DIR/secrets/ssh/id_ed25519.age"
    local encrypted_public="$NIXOS_DIR/secrets/ssh/id_ed25519.pub.age"

    if [[ ! -f "$encrypted_private" ]]; then
        warn "No encrypted SSH key found at $encrypted_private"
        return 0
    fi

    # Get age command
    local age_cmd
    if command -v age &>/dev/null; then
        age_cmd="age"
    elif command -v nix-shell &>/dev/null; then
        info "Using nix-shell for age..."
        age_cmd="nix-shell -p age --run age"
    else
        warn "age not available - cannot decrypt SSH key"
        return 0
    fi

    # Create .ssh directory
    sudo mkdir -p "$ssh_dir"
    sudo chmod 700 "$ssh_dir"

    # Decrypt SSH private key
    info "Decrypting SSH private key..."
    if sudo $age_cmd -d -i "$age_key" -o "$ssh_private" "$encrypted_private" 2>/dev/null; then
        sudo chmod 600 "$ssh_private"
        success "SSH private key decrypted"
    else
        warn "Failed to decrypt SSH private key"
        return 0
    fi

    # Decrypt SSH public key if exists
    if [[ -f "$encrypted_public" ]]; then
        info "Decrypting SSH public key..."
        if sudo $age_cmd -d -i "$age_key" -o "$ssh_public" "$encrypted_public" 2>/dev/null; then
            sudo chmod 644 "$ssh_public"
            success "SSH public key decrypted"
        fi
    fi

    # Fix ownership
    if [[ "$INSTALL_MODE" == "fresh" ]]; then
        sudo chown -R 1000:users "$ssh_dir"
    else
        sudo chown -R "$USERNAME:users" "$ssh_dir"
    fi

    # Add GitHub to known_hosts
    local known_hosts="$ssh_dir/known_hosts"
    if [[ ! -f "$known_hosts" ]] || ! grep -q "github.com" "$known_hosts" 2>/dev/null; then
        info "Adding GitHub to known_hosts..."
        sudo ssh-keyscan -t ed25519 github.com >> "$known_hosts" 2>/dev/null || true
        sudo chmod 644 "$known_hosts"
        if [[ "$INSTALL_MODE" == "fresh" ]]; then
            sudo chown 1000:users "$known_hosts"
        else
            sudo chown "$USERNAME:users" "$known_hosts"
        fi
    fi

    success "SSH key setup complete"
}

restore_backup() {
    step "Restoring user files from backup"

    # Skip in public mode
    if [[ "$PUBLIC_MODE" == "true" ]]; then
        info "Skipping backup restore (public mode)"
        return 0
    fi

    local home_dir
    local age_key

    if [[ "$INSTALL_MODE" == "fresh" ]]; then
        home_dir="/mnt/home/$USERNAME"
        age_key="/mnt/home/$USERNAME/.config/agenix/key.txt"
    else
        home_dir="/home/$USERNAME"
        age_key="/home/$USERNAME/.config/agenix/key.txt"
    fi

    local backup_dir="$home_dir/.local/share/flake-persistent"
    local ssh_key="$home_dir/.ssh/id_ed25519"

    # Check for age key
    if [[ ! -f "$age_key" ]]; then
        warn "No age key found at $age_key - skipping backup restore"
        warn "Run 'flake-restore' manually after adding your key"
        return 0
    fi

    # Check for SSH key (needed for private repo)
    if [[ ! -f "$ssh_key" ]]; then
        warn "No SSH key found - cannot clone private backup repo"
        warn "Run 'flake-restore' after SSH key is set up"
        return 0
    fi

    # Get age command
    local age_cmd
    if command -v age &>/dev/null; then
        age_cmd="age"
    elif command -v nix-shell &>/dev/null; then
        age_cmd="nix-shell -p age --run age"
    else
        warn "age not found - skipping backup restore"
        warn "Run 'flake-restore' after system is fully set up"
        return 0
    fi

    # Clone backup repo if not exists
    if [[ ! -d "$backup_dir/.git" ]]; then
        info "Cloning backup repository..."
        sudo mkdir -p "$backup_dir"

        # Use SSH key for git clone
        local git_ssh="ssh -i $ssh_key -o StrictHostKeyChecking=accept-new"

        if sudo GIT_SSH_COMMAND="$git_ssh" git clone "$BACKUP_REPO_URL" "$backup_dir" 2>/dev/null; then
            success "Backup repository cloned"
        else
            warn "Could not clone backup repo"
            warn "Run 'flake-restore' after first boot to restore files"
            return 0
        fi
    fi

    # Restore files
    info "Decrypting and restoring files..."
    local restore_count=0

    while IFS= read -r -d '' encrypted; do
        local rel_path="${encrypted#$backup_dir/}"
        local dest="$home_dir/${rel_path%.age}"

        sudo mkdir -p "$(dirname "$dest")"
        if sudo $age_cmd -d -i "$age_key" -o "$dest" "$encrypted" 2>/dev/null; then
            ((restore_count++))
        fi
    done < <(find "$backup_dir" -name "*.age" -type f -print0 2>/dev/null)

    # Fix ownership
    if [[ "$INSTALL_MODE" == "fresh" ]]; then
        sudo chown -R 1000:users "$home_dir"
    else
        sudo chown -R "$USERNAME:users" "$home_dir"
    fi

    if [[ $restore_count -gt 0 ]]; then
        success "Restored $restore_count files from backup"
    else
        info "No backup files found to restore"
    fi
}

# ============================================================================
# Main
# ============================================================================

main() {
    echo ""
    echo -e "${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║              Bunny's NixOS Installation Script                 ║${NC}"
    echo -e "${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    detect_environment
    setup_age_key
    setup_repo
    setup_username
    setup_hardware_config
    setup_ssh_key
    run_install
    restore_backup

    echo ""
    echo -e "${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║                             Done!                              ║${NC}"
    echo -e "${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if [[ "$INSTALL_MODE" == "fresh" ]]; then
        info "Reboot into your new system: ${BOLD}sudo reboot${NC}"
        if [[ "$PUBLIC_MODE" == "true" ]]; then
            echo ""
            info "Installed in PUBLIC MODE (no personal secrets/files)"
            info "You have the full NixOS config - customize it for yourself!"
        else
            info "Your files have been restored from backup"
        fi
    fi

    info "Future rebuilds: ${BOLD}rebuild${NC}"
    if [[ "$PUBLIC_MODE" != "true" ]]; then
        info "Manual backup restore: ${BOLD}flake-restore${NC}"
    fi
    echo ""
}

main "$@"
