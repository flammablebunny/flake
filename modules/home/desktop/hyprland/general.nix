{ vars, colors, ... }:

{
  wayland.windowManager.hyprland.settings = {
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
