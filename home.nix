{ inputs, pkgs, ... }:

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

  programs.home-manager.enable = true;

  home.sessionPath = [ "$HOME/.npm-global/bin" ];

  home.packages = with pkgs; [
    nodejs_22
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
