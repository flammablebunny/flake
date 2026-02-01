{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    input = {
      kb_layout = "us";
      numlock_by_default = false;
      repeat_delay = 250;
      repeat_rate = 35;
      focus_on_close = 1;
    };

    binds = {
      scroll_event_delay = 0;
    };

    cursor = {
      hotspot_padding = 1;
    };

    # Per-device configurations
    device = [
      {
        name = "razer-razer-viper-v3-pro";
        accel_profile = "flat";
        sensitivity = -0.68;
      }
      {
        name = "turtle-beach-burst-ii-air-dongle-mouse";
        accel_profile = "flat";
        sensitivity = -0.86;
      }
      {
        name = "company--usb-device--1";
        accel_profile = "flat";
        sensitivity = -0.7;
      }
    ];
  };
}
