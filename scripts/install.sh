#!/usr/bin/env bash
#
# NixOS Configuration Installer
#
# Installs Bunny's complete NixOS configuration on a fresh system.
# Only requires entering the sudo password ONCE.
#
# Usage:
#   # From fresh NixOS install:
#   nix-shell -p git --run "git clone https://github.com/Flammable-Bunny/nix.git /tmp/nix && /tmp/nix/scripts/install.sh"
#
#   # Or if you already cloned:
#   /etc/nixos/scripts/install.sh
#

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

REPO_URL="https://github.com/Flammable-Bunny/nix.git"
NIXOS_DIR="/etc/nixos"
AGE_KEY_PATH="$HOME/.config/agenix/key.txt"

# Common locations to search for age key backup
AGE_KEY_SEARCH_PATHS=(
    "/mnt/arch/home/bunny/.config/agenix/key.txt"
    "/mnt/backup/agenix/key.txt"
    "/mnt/usb/agenix/key.txt"
    "/tmp/key.txt"
)

# ============================================================================
# Colors and Logging
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

info()    { echo -e "${BLUE}::${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn()    { echo -e "${YELLOW}!${NC} $1"; }
error()   { echo -e "${RED}✗${NC} $1"; }
step()    { echo -e "\n${BOLD}==> $1${NC}"; }

die() { error "$1"; exit 1; }

# ============================================================================
# Sudo Keepalive - Only Ask Password Once
# ============================================================================

sudo_keepalive_start() {
    info "Authenticating sudo (you'll only enter your password once)..."

    # Initial authentication
    sudo -v || die "Failed to authenticate with sudo"

    # Background process to keep sudo alive
    (
        while true; do
            sudo -n true 2>/dev/null
            sleep 50
            # Exit if parent script is gone
            kill -0 "$$" 2>/dev/null || exit 0
        done
    ) &
    SUDO_KEEPALIVE_PID=$!

    # Cleanup on exit
    trap 'kill $SUDO_KEEPALIVE_PID 2>/dev/null || true' EXIT

    success "Sudo authenticated - no more password prompts needed"
}

# ============================================================================
# Dependency Management
# ============================================================================

ensure_deps() {
    local missing=()

    command -v git &>/dev/null || missing+=(git)
    command -v age &>/dev/null || missing+=(age)

    if [[ ${#missing[@]} -gt 0 ]]; then
        info "Need dependencies: ${missing[*]}"

        # Get absolute path to this script before re-exec
        local script_path
        script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

        info "Re-launching with dependencies..."
        exec nix-shell -p "${missing[@]}" --run "bash '$script_path' $*"
    fi
}

# ============================================================================
# Flakes Support
# ============================================================================

ensure_flakes() {
    step "Ensuring Nix flakes are enabled"

    local nix_conf="$HOME/.config/nix/nix.conf"

    if grep -q "experimental-features.*flakes" "$nix_conf" 2>/dev/null; then
        success "Flakes already enabled"
        return 0
    fi

    mkdir -p "$(dirname "$nix_conf")"
    echo "experimental-features = nix-command flakes" >> "$nix_conf"
    success "Flakes enabled"
}

# ============================================================================
# Age Key Setup
# ============================================================================

find_age_key_backup() {
    for path in "${AGE_KEY_SEARCH_PATHS[@]}"; do
        if [[ -f "$path" ]]; then
            echo "$path"
            return 0
        fi
    done
    return 1
}

setup_age_key() {
    step "Setting up age key for secrets decryption"

    # Already have key?
    if [[ -f "$AGE_KEY_PATH" ]]; then
        success "Age key exists at $AGE_KEY_PATH"
        local pubkey
        pubkey=$(age-keygen -y "$AGE_KEY_PATH" 2>/dev/null) || die "Invalid age key file"
        info "Public key: ${DIM}$pubkey${NC}"
        return 0
    fi

    # Search for backup
    local backup_key
    if backup_key=$(find_age_key_backup); then
        info "Found age key backup at: $backup_key"
        read -rp "Use this key? [Y/n]: " use_backup
        if [[ "${use_backup,,}" != "n" ]]; then
            mkdir -p "$(dirname "$AGE_KEY_PATH")"
            cp "$backup_key" "$AGE_KEY_PATH"
            chmod 600 "$AGE_KEY_PATH"
            success "Age key copied from backup"
            return 0
        fi
    fi

    # Manual setup
    echo ""
    warn "Age key not found"
    echo ""
    echo "The age key decrypts secrets (API tokens, encrypted wallpapers, etc.)"
    echo "Without the original key, existing secrets cannot be decrypted."
    echo ""
    echo "Options:"
    echo "  ${BOLD}1)${NC} Enter path to key file"
    echo "  ${BOLD}2)${NC} Paste key content"
    echo "  ${BOLD}3)${NC} Generate new key ${DIM}(secrets need re-encryption)${NC}"
    echo "  ${BOLD}4)${NC} Skip ${DIM}(continue without secrets)${NC}"
    echo ""

    read -rp "Choice [1-4]: " choice

    mkdir -p "$(dirname "$AGE_KEY_PATH")"
    chmod 700 "$(dirname "$AGE_KEY_PATH")"

    case "$choice" in
        1)
            read -rp "Path to key file: " key_path
            [[ -f "$key_path" ]] || die "File not found: $key_path"
            cp "$key_path" "$AGE_KEY_PATH"
            ;;
        2)
            echo ""
            echo "Paste your age key (including the comment lines), then Ctrl+D:"
            echo "${DIM}---${NC}"
            cat > "$AGE_KEY_PATH"
            echo "${DIM}---${NC}"
            ;;
        3)
            warn "Generating new age key..."
            age-keygen -o "$AGE_KEY_PATH" 2>&1
            echo ""
            warn "IMPORTANT: Update /etc/nixos/secrets/secrets.nix with the new public key"
            warn "Then re-encrypt secrets: cd /etc/nixos && agenix -r"
            echo ""
            read -rp "Press Enter to continue..."
            ;;
        4)
            warn "Skipping age key - secrets will not decrypt"
            return 0
            ;;
        *)
            die "Invalid choice"
            ;;
    esac

    chmod 600 "$AGE_KEY_PATH"
    success "Age key configured"
}

