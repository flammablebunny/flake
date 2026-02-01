#!/usr/bin/env bash
#
# NixOS Installation Script
#
# Installs NixOS with Bunny's configuration from a Ventoy USB.
# Expects age key at /mnt/Ventoy/secrets/key.txt
#
# Usage (from NixOS installer):
#   1. Boot NixOS installer from Ventoy USB
#   2. Partition and mount drives to /mnt
#   3. Run: nix-shell -p git --run "git clone https://github.com/Flammable-Bunny/nix.git /tmp/nix && /tmp/nix/scripts/install.sh"
#

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

REPO_URL="https://github.com/Flammable-Bunny/nix.git"
VENTOY_KEY="/mnt/Ventoy/secrets/key.txt"
# Will be set properly after we know the username
AGE_KEY_DEST=""

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

setup_age_key() {
    step "Setting up age key"

    # Already have key?
    if [[ -f "$AGE_KEY_DEST" ]]; then
        success "Age key already exists at $AGE_KEY_DEST"
        return 0
    fi

    # Check Ventoy USB
    if [[ -f "$VENTOY_KEY" ]]; then
        info "Found age key on Ventoy USB"
        sudo mkdir -p "$(dirname "$AGE_KEY_DEST")"
        sudo cp "$VENTOY_KEY" "$AGE_KEY_DEST"
        sudo chmod 600 "$AGE_KEY_DEST"
        # Set ownership to UID 1000 (first user) for fresh installs
        if [[ "$INSTALL_MODE" == "fresh" ]]; then
            sudo chown 1000:users "$AGE_KEY_DEST"
        else
            sudo chown "$USERNAME:users" "$AGE_KEY_DEST"
        fi
        success "Age key copied to $AGE_KEY_DEST"
        return 0
    fi

    # Try common backup locations
    local backup_paths=(
        "/mnt/Ventoy/secrets/key.txt"
        "/run/media/nixos/Ventoy/secrets/key.txt"
        "/tmp/key.txt"
    )

    for path in "${backup_paths[@]}"; do
        if [[ -f "$path" ]]; then
            info "Found age key at: $path"
            sudo mkdir -p "$(dirname "$AGE_KEY_DEST")"
            sudo cp "$path" "$AGE_KEY_DEST"
            sudo chmod 600 "$AGE_KEY_DEST"
            if [[ "$INSTALL_MODE" == "fresh" ]]; then
                sudo chown 1000:users "$AGE_KEY_DEST"
            else
                sudo chown "$USERNAME:users" "$AGE_KEY_DEST"
            fi
            success "Age key copied to $AGE_KEY_DEST"
            return 0
        fi
    done

    warn "No age key found - secrets won't decrypt until key is added"
    warn "Expected location: $VENTOY_KEY"
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
    run_install

    echo ""
    echo -e "${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║                         All Done!                              ║${NC}"
    echo -e "${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if [[ "$INSTALL_MODE" == "fresh" ]]; then
        info "Reboot into your new system: ${BOLD}sudo reboot${NC}"
    fi

    info "Future rebuilds: ${BOLD}rebuild${NC}"
    echo ""
}

main "$@"
