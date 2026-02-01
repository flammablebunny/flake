{ pkgs, ... }:

{
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      # Add any plugins you use here, e.g.:
      # obs-vkcapture
      # obs-pipewire-audio-capture
    ];
  };

  # OBS generates most of its config at runtime (scenes, profiles, etc.)
  # We only seed the global.ini with preferred settings
  xdg.configFile."obs-studio/global.ini" = {
    force = true;
    text = ''
    [General]
    MaxLogs=10
    InfoIncrement=-1
    ProcessPriority=Normal
    EnableAutoUpdates=true
    BrowserHWAccel=true

    [Video]
    Renderer=OpenGL
    '';
  };
}
