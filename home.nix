{ inputs, pkgs, ... }:

{
  imports = [
    ./nvim.nix
    ./spicetify.nix
    ./nixcraft.nix
    ./nixcord.nix
  ];

  home.username = "bunny";
  home.homeDirectory = "/home/bunny";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  home.sessionPath = [ "$HOME/.npm-global/bin" ];

  home.packages = with pkgs; [
    nodejs_22
  ];

  xdg.configFile."caelestia/shell.json".source = ./shell.json;
 
}
