{ ... }:

let
  vars = import ../common/variables.nix;
  colors = import ../common/colors.nix;
in
{
  wayland.windowManager.hyprland.settings = {
    monitor = "eDP-1,2880x1800@120,0x0,1.67";

    general = {
      layout = "dwindle";
      allow_tearing = false;

      gaps_workspaces = vars.gaps.workspaces;
      gaps_in = vars.gaps.windowsIn;
      gaps_out = vars.gaps.windowsOut;
      border_size = vars.window.borderSize;

      "col.active_border" = "rgba(${colors.primary}e6)";
      "col.inactive_border" = "rgba(${colors.onSurfaceVariant}11)";
    };

    dwindle = {
      preserve_split = true;
      smart_split = false;
      smart_resizing = true;
    };
  };
}
