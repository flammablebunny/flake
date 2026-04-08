{ config, lib, pkgs, inputs, userName, ... }:

{
  imports = [
    ../../modules/nixos/desktop
    ../../modules/nixos/hardware
    ../../modules/nixos/security
    ../../modules/nixos/gaming
    ../../modules/nixos/persistence
  ];

  # Nix settings
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;  # Deduplicate files in store via hardlinks
    };

    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "-d";
    };
  };

  # Boot loader
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "nodev" ];
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use 7.0-rc7 kernel
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_testing.override {
    argsOverride = rec {
      version = "7.0.0-rc7";
      modDirVersion = version;
      src = pkgs.fetchurl {
        url = "https://git.kernel.org/torvalds/t/linux-7.0-rc7.tar.gz";
        hash = "sha256-FsjUyaqZbpY7pu5xOAo2ZZBEpb/TiQkVlwBu0F2+XSM=";
      };
    };
  });

  # Xe driver overclock support (SLPC params 14/15 + sysfs oc_offset knob)
  boot.kernelPatches = [
    {
      name = "xe-overclock";
      patch = ../../patches/xe-overclock.patch;
    }
  ];

  # OBS Virtual Camera
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Virtual Camera" exclusive_caps=1
  '';

  # Network
  networking.networkmanager.enable = true;

  # Disable WiFi power saving to prevent disconnects on screen lock
  networking.networkmanager.wifi.powersave = false;

  # Mullvad VPN
  services.mullvad-vpn.enable = true;
  services.resolved.enable = true;                # Required: Mullvad & Tailscale both manage DNS through resolved
  networking.nftables.enable = true;              # Mullvad uses nftables; must match NixOS firewall backend
  networking.firewall.checkReversePath = "loose"; # Required for WireGuard

  # Tailscale for remote access to home network
  services.tailscale.enable = true;

  # Libvirt for VMs
  virtualisation.libvirtd.enable = true;

  # SPICE USB redirection (for USB passthrough to VMs)
  virtualisation.spiceUSBRedirection.enable = true;

  # Podman for distrobox/containers
  virtualisation.podman.enable = true;

  services.hardware.bolt.enable = true;  # Thunderbolt device authorization (eGPU)
  # Ollama (local LLM inference on Intel Arc B580 via Vulkan)
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
  };

  # Open WebUI (chat history, memory, and session management for Ollama)
  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    port = 8080;
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      WEBUI_AUTH = "false";  # single-user system, no login needed
    };
  };

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
    extraGroups = [ "wheel" "libvirtd" "video" "render" "input" ];
    packages = with pkgs; [ tree ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHgsCClEAX9+zinuQojwkFUluCZw41AybWpLpJJBtX0Q theflammablebunny@gmail.com"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  # btop with Intel Xe GPU support (PR #1457) + sysfs access
  security.wrappers.btop = {
    owner = "root";
    group = "root";
    capabilities = "cap_perfmon+ep";
    source = "${pkgs.btop.overrideAttrs (old: {
      src = pkgs.fetchFromGitHub {
        owner = "deveworld";
        repo = "btop";
        rev = "922a37e43b098bde231a03e8379628d0b186f885";
        hash = "sha256-c6C7Vn6BzOh8DjJvc111wV1hD1sh2WdyQOQ9V2XmBR0=";
      };
    })}/bin/btop";
  };

  # Universal Packages
  environment.systemPackages = with pkgs; [
    # btop-gpu with ROCm - re-enable with 7900XTX
    # let
    #   btop-gpu = btop.overrideAttrs (old: {
    #     nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ makeWrapper ];
    #     postFixup = (old.postFixup or "") + ''
    #       wrapProgram $out/bin/btop \
    #         --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
    #           rocmPackages.rocm-smi
    #           rocmPackages.amdsmi
    #         ]}
    #     '';
    #   });
    # in [

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
    
    thunar
    file-roller

    # ── Theming ────────────────────────────────────────────────────────
    
    nwg-look
    adw-gtk3
    papirus-icon-theme
    catppuccin-cursors.frappeDark
    gsettings-desktop-schemas
    gtk3
    jetbrains-mono

    # ── Terminal & Shell ───────────────────────────────────────────────
    
    foot
    fastfetch
    starship
    eza
    fzf
    direnv
    nix-direnv

    # ── CLI & TUI Utils ──────────────────────────────────────────────────────

    android-tools 
    git
    wget
    curl
    jq
    fd
    ripgrep
    unrar
    tree
    trash-cli
    p7zip
    socat
    toybox
    btop
    nvtopPackages.intel
    # rocmPackages.rocm-device-libs           # re-enable with 7900XTX
    # rocmPackages.rocm-smi                   # re-enable with 7900XTX
    # rocmPackages.amdsmi                     # re-enable with 7900XTX
    lm_sensors
    inotify-tools
    # radeontop                               # re-enable with 7900XTX
    # amdgpu_top                              # re-enable with 7900XTX
    speedtest-cli
    cava

    # ── Wayland Utilities ──────────────────────────────────────────────
    
    wl-clipboard
    cliphist
    grim
    slurp
    swappy
    gimp-with-plugins
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
    qbittorrent

    # ── Gaming ─────────────────────────────────────────────────────────
    
    steam
    protonplus
    xremap
    gamescope
    prismlauncher
    wineWowPackages.waylandFull
    mangohud
    waywall
    libxtst
    luajit

    # ── Development ────────────────────────────────────────────────────
    
    # IDEs
    jetbrains.idea-oss
    vscode

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
    # lact                                    # re-enable with 7900XTX
    freetype
    fontconfig

  ];

  system.stateVersion = "25.11";
}