# ============================================================================
# Repository Setup
# ============================================================================

setup_repo() {
    step "Setting up NixOS configuration repository"

    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Case 1: Running from within an existing clone (e.g., /tmp/nix/scripts/)
    if [[ -f "$script_dir/../flake.nix" ]]; then
        local source_dir
        source_dir="$(dirname "$script_dir")"

        if [[ "$source_dir" != "$NIXOS_DIR" ]]; then
            info "Installing from $source_dir to $NIXOS_DIR"

            # Backup existing
            if [[ -d "$NIXOS_DIR" ]]; then
                local backup="${NIXOS_DIR}.backup.$(date +%Y%m%d%H%M%S)"
                warn "Backing up existing $NIXOS_DIR to $backup"
                sudo mv "$NIXOS_DIR" "$backup"
            fi

            sudo cp -r "$source_dir" "$NIXOS_DIR"
            sudo chown -R "$USER:users" "$NIXOS_DIR"
            success "Configuration installed to $NIXOS_DIR"
            return 0
        fi
    fi

    # Case 2: Repo already at /etc/nixos
    if [[ -d "$NIXOS_DIR/.git" ]]; then
        success "Configuration exists at $NIXOS_DIR"
        info "Pulling latest changes..."
        git -C "$NIXOS_DIR" pull --ff-only 2>/dev/null || warn "Could not pull (offline?)"
        return 0
    fi

    # Case 3: Fresh clone needed
    info "Cloning $REPO_URL..."

    if [[ -d "$NIXOS_DIR" ]]; then
        local backup="${NIXOS_DIR}.backup.$(date +%Y%m%d%H%M%S)"
        warn "Backing up existing $NIXOS_DIR to $backup"
        sudo mv "$NIXOS_DIR" "$backup"
    fi

    sudo git clone "$REPO_URL" "$NIXOS_DIR"
    sudo chown -R "$USER:users" "$NIXOS_DIR"

    success "Configuration cloned to $NIXOS_DIR"
}

# ============================================================================
# NixOS Rebuild
# ============================================================================

run_rebuild() {
    step "Building and activating NixOS configuration"

    info "This may take a while on first run..."
    echo ""

    sudo nixos-rebuild switch --flake "$NIXOS_DIR#default" --impure || die "Rebuild failed!"

    echo ""
    success "NixOS configuration activated!"
}

# ============================================================================
# Verification
# ============================================================================

verify() {
    step "Verifying installation"

    local warnings=0

    # Check wallpapers
    if [[ -f "$HOME/Pictures/Wallpapers/rabbit forest.png" ]]; then
        local filetype
        filetype=$(file -b "$HOME/Pictures/Wallpapers/rabbit forest.png" 2>/dev/null || echo "unknown")
        if [[ "$filetype" == *"PNG"* ]]; then
            success "Wallpapers decrypted correctly"
        else
            warn "Wallpapers exist but may not be properly decrypted"
            ((warnings++)) || true
        fi
    else
        warn "Wallpapers not found (age key may be missing/wrong)"
        ((warnings++)) || true
    fi

    # Check home-manager links
    if [[ -L "$HOME/.config/foot/foot.ini" ]]; then
        success "Home-manager configs linked"
    else
        warn "Some home-manager configs may not be linked"
        ((warnings++)) || true
    fi

    # Check fish config
    if [[ -L "$HOME/.config/fish/config.fish" ]]; then
        success "Fish shell configured"
    else
        warn "Fish config not linked"
        ((warnings++)) || true
    fi

    if [[ $warnings -eq 0 ]]; then
        success "All checks passed!"
    else
        warn "$warnings check(s) had warnings - review above"
    fi
}

# ============================================================================
# Main
# ============================================================================

main() {
    clear 2>/dev/null || true

    echo ""
    echo -e "${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║              Bunny's NixOS Configuration Installer             ║${NC}"
    echo -e "${BOLD}║                                                                ║${NC}"
    echo -e "${BOLD}║   Installs the complete reproducible NixOS configuration.     ║${NC}"
    echo -e "${BOLD}║   You only need to enter your password ${GREEN}once${NC}${BOLD}.                  ║${NC}"
    echo -e "${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Step 0: Dependencies
    ensure_deps "$@"

    # Step 1: Sudo (only password prompt!)
    sudo_keepalive_start

    # Step 2: Flakes
    ensure_flakes

    # Step 3: Age key
    setup_age_key

    # Step 4: Repository
    setup_repo

    # Step 5: Rebuild
    run_rebuild

    # Step 6: Verify
    verify

    echo ""
    echo -e "${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║                    Installation Complete!                      ║${NC}"
    echo -e "${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    info "Reboot recommended: ${BOLD}sudo reboot${NC}"
    info "Future rebuilds: ${BOLD}nix-rebuild${NC}"
    echo ""
}

main "$@"
