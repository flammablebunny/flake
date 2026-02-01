{ inputs, pkgs, ... }:

{
  imports = [
    ./spicetify.nix
    ./nixcraft.nix
    ./nixcord.nix
  ];

  home.username = "bunny";
  home.homeDirectory = "/home/bunny";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  xdg.configFile."caelestia/shell.json".source = ./shell.json;
 
}
