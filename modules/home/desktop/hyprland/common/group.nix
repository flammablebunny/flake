{ colors, ... }:

{
  wayland.windowManager.hyprland.settings = {
    group = {
      "col.border_active" = "rgba(${colors.primary}e6)";
      "col.border_inactive" = "rgba(${colors.onSurfaceVariant}11)";
      "col.border_locked_active" = "rgba(${colors.primary}e6)";
      "col.border_locked_inactive" = "rgba(${colors.onSurfaceVariant}11)";

      groupbar = {
        font_family = "JetBrains Mono NF";
        font_size = 15;
        gradients = true;
        gradient_round_only_edges = false;
        gradient_rounding = 5;
        height = 25;
        indicator_height = 0;
        gaps_in = 3;
        gaps_out = 3;

        text_color = "rgb(${colors.onPrimary})";
        "col.active" = "rgba(${colors.primary}d4)";
        "col.inactive" = "rgba(${colors.outline}d4)";
        "col.locked_active" = "rgba(${colors.primary}d4)";
        "col.locked_inactive" = "rgba(${colors.secondary}d4)";
      };
    };
  };
}
