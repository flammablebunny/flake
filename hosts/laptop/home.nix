{ inputs, pkgs, config, userName, ... }:

{
  imports = [
    ../../modules/home/desktop/hyprland/laptop/env.nix
    ../../modules/home/desktop/hyprland/laptop/input.nix
    ../../modules/home/desktop/hyprland/laptop/general.nix
    ../../modules/home/desktop/hyprland/laptop/rules.nix
    ../../modules/home/desktop/hyprland/laptop/keybinds.nix
  ];

  xdg.configFile."caelestia/shell.json".source = ../../assets/shell-laptop.json;
}
