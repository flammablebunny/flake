{ pkgs, ... }:

let
  wrappedObs = pkgs.wrapOBS {
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-pipewire-audio-capture
    ];
  };
in {
  home.packages = [
    (pkgs.writeShellScriptBin "obs" ''
      # Fix CEF sandbox failure (exit code 21) on Wayland/NixOS
      export OBS_USE_EGL=1
      export QTWEBENGINE_DISABLE_SANDBOX=1
      exec ${wrappedObs}/bin/obs --no-sandbox "$@"
    '')
  ];

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
