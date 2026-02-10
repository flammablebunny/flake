{ config, lib, pkgs, inputs, userName, ... }:

{
  imports = [
    ../../modules/nixos/desktop
    ../../modules/nixos/hardware
    ../../modules/nixos/security
    ../../modules/nixos/gaming
    ../../modules/nixos/persistence
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

  # Disable WiFi power saving to prevent disconnects on screen lock
  networking.networkmanager.wifi.powersave = false;

  # Mullvad VPN
  services.mullvad-vpn.enable = true;
  networking.firewall.checkReversePath = "loose";  # Required for WireGuard

  # Tailscale for remote access to home network
  services.tailscale.enable = true;

  # Libvirt for VMs
  virtualisation.libvirtd.enable = true;

  # SPICE USB redirection (for USB passthrough to VMs)
  virtualisation.spiceUSBRedirection.enable = true;

  # Podman for distrobox/containers
  virtualisation.podman.enable = true;

  services.gvfs.enable = true;  # For file manager integration

  # Run dynamically linked executables (for non-NixOS binaries)
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    glib
    gtk3
    SDL2
    libGL
    openssl
  ];

   # Timezone
  time.timeZone = "America/Vancouver";

  # User definition 
  users.users.${userName} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" "video" "render" ];
    packages = with pkgs; [ tree ];
  };

  nixpkgs.config.allowUnfree = true;

  # Universal Packages 
  environment.systemPackages = with pkgs; let
    btop-gpu = btop.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ makeWrapper ];
      postFixup = (old.postFixup or "") + ''
        wrapProgram $out/bin/btop \
          --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
            rocmPackages.rocm-smi
            rocmPackages.amdsmi
          ]}
      '';
    });
  in [

    (writeShellScriptBin "app2unit" ''
      #!/bin/sh
      if [ "$1" = "--" ]; then shift; fi
      nohup "$@" >/dev/null 2>&1 &
    '')

    inputs.quickshell.packages.${system}.default
    inputs.zen-browser.packages.${system}.default
    inputs.nixcraft.packages.${system}.nixcraft-cli
    inputs.nixcraft.packages.${system}.nixcraft-auth
    inputs.nixcraft.packages.${system}.nixcraft-skin

    # ── Desktop Environment ────────────────────────────────────────────
    
    polkit_gnome
    gnome-keyring
    gvfs
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
    eza
    fzf

    # ── CLI & TUI Utils ──────────────────────────────────────────────────────

    android-tools 
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
    btop-gpu
    nvtopPackages.intel
    rocmPackages.rocm-device-libs
    rocmPackages.rocm-smi
    rocmPackages.amdsmi
    lm_sensors
    inotify-tools
    radeontop
    amdgpu_top
    cava

    # ── Wayland Utilities ──────────────────────────────────────────────
    
    wl-clipboard
    cliphist
    grim
    slurp
    swappy
    hyprpicker
    brightnessctl
    gammastep
    ydotool

    # ── Media ──────────────────────────────────────────────────────────
    
    mpv-unwrapped 
    playerctl

    # ── Security & Privacy ─────────────────────────────────────────────
    
    mullvad-vpn
    mullvad-browser

    # ── Gaming ─────────────────────────────────────────────────────────
    
    steam
    prismlauncher
    wineWowPackages.wayland
    mangohud
    waywall
    xorg.libXtst
    luajit

    # ── Development ────────────────────────────────────────────────────
    
    # IDEs
    jetbrains.idea-oss

    # Languages
    go
    mold
    rustc
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
    antigravity

    # VM & Containers
    virt-manager
    distrobox

    # ── Libraries ──────────────────────────────────────────────────────
    
    # Qt (for QuickShell)
    qt6.qtwayland
    qt6.qmake
    qt6.qt5compat
    qt6.qtdeclarative
    qt6.qtmultimedia
    qt6.qtpositioning
    qt6.qtsensors
    qt6.qtsvg
    qt6.qtimageformats
    qt6.qtvirtualkeyboard
    kdePackages.kirigami
    kdePackages.syntax-highlighting
    libsForQt5.qt5ct
    qt6Packages.qt6ct

    # QuickShell deps    
    libqalculate
    matugen
    ddcutil        
    imagemagick   
    libsecret     

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
    pulseaudio

    # Misc
    icu

    # Neovim Plugins (Managed By /modules/home/development/nixos)
    vimPlugins.nvim-tree-lua
    vimPlugins.nvim-web-devicons

    # ── Misc ────────────────────────────────────────────────────────────
    
    chromium
    lact

  ];

  system.stateVersion = "25.11";
}
