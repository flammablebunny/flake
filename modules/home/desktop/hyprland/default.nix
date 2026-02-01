{ config, pkgs, lib, ... }:

let
  # Import configuration data
  colors = import ./common/colors.nix;
  vars = import ./common/variables.nix;

  # Common arguments passed to all submodules
  moduleArgs = { inherit colors vars pkgs lib config; };
in
{
  imports = [
    # Device-specific configs (env.nix, input.nix, general.nix) are imported per-host in hosts/*/home.nix
    (import ./common/decoration.nix moduleArgs)
    (import ./common/animations.nix moduleArgs)
    (import ./common/misc.nix moduleArgs)
    (import ./common/group.nix moduleArgs)
    (import ./common/rules.nix moduleArgs)
    (import ./common/execs.nix moduleArgs)
    (import ./common/keybinds.nix moduleArgs)
    (import ./common/scripts.nix moduleArgs)
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
