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

    lazyvim-module = {
      url = "github:matadaniel/LazyVim-module";
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
      url = "git+file:///home/bunny/IdeaProjects/nixcraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "git+file:///home/bunny/IdeaProjects/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, caelestia-shell, caelestia-cli, lazyvim-module, zen-browser, spicetify-nix, nixcord, nixcraft, hyprland, agenix,  ... }@inputs: {
    nixosConfigurations.iusenixbtw = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        ./dualgpu.nix
        hyprland.nixosModules.default
        agenix.nixosModules.default
        home-manager.nixosModules.home-manager

        ({ pkgs, inputs, ... }: {
          nixpkgs.config.allowUnfree = true;

          nixpkgs.overlays = [
            (final: prev: {
              quickshell = prev.quickshell.overrideAttrs (old: {
                cmakeBuildType = "Release";
                dontStrip = false;
              });
            })
          ];

          # Home Manager configuration
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.bunny = import ./home.nix;

          programs.dconf.enable = true;
          programs.hyprland = {
            enable = true;
            package = inputs.hyprland.packages.${pkgs.system}.hyprland;
            portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
            xwayland.enable = true;
            withUWSM = false;
          };
          programs.fish.enable = true;
          programs.xfconf.enable = true;

          programs.thunar = {
            enable = true;            plugins = with pkgs.xfce; [
              thunar-archive-plugin
              thunar-volman
            ];
          };

         programs.steam = {
            enable = true;
            remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
            dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
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
              pkgs.xdg-desktop-portal-gtk
            ];
            config.common.default = "gtk";
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
              cmakeBuildType = "Release";
              dontStrip = false;
              postPatch = (old.postPatch or "") + ''
                find . -type f -name "*.qml" -exec sed -i 's|https://wttr.in|http://wttr.in|g' {} +
                find . -type f -name "shell.qml" -exec sed -i 's|//@ pragma Env QSG_RENDER_LOOP=threaded|//@ pragma Env QSG_RENDER_LOOP=basic|g' {} +
              '';
            }))

            inputs.zen-browser.packages.${pkgs.system}.default
            caelestia-cli.packages.${pkgs.system}.default

            # Desktop environment essentials
            pkgs.xfce.thunar
            pkgs.nwg-look
            pkgs.gvfs
            pkgs.tree
            pkgs.polkit_gnome
            pkgs.gnome-keyring

            # Theming
            pkgs.gsettings-desktop-schemas
            pkgs.glib
            pkgs.adw-gtk3
            pkgs.papirus-icon-theme
            pkgs.catppuccin-cursors.frappeDark
            pkgs.gtk3

            # Core tools
            pkgs.git
            pkgs.fd
	         pkgs.wget
            pkgs.socat
	         pkgs.os-prober
	         pkgs.toybox
            pkgs.libnotify
            pkgs.qt6.qtwayland
            pkgs.qt6.qmake
            pkgs.libsForQt5.qt5ct
            pkgs.qt6Packages.qt6ct
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
            pkgs.vlc
            pkgs.wineWowPackages.wayland
            pkgs.steam
            pkgs.virt-manager
            pkgs.radeontop
            pkgs.amdgpu_top

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
            pkgs.mullvad
            pkgs.mullvad-browser
            pkgs.inotify-tools
            pkgs.grim
            pkgs.slurp
            pkgs.playerctl
            pkgs.p7zip
            pkgs.go
            pkgs.fzf
            pkgs.luajitPackages.luarocks
            pkgs.python3

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
            pkgs.antigravity

            # Java
            pkgs.jdk17
            pkgs.graalvmPackages.graalvm-oracle_17

            # Nixcraft tools
            nixcraft.packages.${pkgs.system}.nixcraft-cli
            nixcraft.packages.${pkgs.system}.nixcraft-auth
            nixcraft.packages.${pkgs.system}.nixcraft-skin

            # Waywall dependencies
            pkgs.waywall
            pkgs.cmake
            pkgs.meson
            pkgs.ninja
            pkgs.mesa
            pkgs.luajit
            pkgs.libspng
            pkgs.wayland
            pkgs.wayland.dev
            pkgs.wayland-scanner
            pkgs.wayland-protocols
            pkgs.xwayland
            pkgs.libxkbcommon
            pkgs.libxkbcommon.dev
	         pkgs.mangohud

            # Secrets management
            agenix.packages.${pkgs.system}.default
          ];

          # Agenix secrets configuration
          age.identityPaths = [ "/home/bunny/.config/agenix/key.txt" ];
          age.secrets = {
            waywall-oauth = {
              file = ./secrets/waywall-oauth.age;
              owner = "bunny";
              group = "users";
              mode = "0400";
            };
            paceman-key = {
              file = ./secrets/paceman-key.age;
              owner = "bunny";
              group = "users";
              mode = "0400";
            };
            "wallpaper-rabbit-forest" = {
              file = ./secrets/wallpapers/rabbit_forest.png.age;
              path = "/home/bunny/Pictures/Wallpapers/rabbit forest.png";
              owner = "bunny";
              group = "users";
              mode = "0644";
            };
            "wallpaper-rabbit-forest-no-grain" = {
              file = ./secrets/wallpapers/rabbit_forest_no_grain.png.age;
              path = "/home/bunny/Pictures/Wallpapers/rabbit forest no grain.png";
              owner = "bunny";
              group = "users";
              mode = "0644";
            };
            "wallpaper-rabbit-forest-no-grain-no-particles" = {
              file = ./secrets/wallpapers/rabbit_forest_no_grain_no_particles.png.age;
              path = "/home/bunny/Pictures/Wallpapers/rabbit forest no grain no particles.png";
              owner = "bunny";
              group = "users";
              mode = "0644";
            };
            "wallpaper-rabbit-forest-no-particles" = {
              file = ./secrets/wallpapers/rabbit_forest_no_particles.png.age;
              path = "/home/bunny/Pictures/Wallpapers/rabbit forest no particles.png";
              owner = "bunny";
              group = "users";
              mode = "0644";
            };
            "wallpaper-rabbit-forest-no-sign" = {
              file = ./secrets/wallpapers/rabbit_forest_no_sign.png.age;
              path = "/home/bunny/Pictures/Wallpapers/rabbit forest no sign.png";
              owner = "bunny";
              group = "users";
              mode = "0644";
            };
            "wallpaper-rabbit-forest-no-sign-no-grain" = {
              file = ./secrets/wallpapers/rabbit_forest_no_sign_no_grain.png.age;
              path = "/home/bunny/Pictures/Wallpapers/rabbit forest no sign no grain.png";
              owner = "bunny";
              group = "users";
              mode = "0644";
            };
            "wallpaper-rabbit-forest-no-sign-no-grain-no-particles" = {
              file = ./secrets/wallpapers/rabbit_forest_no_sign_no_grain_no_particles.png.age;
              path = "/home/bunny/Pictures/Wallpapers/rabbit forest no sign no grain no particles.png";
              owner = "bunny";
              group = "users";
              mode = "0644";
            };
            "wallpaper-rabbit-forest-no-sign-no-particles" = {
              file = ./secrets/wallpapers/rabbit_forest_no_sign_no_particles.png.age;
              path = "/home/bunny/Pictures/Wallpapers/rabbit forest no sign no particles.png";
              owner = "bunny";
              group = "users";
              mode = "0644";
            };
          };

          systemd.tmpfiles.rules = [
            "d /home/bunny/Pictures/Wallpapers 0755 bunny users -"
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
