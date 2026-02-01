{ vars, colors, ... }:

{
  wayland.windowManager.hyprland.settings = {
    decoration = {
      rounding = vars.window.rounding;

      blur = {
        enabled = vars.blur.enabled;
        xray = vars.blur.xray;
        special = vars.blur.specialWs;
        ignore_opacity = true;  # Allows opacity blurring
        new_optimizations = true;
        popups = vars.blur.popups;
        input_methods = vars.blur.inputMethods;
        size = vars.blur.size;
        passes = vars.blur.passes;
      };

      shadow = {
        enabled = vars.shadow.enabled;
        range = vars.shadow.range;
        render_power = vars.shadow.renderPower;
        color = "rgba(${colors.surface}d4)";
      };
    };
  };
}
