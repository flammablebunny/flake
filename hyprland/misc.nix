{ colors, ... }:

{
  wayland.windowManager.hyprland.settings = {
    misc = {
      vfr = true;
      vrr = 1;

      animate_manual_resizes = false;
      animate_mouse_windowdragging = false;

      disable_hyprland_logo = true;
      force_default_wallpaper = 0;
      disable_watchdog_warning = true;

      allow_session_lock_restore = true;
      middle_click_paste = false;
      focus_on_activate = true;
      session_lock_xray = true;

      mouse_move_enables_dpms = true;
      key_press_enables_dpms = true;

      background_color = "rgb(${colors.surfaceContainer})";
    };

    debug = {
      error_position = 1;
      # suppress_errors = true;
    };
  };
}
