{ inputs, pkgs, config, ... }:

{
  imports = [
    ../../modules/home/gaming
    ../../modules/home/desktop/hyprland/pc/env.nix
    ../../modules/home/desktop/hyprland/pc/input.nix
    ../../modules/home/desktop/hyprland/pc/general.nix
  ];

  xdg.configFile."caelestia/shell.json".source = ../../assets/shell-pc.json;
}
