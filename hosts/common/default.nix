{ config, lib, pkgs, inputs, userName, ... }:

{
  imports = [
    ../../modules/nixos/desktop
    ../../modules/nixos/hardware
    ../../modules/nixos/security
    ../../modules/nixos/gaming
  ];

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Boot loader
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "nodev" ];
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Network
  networking.networkmanager.enable = true;

  # Timezone
  time.timeZone = "America/Vancouver";

  # User definition 
  users.users.${userName} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ];
    packages = with pkgs; [ tree ];
  };

  nixpkgs.config.allowUnfree = true;

  # Universal Packages 
  environment.systemPackages = with pkgs; [

    (writeShellScriptBin "app2unit" ''
      #!/bin/sh
      if [ "$1" = "--" ]; then shift; fi
      nohup "$@" >/dev/null 2>&1 &
    '')

    (inputs.caelestia-shell.packages.${system}.default.overrideAttrs (old: {
      cmakeBuildType = "Release";
      dontStrip = false;
      postPatch = (old.postPatch or "") + ''
        find . -type f -name "*.qml" -exec sed -i 's|https://wttr.in|http://wttr.in|g' {} +
      '';
    }))
    inputs.zen-browser.packages.${system}.default
    inputs.caelestia-cli.packages.${system}.default
    inputs.nixcraft.packages.${system}.nixcraft-cli
    inputs.nixcraft.packages.${system}.nixcraft-auth
    inputs.nixcraft.packages.${system}.nixcraft-skin

    # ── Desktop Environment ────────────────────────────────────────────
    
    polkit_gnome
    gnome-keyring
    gvfs
    fuzzel
    libnotify

    # ── System Utilities ───────────────────────────────────────────────
    
    xfce.thunar
    file-roller

    # ── Theming ────────────────────────────────────────────────────────
    
    nwg-look
    adw-gtk3
    papirus-icon-theme
    catppuccin-cursors.frappeDark
    gsettings-desktop-schemas
    gtk3

    # ── Terminal & Shell ───────────────────────────────────────────────
    
    foot
    fastfetch
    starship
    btop
    eza
    fzf

    # ── CLI Utils ──────────────────────────────────────────────────────
    
    git
    wget
    curl
    jq
    fd
    ripgrep
    tree
    trash-cli
    p7zip
    socat
    toybox
    inotify-tools

    # ── Wayland Utilities ──────────────────────────────────────────────
    
    wl-clipboard
    cliphist
    grim
    slurp
    hyprpicker
    brightnessctl
    gammastep
    ydotool

    # ── Media ──────────────────────────────────────────────────────────
    
    vlc
    playerctl

    # ── Security & Privacy ─────────────────────────────────────────────
    
    mullvad
    mullvad-browser

    # ── Gaming ─────────────────────────────────────────────────────────
    
    steam
    prismlauncher
    wineWowPackages.wayland
    mangohud
    waywall
    luajit

    # ── Development ────────────────────────────────────────────────────
    
    # IDEs
    jetbrains.idea-ultimate

    # Languages
    go
    python3
    jdk17
    graalvmPackages.graalvm-oracle_17
    luajitPackages.luarocks

    # Build Tools
    gradle
    cmake
    meson
    ninja

    # AI 
    claude-code
    antigravity

    # ── Libraries ──────────────────────────────────────────────────────
    
    # Qt
    qt6.qtwayland
    qt6.qmake
    libsForQt5.qt5ct
    qt6Packages.qt6ct

    # Wayland
    wayland
    wayland.dev
    wayland-scanner
    wayland-protocols
    xwayland
    libxkbcommon
    libxkbcommon.dev

    # Graphics
    mesa
    libspng
    glib

    # Audio/Bluetooth
    wireplumber
    bluez-tools
    pavucontrol
    easyeffects

    # Neovim Plugins (Managed By /modules/home/development/nixos)
    vimPlugins.nvim-tree-lua
    vimPlugins.nvim-web-devicons
  ];

  system.stateVersion = "25.11";
}
