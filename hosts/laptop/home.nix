{ inputs, pkgs, config, userName, ... }:

{
  imports = [
    ../../modules/home/gaming/mangohud.nix
    ../../modules/home/gaming/paceman.nix
    ../../modules/home/gaming/waywall
    ../../modules/home/desktop/hyprland/laptop/env.nix
    ../../modules/home/desktop/hyprland/laptop/input.nix
    ../../modules/home/desktop/hyprland/laptop/general.nix
    ../../modules/home/desktop/hyprland/laptop/rules.nix
    ../../modules/home/desktop/hyprland/laptop/keybinds.nix
  ];
}
