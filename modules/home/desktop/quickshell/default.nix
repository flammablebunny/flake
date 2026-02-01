{ pkgs, config, lib, inputs, ... }:

let
  quickshellConfigSrc = ./config;

  # Fetch shapes library (QML rounded polygon drawing)
  shapesLib = pkgs.fetchFromGitHub {
    owner = "end-4";
    repo = "rounded-polygon-qmljs";
    rev = "b62e4482af56722840dd4b86c4dab41d5c9f2dda";
    hash = "sha256-WVkjTpFtJt6TFCi7tTBjsTUjRCFmYoQAlfqRwSCT2lY=";
  };

  # Build QML import path from packages
  # Use unwrapped kirigami to get actual QML modules
  kirigamiUnwrapped = pkgs.kdePackages.kirigami.unwrapped or pkgs.kdePackages.kirigami;
  qmlImportPath = lib.concatStringsSep ":" [
    "/run/current-system/sw/lib/qt-6/qml"
    "${kirigamiUnwrapped}/lib/qt-6/qml"
  ];

  # Wrapper script for quickshell with proper QML paths
  quickshellWrapper = pkgs.writeShellScriptBin "qs" ''
    export QML2_IMPORT_PATH="${qmlImportPath}"
    exec quickshell "$@"
  '';
