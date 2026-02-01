{ vars, ... }:

{
  wayland.windowManager.hyprland.settings = {
    # Window rules (v3 syntax: match:<prop> <value>, <effect> <value>)
    windowrule = [
      # Opacity for non-fullscreen windows
      "match:fullscreen 0, opacity ${toString vars.window.opacity} override"

      # Opaque windows (native transparency or we want them opaque)
      "match:class foot|equibop|org\\.quickshell|imv|swappy, opaque true"

      # Center all floating windows (not xwayland cause popups)
      "match:float 1, match:xwayland 0, center 1"

      # Float rules
      "match:class guifetch, float true"
      "match:class yad, float true"
      "match:class zenity, float true"
      "match:class wev, float true"
      "match:class org\\.gnome\\.FileRoller, float true"
      "match:class file-roller, float true"
      "match:class blueman-manager, float true"
      "match:class com\\.github\\.GradienceTeam\\.Gradience, float true"
      "match:class feh, float true"
      "match:class imv, float true"
      "match:class system-config-printer, float true"
      "match:class org\\.quickshell, float true"

      # Float, resize and center - nmtui
      "match:class foot, match:title nmtui, float true"
      "match:class foot, match:title nmtui, size 60% 70%"
      "match:class foot, match:title nmtui, center 1"

      # Float, resize and center - GNOME Settings
      "match:class org\\.gnome\\.Settings, float true"
      "match:class org\\.gnome\\.Settings, size 70% 80%"
      "match:class org\\.gnome\\.Settings, center 1"

      # Float, resize and center - pavucontrol/yad-icon-browser
      "match:class org\\.pulseaudio\\.pavucontrol|yad-icon-browser, float true"
      "match:class org\\.pulseaudio\\.pavucontrol|yad-icon-browser, size 60% 70%"
      "match:class org\\.pulseaudio\\.pavucontrol|yad-icon-browser, center 1"

      # Float, resize and center - nwg-look
      "match:class nwg-look, float true"
      "match:class nwg-look, size 50% 60%"
      "match:class nwg-look, center 1"

      # Special workspaces
      "match:class btop, workspace special:sysmon"
      "match:class Spotify, workspace special:music"
      "match:class discord, workspace special:communication"
      "match:class com.obsproject.Studio|obs, workspace special:recording"

      # Dialogs
      "match:title (Select|Open)( a)? (File|Folder)(s)?, float true"
      "match:title File (Operation|Upload)( Progress)?, float true"
      "match:title .* Properties, float true"
      "match:title Export Image as PNG, float true"
      "match:title GIMP Crash Debug, float true"
      "match:title Save As, float true"
      "match:title Library, float true"

      # Picture in picture
      "match:title Picture(-| )in(-| )[Pp]icture, move 100%-w-2% 100%-w-3%"
      "match:title Picture(-| )in(-| )[Pp]icture, keep_aspect_ratio true"
      "match:title Picture(-| )in(-| )[Pp]icture, float true"
      "match:title Picture(-| )in(-| )[Pp]icture, pin true"

      # Steam
      "match:class steam, match:title ^$, rounding 10"
      "match:class steam, match:title Friends List, float true"
      "match:class steam_app_[0-9]+, immediate true"
      "match:class steam_app_[0-9]+, idle_inhibit always"

      # ATLauncher console
      "match:class com-atlauncher-App, match:title ATLauncher Console, float true"

      # Autodesk Fusion 360
      "match:class fusion360\\.exe, match:title Fusion360|(Marking Menu), no_blur true"

      # XWayland popups
      "match:xwayland 1, match:title win[0-9]+, no_dim true"
      "match:xwayland 1, match:title win[0-9]+, no_shadow true"
      "match:xwayland 1, match:title win[0-9]+, rounding 10"
    ];

    # Workspace rules
    workspace = [
      "w[tv1]s[false], gapsout:${toString vars.gaps.singleWindowOut}"
      "f[1]s[false], gapsout:${toString vars.gaps.singleWindowOut}"
    ];

    # Layer rules (v2 syntax: match:namespace <pattern>, <effect> <value>)
    layerrule = [
      # Animations
      "match:namespace hyprpicker, animation fade"
      "match:namespace logout_dialog, animation fade"
      "match:namespace selection, animation fade"
      "match:namespace wayfreeze, animation fade"

      # Fuzzel
      "match:namespace launcher, animation popin 80%"
      "match:namespace launcher, blur true"

      # Shell
      "match:namespace caelestia-(border-exclusion|area-picker), no_anim true"
      "match:namespace caelestia-(drawers|background), animation fade"
      "match:namespace caelestia-drawers, blur true"
      "match:namespace caelestia-drawers, ignore_alpha 0.57"
    ];
  };
}
