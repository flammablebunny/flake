{ vars, ... }:

let
  kb = vars.keybinds;
  apps = vars.apps;
  volumeStep = vars.misc.volumeStep;

  wsaction = "/home/bunny/.config/hypr/scripts/wsaction.fish";

  caelestia = "caelestia";
in
{
  wayland.windowManager.hyprland.settings = {
    exec = [ "hyprctl dispatch submap global" ];

    "$wsaction" = wsaction;
    "$caelestia" = caelestia;

    submap = "global";

    # Regular binds
    bind = [
      # Shell keybinds - Launcher
      "Super, Space, global, caelestia:launcher"

      # Misc shell
      "${kb.session}, global, caelestia:session"
      "${kb.showPanels}, global, caelestia:showall"
      "${kb.lock}, global, caelestia:lock"

      # Go to workspace
      "${kb.goToWs}, 1, exec, $wsaction workspace 1"
      "${kb.goToWs}, 2, exec, $wsaction workspace 2"
      "${kb.goToWs}, 3, exec, $wsaction workspace 3"
      "${kb.goToWs}, 4, exec, $wsaction workspace 4"
      "${kb.goToWs}, 5, exec, $wsaction workspace 5"
      "${kb.goToWs}, 6, exec, $wsaction workspace 6"
      "${kb.goToWs}, 7, exec, $wsaction workspace 7"
      "${kb.goToWs}, 8, exec, $wsaction workspace 8"
      "${kb.goToWs}, 9, exec, $wsaction workspace 9"
      "${kb.goToWs}, 0, exec, $wsaction workspace 10"

      # Go to workspace group
      "${kb.goToWsGroup}, 1, exec, $wsaction -g workspace 1"
      "${kb.goToWsGroup}, 2, exec, $wsaction -g workspace 2"
      "${kb.goToWsGroup}, 3, exec, $wsaction -g workspace 3"
      "${kb.goToWsGroup}, 4, exec, $wsaction -g workspace 4"
      "${kb.goToWsGroup}, 5, exec, $wsaction -g workspace 5"
      "${kb.goToWsGroup}, 6, exec, $wsaction -g workspace 6"
      "${kb.goToWsGroup}, 7, exec, $wsaction -g workspace 7"
      "${kb.goToWsGroup}, 8, exec, $wsaction -g workspace 8"
      "${kb.goToWsGroup}, 9, exec, $wsaction -g workspace 9"
      "${kb.goToWsGroup}, 0, exec, $wsaction -g workspace 10"

      # Toggle special workspace
      "${kb.toggleSpecialWs}, exec, $caelestia toggle specialws"

      # Move window to workspace
      "${kb.moveWinToWs}, 1, exec, $wsaction movetoworkspace 1"
      "${kb.moveWinToWs}, 2, exec, $wsaction movetoworkspace 2"
      "${kb.moveWinToWs}, 3, exec, $wsaction movetoworkspace 3"
      "${kb.moveWinToWs}, 4, exec, $wsaction movetoworkspace 4"
      "${kb.moveWinToWs}, 5, exec, $wsaction movetoworkspace 5"
      "${kb.moveWinToWs}, 6, exec, $wsaction movetoworkspace 6"
      "${kb.moveWinToWs}, 7, exec, $wsaction movetoworkspace 7"
      "${kb.moveWinToWs}, 8, exec, $wsaction movetoworkspace 8"
      "${kb.moveWinToWs}, 9, exec, $wsaction movetoworkspace 9"
      "${kb.moveWinToWs}, 0, exec, $wsaction movetoworkspace 10"

      # Move window to workspace group
      "${kb.moveWinToWsGroup}, 1, exec, $wsaction -g movetoworkspace 1"
      "${kb.moveWinToWsGroup}, 2, exec, $wsaction -g movetoworkspace 2"
      "${kb.moveWinToWsGroup}, 3, exec, $wsaction -g movetoworkspace 3"
      "${kb.moveWinToWsGroup}, 4, exec, $wsaction -g movetoworkspace 4"
      "${kb.moveWinToWsGroup}, 5, exec, $wsaction -g movetoworkspace 5"
      "${kb.moveWinToWsGroup}, 6, exec, $wsaction -g movetoworkspace 6"
      "${kb.moveWinToWsGroup}, 7, exec, $wsaction -g movetoworkspace 7"
      "${kb.moveWinToWsGroup}, 8, exec, $wsaction -g movetoworkspace 8"
      "${kb.moveWinToWsGroup}, 9, exec, $wsaction -g movetoworkspace 9"
      "${kb.moveWinToWsGroup}, 0, exec, $wsaction -g movetoworkspace 10"

      # Mouse move window to workspace
      "Super+Alt, mouse_down, movetoworkspace, -1"
      "Super+Alt, mouse_up, movetoworkspace, +1"

      # Move window to/from special workspace
      "Ctrl+Super+Shift, up, movetoworkspace, special:special"
      "Ctrl+Super+Shift, down, movetoworkspace, e+0"
      "Super+Alt, S, movetoworkspace, special:special"

      # Window groups
      "${kb.toggleGroup}, togglegroup"
      "${kb.ungroup}, moveoutofgroup"
      "Super+Shift, Comma, lockactivegroup, toggle"

      # Window focus/movement
      "Super, left, movefocus, l"
      "Super, right, movefocus, r"
      "Super, up, movefocus, u"
      "Super, down, movefocus, d"
      "Super+Shift, left, movewindow, l"
      "Super+Shift, right, movewindow, r"
      "Super+Shift, up, movewindow, u"
      "Super+Shift, down, movewindow, d"

      # Window center and resize
      "Ctrl+Super, Backslash, centerwindow, 1"
      "Ctrl+Super+Alt, Backslash, resizeactive, exact 55% 70%"
      "Ctrl+Super+Alt, Backslash, centerwindow, 1"
      "${kb.windowPip}, exec, $caelestia resizer pip"
      "${kb.pinWindow}, pin"
      "${kb.windowFullscreen}, fullscreen, 0"
      "${kb.windowBorderedFullscreen}, fullscreen, 1"
      "${kb.toggleWindowFloating}, togglefloating,"
      "${kb.closeWindow}, killactive,"

      # Special workspace toggles
      "${kb.systemMonitor}, exec, $caelestia toggle sysmon"
      "${kb.communication}, exec, $caelestia toggle communication"
      "${kb.recording}, exec, $caelestia toggle recording"
      "${kb.music}, exec, $caelestia toggle music"

      # Apps
      "${kb.terminal}, exec, app2unit -- ${apps.terminal}"
      "${kb.browser}, exec, app2unit -- ${apps.browser}"
      "${kb.editor}, exec, app2unit -- ${apps.editor}"
      "${kb.fileExplorer}, exec, app2unit -- ${apps.fileExplorer}"
      "Ctrl+Alt, Escape, exec, app2unit -- qps"
      "Ctrl+Alt, V, exec, app2unit -- pavucontrol"

      # Utilities
      "Super+Shift, S, global, caelestia:screenshotFreeze"
      "Super+Shift+Alt, S, global, caelestia:screenshot"
      "Super+Alt, R, exec, $caelestia record -s"
      "Ctrl+Alt, R, exec, $caelestia record"
      "Super+Shift+Alt, R, exec, $caelestia record -r"
      "Super+Shift, C, exec, hyprpicker -a"

      # Sleep
      "Super+Shift, L, exec, systemctl suspend-then-hibernate"

      # Clipboard and emoji picker
      "Super, V, exec, pkill fuzzel || $caelestia clipboard"
      "Super+Alt, V, exec, pkill fuzzel || $caelestia clipboard -d"
      "Super, Period, exec, pkill fuzzel || $caelestia emoji -p"
    ];

    # Lock-screen-safe binds (bindl)
    bindl = [
      "${kb.clearNotifs}, global, caelestia:clearNotifs"

      # Restore lock
      "${kb.restoreLock}, exec, env QSG_RENDER_LOOP=basic $caelestia shell -d"
      "${kb.restoreLock}, global, caelestia:lock"

      # Brightness
      ", XF86MonBrightnessUp, global, caelestia:brightnessUp"
      ", XF86MonBrightnessDown, global, caelestia:brightnessDown"

      # Media
      "Ctrl+Super, Space, global, caelestia:mediaToggle"
      ", XF86AudioPlay, global, caelestia:mediaToggle"
      ", XF86AudioPause, global, caelestia:mediaToggle"
      "Ctrl+Super, Equal, global, caelestia:mediaNext"
      ", XF86AudioNext, global, caelestia:mediaNext"
      "Ctrl+Super, Minus, global, caelestia:mediaPrev"
      ", XF86AudioPrev, global, caelestia:mediaPrev"
      ", XF86AudioStop, global, caelestia:mediaStop"

      # Volume
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      "Super+Shift, M, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

      # Screenshot
      ", Print, exec, $caelestia screenshot"

      # Clipboard paste
      "Ctrl+Shift+Alt, V, exec, sleep 0.5s && ydotool type -d 1 \"$(cliphist list | head -1 | cliphist decode)\""

    ];

    # Repeat binds (binde)
    binde = [
      # Workspace navigation
      "${kb.prevWs}, workspace, -1"
      "${kb.nextWs}, workspace, +1"
      "Super, Page_Up, workspace, -1"
      "Super, Page_Down, workspace, +1"

      # Move window to workspace
      "Super+Alt, Page_Up, movetoworkspace, -1"
      "Super+Alt, Page_Down, movetoworkspace, +1"
      "Ctrl+Super+Shift, right, movetoworkspace, +1"
      "Ctrl+Super+Shift, left, movetoworkspace, -1"

      # Window groups
      "${kb.windowGroupCycleNext}, cyclenext, activewindow"
      "${kb.windowGroupCyclePrev}, cyclenext, prev, activewindow"
      "Ctrl+Alt, Tab, changegroupactive, f"
      "Ctrl+Shift+Alt, Tab, changegroupactive, b"

      # Split ratio
      "Super, Minus, splitratio, -0.1"
      "Super, Equal, splitratio, 0.1"
    ];

    # Lock-screen-safe repeat binds (bindle)
    bindle = [
      # Volume
      ", XF86AudioRaiseVolume, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ ${toString volumeStep}%+"
      ", XF86AudioLowerVolume, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ ${toString volumeStep}%-"
    ]; 

    # Release binds (bindr)
    bindr = [
      # Kill/restart shell
      "Ctrl+Super+Shift, R, exec, $caelestia shell -k"
      "Ctrl+Super+Alt, R, exec, $caelestia shell -k; env QSG_RENDER_LOOP=basic $caelestia shell -d"
    ];

    # Mouse binds for dragging windows
    bindm = [
      "Super, mouse:272, movewindow"
      "Super, mouse:273, resizewindow"
      "Super, X, movewindow"
      "Super, Z, resizewindow"
    ];
  };
}
