{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    input = {
      kb_layout = "us";
      numlock_by_default = false;
      repeat_delay = 250;
      repeat_rate = 35;
      focus_on_close = 1;
      natural_scroll = true;
    };

    binds = {
      scroll_event_delay = 0;
    };

    cursor = {
      hotspot_padding = 1;
    };
  };
}
