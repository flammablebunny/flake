{
  description = "Bunny's Caelestia NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-cli = {
      url = "github:caelestia-dots/cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixcord = {
      url = "github:kaylorben/nixcord";
    };

    nixcraft = {
      url = "github:loystonpais/nixcraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, caelestia-shell, caelestia-cli, zen-browser, spicetify-nix, nixcord, nixcraft, ... }@inputs: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager

        ({ pkgs, inputs, ... }: {
          nixpkgs.config.allowUnfree = true;

          # Home Manager configuration
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.bunny = import ./home.nix;

          programs.dconf.enable = true;
          programs.hyprland.enable = true;
          programs.fish.enable = true;
          programs.xfconf.enable = true;

          programs.thunar = {
            enable = true;
            plugins = with pkgs.xfce; [
              thunar-archive-plugin
              thunar-volman
            ];
          };

          services.gvfs.enable = true;
          services.tumbler.enable = true;
          services.udisks2.enable = true;
          services.gnome.gnome-keyring.enable = true;
          services.geoclue2.enable = true;
          services.upower.enable = true;
          services.power-profiles-daemon.enable = true;
          systemd.services.set-performance-profile = {
            description = "Set power profile to performance";
            wantedBy = [ "multi-user.target" ];
            after = [ "power-profiles-daemon.service" ];
            requires = [ "power-profiles-daemon.service" ];
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance";
              RemainAfterExit = true;
            };
          };
          hardware.bluetooth.enable = true;
          services.blueman.enable = true;

          security.rtkit.enable = true;
          security.polkit.enable = true;
          services.pipewire.enable = true;
          services.pipewire.alsa.enable = true;
          services.pipewire.jack.enable = true;

          fonts.packages = with pkgs; [
            nerd-fonts.jetbrains-mono
          ];

          xdg.portal = {
            enable = true;
            extraPortals = [
              pkgs.xdg-desktop-portal-hyprland
              pkgs.xdg-desktop-portal-gtk
            ];
            config.common.default = "hyprland";
          };

          environment.sessionVariables = {
            XDG_CURRENT_DESKTOP = "Hyprland";
            XDG_SESSION_TYPE = "wayland";
            DEFAULT_BROWSER = "zen";
            GTK_THEME = "adw-gtk3";
            MOZ_ENABLE_WAYLAND = "1";
            XDG_DATA_DIRS = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS";
            JAVA_HOME = "${pkgs.jdk17}/lib/openjdk";
          };

          environment.systemPackages = [
            (pkgs.writeShellScriptBin "app2unit" ''
              #!/bin/sh
              if [ "$1" = "--" ]; then shift; fi
              nohup "$@" >/dev/null 2>&1 &
            '')

            (caelestia-shell.packages.${pkgs.system}.default.overrideAttrs (old: {
              postPatch = (old.postPatch or "") + ''
                find . -type f -name "*.qml" -exec sed -i 's|https://wttr.in|http://wttr.in|g' {} +
              '';
            }))

            inputs.zen-browser.packages.${pkgs.system}.default
            caelestia-cli.packages.${pkgs.system}.default

            # Desktop environment essentials
            pkgs.xfce.thunar
            pkgs.nwg-look
            pkgs.gvfs
            pkgs.polkit_gnome
            pkgs.gnome-keyring

            # GTK theming
            pkgs.gsettings-desktop-schemas
            pkgs.glib
            pkgs.adw-gtk3
            pkgs.papirus-icon-theme
            pkgs.bibata-cursors
            pkgs.gtk3

            # Core tools
            pkgs.git
	    pkgs.wget
            pkgs.socat
            pkgs.libnotify
            pkgs.qt6.qtwayland
            pkgs.qt6.qmake
            pkgs.libsForQt5.qt5ct
            pkgs.qt6Packages.qt6ct
            pkgs.neovim
            pkgs.os-prober
            pkgs.vimPlugins.nvim-tree-lua
            pkgs.vimPlugins.nvim-web-devicons

            # Apps
            pkgs.foot
            (pkgs.wrapOBS {
              plugins = with pkgs.obs-studio-plugins; [
                wlrobs
                obs-pipewire-audio-capture
              ];
            })
            pkgs.pavucontrol
            pkgs.easyeffects
            pkgs.prismlauncher
            pkgs.file-roller

            # CLI tools
            pkgs.fastfetch
            pkgs.starship
            pkgs.btop
            pkgs.jq
            pkgs.eza
            pkgs.fuzzel
            pkgs.ripgrep
            pkgs.trash-cli
            pkgs.hyprpicker
            pkgs.wl-clipboard
            pkgs.cliphist
            pkgs.inotify-tools
            pkgs.grim
            pkgs.slurp
            pkgs.playerctl
            pkgs.p7zip

            # Caelestia dependencies
            pkgs.brightnessctl
            pkgs.gammastep
            pkgs.bluez-tools
            pkgs.wireplumber
            pkgs.ydotool

            # Coding
            pkgs.jetbrains.idea-ultimate
            pkgs.gradle
            pkgs.claude-code

            # Java
            pkgs.jdk17

            # Waywall dependencies
            pkgs.waywall
            pkgs.gcc
            pkgs.gnumake
            pkgs.cmake
            pkgs.meson
            pkgs.ninja
            pkgs.pkg-config
            pkgs.libGL
            pkgs.mesa
            pkgs.luajit
            pkgs.libspng
            pkgs.wayland
            pkgs.wayland.dev
            pkgs.wayland-scanner
            pkgs.wayland-protocols
            pkgs.xorg.libxcb
            pkgs.xorg.libxcb.dev
            pkgs.xorg.xcbutilwm
            pkgs.xorg.xcbutilimage
            pkgs.xorg.libXcomposite
            pkgs.xorg.libXres
            pkgs.xorg.libXtst
            pkgs.xwayland
            pkgs.libxkbcommon
            pkgs.libxkbcommon.dev
	    pkgs.mangohud
          ];

          systemd.user.services.polkit-gnome-authentication-agent-1 = {
            description = "polkit-gnome-authentication-agent-1";
            wantedBy = [ "graphical-session.target" ];
            wants = [ "graphical-session.target" ];
            after = [ "graphical-session.target" ];
            serviceConfig = {
              Type = "simple";
              ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
              Restart = "on-failure";
              RestartSec = 1;
              TimeoutStopSec = 10;
            };
          };
        })
      ];
    };
  };
}
