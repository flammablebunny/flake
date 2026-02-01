{ vars, ... }:

{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      # Keyring and auth
      "gnome-keyring-daemon --start --components=secrets"
      # polkit-gnome is handled by systemd service in flake.nix

      # Clipboard history
      "wl-paste --type text --watch cliphist store"
      "wl-paste --type image --watch cliphist store"

      # Auto delete trash 20 days old
      "trash-empty 20"

      # Cursors
      "hyprctl setcursor ${vars.cursor.theme} ${toString vars.cursor.size}"
      "gsettings set org.gnome.desktop.interface cursor-theme '${vars.cursor.theme}'"
      "gsettings set org.gnome.desktop.interface cursor-size ${toString vars.cursor.size}"

      # Location provider and night light
      "/run/current-system/sw/libexec/geoclue-2.0/demos/agent || true"
      "sleep 1 && gammastep || true"

      # Forward bluetooth media commands to MPRIS
      "mpris-proxy"

      # Resize and move windows based on matches (e.g. pip)
      "caelestia resizer -d"

      # Start shell
      "caelestia shell -d"

      # Start EasyEffects
      "easyeffects --gapplication-service"
    ];
  };
}
