{ inputs, pkgs, config, userName, ... }:

{
  imports = [
    ../../modules/home/desktop
    ../../modules/home/development
    ../../modules/home/apps
    ../../modules/home/services
  ];

  home.username = userName;
  home.homeDirectory = "/home/${userName}";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  home.sessionPath = [ "$HOME/.npm-global/bin" ];

  home.packages = with pkgs; [
    nodejs_22
    (writeShellScriptBin "java" ''
      #!/usr/bin/env bash
      set -euo pipefail

      extra_libs="${
        pkgs.lib.makeLibraryPath [
          pkgs.libxkbcommon
          pkgs.xorg.libX11
          pkgs.xorg.libxcb
          pkgs.xorg.libXt
          pkgs.xorg.libXtst
          pkgs.xorg.libXi
          pkgs.xorg.libXext
          pkgs.xorg.libXinerama
          pkgs.xorg.libXrender
          pkgs.xorg.libXfixes
          pkgs.xorg.libXrandr
          pkgs.xorg.libXcursor
        ]
      }"

      if [[ -n "''${LD_LIBRARY_PATH:-}" ]]; then
        export LD_LIBRARY_PATH="$extra_libs:$LD_LIBRARY_PATH"
      else
        export LD_LIBRARY_PATH="$extra_libs"
      fi

      exec /run/current-system/sw/bin/java "$@"
    '')
  ];

  xdg.portal.config.common.default = "*";

  xdg.desktopEntries."org.quickshell" = {
    name = "Quickshell";
    exec = "quickshell";
    terminal = false;
    type = "Application";
    categories = [ "Utility" ];
    noDisplay = true;
  };
}
