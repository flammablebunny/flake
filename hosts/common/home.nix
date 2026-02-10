{ inputs, pkgs, config, userName, ... }:

{
  imports = [
    ../../modules/home/desktop
    ../../modules/home/development
    ../../modules/home/apps
    ../../modules/home/services
    ../../modules/home/persistence
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
          pkgs.libx11
          pkgs.libxcb
          pkgs.libxt
          pkgs.libxtst
          pkgs.libxi
          pkgs.libxext
          pkgs.libxinerama
          pkgs.libxrender
          pkgs.libxfixes
          pkgs.libxrandr
          pkgs.libxcursor
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

  # Auto-encrypted git backup for user files
  services.persist-backup = {
    enable = true;
    ageRecipient = "age1vt7xwl0rgxcn2dadz7cq33vq74wzvcf6n9c4c09wgca0hrdqsecssyth5t";
    watchDirs = [
      # User files
      "$HOME/Documents"
      "$HOME/Downloads"
      "$HOME/Pictures"
      "$HOME/Music"
      "$HOME/Videos"
      "$HOME/Important"
      "$HOME/Commisions"

      # Code projects
      "$HOME/pro"
      "$HOME/Projects"

      # Browser profiles
      "$HOME/.zen"
      "$HOME/.mozilla"

      # SSH and Git (critical)
      "$HOME/.ssh"
      "$HOME/.config/git"

      # AI tools
      "$HOME/.claude"
      "$HOME/.codex"
      "$HOME/.config/Antigravity"

      # App configs (small, important settings)
      "$HOME/.config/discord"
      "$HOME/.config/Equicord"
      "$HOME/.config/spotify"
      "$HOME/.config/obs-studio"
      "$HOME/.config/easyeffects"
      "$HOME/.local/share/easyeffects"
      "$HOME/.config/Mullvad VPN"
      "$HOME/.config/OpenRGB"
      "$HOME/.config/cava"
      "$HOME/.config/lact"
      "$HOME/.config/JetBrains"

      # Gaming (configs and saves, not games)
      "$HOME/mcsr"
      "$HOME/Doki_Doki_Mods"
      "$HOME/.local/share/PrismLauncher"
      "$HOME/.local/share/MCSRLauncher"
      "$HOME/.minecraft"
      "$HOME/.renpy"

      # Shell and editor state
      "$HOME/.local/share/fish"
      "$HOME/.local/share/nvim"
      "$HOME/.local/state/nvim"

      # System (keyrings, clipboard)
      "$HOME/.local/share/keyrings"
      "$HOME/.cache/cliphist"
      "$HOME/.config/agenix"

      # Media production
      "$HOME/.local/share/DaVinciResolve"
    ];
    remoteUrl = "git@gitlab.com:flammablebunny/flake-persistent.git";
  };

  xdg.desktopEntries."org.quickshell" = {
    name = "Quickshell";
    exec = "quickshell";
    terminal = false;
    type = "Application";
    categories = [ "Utility" ];
    noDisplay = true;
  };
}
