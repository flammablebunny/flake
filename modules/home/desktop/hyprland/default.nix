{ config, pkgs, lib, ... }:

let
  # Import configuration data
  colors = import ./colors.nix;
  vars = import ./variables.nix;

  # Common arguments passed to all submodules
  moduleArgs = { inherit colors vars pkgs lib config; };
in
{
  imports = [
    (import ./env.nix moduleArgs)
    (import ./general.nix moduleArgs)
    (import ./input.nix moduleArgs)
    (import ./decoration.nix moduleArgs)
    (import ./animations.nix moduleArgs)
    (import ./misc.nix moduleArgs)
    (import ./group.nix moduleArgs)
    (import ./rules.nix moduleArgs)
    (import ./execs.nix moduleArgs)
    (import ./keybinds.nix moduleArgs)
    (import ./scripts.nix moduleArgs)
  ];

  # Enable Hyprland via Home Manager
  wayland.windowManager.hyprland = {
    enable = true;

    # Use the system-installed Hyprland package
    # (already configured in flake.nix via programs.hyprland)
    package = null;

    # Use system portal configuration
    systemd = {
      enable = false;  # We use custom exec-once instead
    };

    # XWayland support
    xwayland.enable = true;
  };
}
