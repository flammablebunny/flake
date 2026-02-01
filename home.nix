{ inputs, pkgs, config, ... }:

{
  imports = [
    ./nvim.nix
    ./spicetify.nix
    ./nixcraft.nix
    ./nixcord.nix
    ./hyprland

    # Application configs
    /etc/nixos/modules/fastfetch.nix
    /etc/nixos/modules/fish.nix
    /etc/nixos/modules/foot.nix
    /etc/nixos/modules/mangohud.nix
    /etc/nixos/modules/obs.nix
    /etc/nixos/modules/thunar.nix
    /etc/nixos/modules/waywall.nix
    /etc/nixos/modules/paceman.nix
    /etc/nixos/modules/easyeffects.nix
  ];

  home.username = "bunny";
  home.homeDirectory = "/home/bunny";
  home.stateVersion = "24.05";

  home.pointerCursor = {
    name = "catppuccin-frappe-dark-cursors";
    package = pkgs.catppuccin-cursors.frappeDark;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
  };

  programs.home-manager.enable = true;

  home.sessionPath = [ "$HOME/.npm-global/bin" ];

  home.packages = with pkgs; [
    nodejs_22
    (writeShellScriptBin "java" ''
      #!/usr/bin/env bash
      set -euo pipefail

      extra_libs="${
        pkgs.lib.makeLibraryPath [
          pkgs.libxkbcommon
          pkgs.xorg.libX11
          pkgs.xorg.libxcb
          pkgs.xorg.libXt
          pkgs.xorg.libXtst
          pkgs.xorg.libXi
          pkgs.xorg.libXext
          pkgs.xorg.libXinerama
          pkgs.xorg.libXrender
          pkgs.xorg.libXfixes
          pkgs.xorg.libXrandr
          pkgs.xorg.libXcursor
        ]
      }"

      if [[ -n "''${LD_LIBRARY_PATH:-}" ]]; then
        export LD_LIBRARY_PATH="$extra_libs:$LD_LIBRARY_PATH"
      else
        export LD_LIBRARY_PATH="$extra_libs"
      fi

      exec /run/current-system/sw/bin/java "$@"
    '')
  ];

  xdg.configFile."caelestia/shell.json".source = ./shell.json;

  xdg.desktopEntries."org.quickshell" = {
    name = "Quickshell";
    exec = "quickshell";
    terminal = false;
    type = "Application";
    categories = [ "Utility" ];
    noDisplay = true;
  };
}