in {
  # Add the wrapper to user's path
  home.packages = [
    quickshellWrapper
    pkgs.hypridle
    pkgs.gnome-calendar  # Google Calendar integration
  ];

  # Set QML2_IMPORT_PATH for the session
  home.sessionVariables = {
    QML2_IMPORT_PATH = qmlImportPath;
  };

  xdg.configFile."quickshell" = {
    source = quickshellConfigSrc;
    recursive = true;
    force = true; 
  };

  # Shapes library
  xdg.configFile."quickshell/modules/common/widgets/shapes" = {
    source = shapesLib;
    recursive = true;
    force = true;
  };

  # QuickShell config JSON - end-4 expects this at ~/.config/illogical-impulse/
  home.file.".config/illogical-impulse/config.json".text = builtins.toJSON {
    panelFamily = "ii";

    appearance = {
      fonts = {
        main = "JetBrains Mono NF";
        numbers = "JetBrains Mono NF";
        title = "JetBrains Mono NF";
        iconNerd = "JetBrains Mono NF";
        monospace = "JetBrains Mono NF";
        reading = "Rubik";
        expressive = "Rubik";
      };
      colors = {
        type = "scheme-expressive";  # Options: scheme-content, scheme-expressive, scheme-fidelity, scheme-fruit-salad, scheme-monochrome, scheme-neutral, scheme-rainbow, scheme-tonal-spot
      };
      transparency = {
        enable = true;
        automatic = true;
      };
      wallpaperTheming = {
        enableAppsAndShell = true;
        enableQtApps = false;
        enableTerminal = false;
      };
    };

    apps = {
      terminal = "foot";
      volumeMixer = "pavucontrol";
    };

    background = {
      wallpaperPath = "/home/AionFan/Pictures/Wallpapers/rabbit forest.png";
    };

    bar = {
      vertical = true;  # Left sidebar
      bottom = false;
      cornerStyle = 1;  # 0: Hug | 1: Float | 2: Plain
      verbose = true;
      topLeftIcon = "nixos"; 
      workspaces = {
        shown = 10;
        showAppIcons = false;
        alwaysShowNumbers = true;
        numberMap = ["1" "2" "3" "4" "5" "6" "7" "8" "9" "10"];
      };
      utilButtons = {
        showMicToggle = true;
        showPerformanceProfileToggle = true;
      };
      weather = {
        enable = true;
        city = "Berkeley, CA";
      };
    };

    battery = {
      low = 15;
      critical = 5;
      suspend = 3;
      automaticSuspend = true;
    };

    time = {
      format = "hh:mm";
      shortDateFormat = "MM/dd";
      dateFormat = "ddd, MM/dd";
      dateWithYearFormat = "MM/dd/yyyy";
    };

    lock = {
      launchOnStartup = false;  # Don't auto-lock on QuickShell start
      blur = {
        extraZoom = 1.05;
      };
    };

    security = {
      requirePasswordToPower = true;
    };

    interactions = {
      deadPixelWorkaround = {
        enable = true;  # Hyprland leaves 1 pixel on right/bottom edges - this fixes it
      };
    };

    policies = {
      weeb = 0;  # 0: No, 1: Yes, 2: Closet
    };

    sidebar = {
      cornerOpen = {
        enable = true;
        bottom = false;  # Use top corners (TopLeft for left sidebar, TopRight for right sidebar)
        cornerRegionWidth = 10;  # Wider for easier scroll at edge
        cornerRegionHeight = 1440;  # Full screen height (2560x1440)
        clickless = true;  # Open on hover, no click needed
        clicklessCornerEnd = true;  # Also trigger when mouse reaches edge
        valueScroll = true;  # Scroll to adjust brightness (left) or volume (right)
      };
      quickToggles = {
        style = "android";
        android = {
          columns = 5;
          toggles = [
            { size = 2; type = "network"; }
            { size = 2; type = "bluetooth"; }
            { size = 1; type = "idleInhibitor"; }
            { size = 2; type = "mic"; }
            { size = 2; type = "audio"; }
            { size = 1; type = "nightLight"; }
            { size = 1; type = "darkMode"; }
            { size = 1; type = "powerProfile"; }
            { size = 1; type = "gameMode"; }
            { size = 1; type = "notifications"; }
            { size = 1; type = "colorPicker"; }
          ];
        };
      };
    };

    regionSelector = {
      annotation = {
        useSatty = false;  # Use swappy for screenshot annotation
      };
      targetRegions = {
        windows = true;
        layers = true;
        content = false;
        opacity = 0.8;
      };
    };

    screenSnip = {
      savePath = "${config.home.homeDirectory}/Pictures/Screenshots";
    };
  };

  # Workspace toggle script
  home.file.".config/hypr/scripts/toggle-workspace.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      WORKSPACE_NAME="$1"
      CLASS="$2"
      shift 2
      COMMAND="$*"

      if hyprctl clients -j | jq -e ".[] | select(.class == \"$CLASS\")" > /dev/null 2>&1; then
          hyprctl dispatch togglespecialworkspace "$WORKSPACE_NAME"
      else
          hyprctl dispatch exec "[workspace special:$WORKSPACE_NAME silent] $COMMAND"
          sleep 0.3
          hyprctl dispatch togglespecialworkspace "$WORKSPACE_NAME"
      fi
    '';
  };

  # Screenshot script - ensures IPC call goes through reliably
  home.file.".config/hypr/scripts/screenshot.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      ACTION="''${1:-edit}"

      for i in 1 2 3; do
        if quickshell ipc call region "$ACTION" 2>/dev/null; then
          exit 0
        fi
        sleep 0.05
      done

      if [ "$ACTION" = "edit" ]; then
        grim -g "$(slurp)" - | swappy -f -
      else
        grim -g "$(slurp)" - | wl-copy
      fi
    '';
  };

  # Swappy config - screenshot annotation tool
  xdg.configFile."swappy/config".text = ''
    [Default]
    save_dir=${config.home.homeDirectory}/Pictures/Screenshots
    save_filename_format=screenshot-%Y-%m-%d_%H-%M-%S.png
    show_panel=false
    line_size=5
    text_size=20
    text_font=sans-serif
    paint_mode=brush
    early_exit=false
    fill_shape=false
  '';

  # Hypridle configuration for screen lock timeout
  xdg.configFile."hypr/hypridle.conf".text = ''
    general {
        lock_cmd = quickshell ipc call lock activate
        unlock_cmd = quickshell ipc call lock release
        before_sleep_cmd = quickshell ipc call lock activate
    }

    listener {
        timeout = 30
        on-timeout = quickshell ipc call lock activate
    }
  '';
}
