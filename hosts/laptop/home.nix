{ inputs, pkgs, config, userName, ... }:

{
  imports = [
    ../../modules/home/desktop/hyprland/env-laptop.nix
  ];

  xdg.configFile."caelestia/shell.json".source = ../../assets/shell-laptop.json;
}
