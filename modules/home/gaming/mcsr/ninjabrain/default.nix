{ inputs, ... }:

{
  imports = [
    inputs.ninjabrain-bot-nix.homeModules.default
  ];

  programs.ninjabrain-bot = {
    enable = true;
    force = true;

    settings = {
      # === Basic ===
      show_nether_coords = true;
      auto_reset = false;
      always_on_top = true;
      translucent = false;
      check_for_updates = true;
      stronghold_display_type = "eighteight";
      view = "detailed";
      size = "medium";
      mc_version = "pre_119";
      language_v2 = "en-US";

      # === Advanced ===
      sigma = 0.1;                    # Standard deviation (1.13+)
      sigma_manual = 0.03;            # Standard deviation (1.9-1.12)
      crosshair_correction = 0;
      show_angle_errors = false;
      color_negative_coords = true;
      use_adv_statistics = true;
      alt_clipboard_reader = false;
      enable_http_server = false;
      save_state = true;

      # === Hotkeys (jnativehook VC_ key codes) ===
      hotkey_increment = { key = 13; modifiers = []; };  # VC_EQUALS
      hotkey_decrement = { key = 12; modifiers = []; };  # VC_MINUS
      hotkey_reset = { key = 11; modifiers = []; };      # VC_0
      hotkey_undo = { key = 26; modifiers = []; };       # VC_OPEN_BRACKET
      hotkey_redo = { key = 27; modifiers = []; };       # VC_CLOSE_BRACKET
      hotkey_lock = { key = 43; modifiers = []; };       # VC_BACK_SLASH

      # === Optional Features > General ===
      direction_help_enabled = true;
      mismeasure_warning_enabled = false;
      portal_linking_warning_enabled = true;
      combined_offset_information_enabled = false;

      # === Optional Features > Angle Adjustment ===
      angle_adjustment_display_type = "increments";
      angle_adjustment_type = "tall";
      resolution_height = 16384;

      # === Optional Features > Boat Measurement ===
      use_precise_angle = true;
      sensitivity_manual = 0.0229116492;  # 1.9-1.12
      sensitivity = 0.02291165;           # 1.13+
      hotkey_boat = { key = 3639; modifiers = [ "SHIFT_L" ]; };  # Shift+PrintScreen
      default_boat_type = "blue";
      boat_error = 0.03;
      sigma_boat = 0.0007;
    };
  };
}
