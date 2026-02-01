{ inputs, pkgs, config, ... }:

{
  imports = [
    ../../modules/home/gaming
    ../../modules/home/desktop/hyprland/env-pc.nix
  ];

  xdg.configFile."caelestia/shell.json".source = ../../assets/shell-pc.json;
}
