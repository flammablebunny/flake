{
  apps = {
    terminal = "foot";
    browser = "zen";
    editor = "codium";
    fileExplorer = "thunar";
  };

  blur = {
    enabled = true;
    specialWs = false;
    popups = true;
    inputMethods = true;
    size = 8;
    passes = 2;
    xray = false;
  };

  shadow = {
    enabled = true;
    range = 20;
    renderPower = 3;
  };

  gaps = {
    workspaces = 20;
    windowsIn = 10;
    windowsOut = 40;
    singleWindowOut = 20;
  };

  window = {
    opacity = 0.95;
    rounding = 10;
    borderSize = 3;
  };

  misc = {
    volumeStep = 10;
  };

  cursor = {
    theme = "catppuccin-frappe-dark-cursors";
    size = 24;
  };

  keybinds = {
    moveWinToWs = "Super+Shift";
    moveWinToWsGroup = "Ctrl+Super+Alt";
    goToWs = "Super";
    goToWsGroup = "Ctrl+Super";

    nextWs = "Ctrl+Super, right";
    prevWs = "Ctrl+Super, left";

    toggleSpecialWs = "Super, S";

    windowGroupCycleNext = "Alt, Tab";
    windowGroupCyclePrev = "Shift+Alt, Tab";
    ungroup = "Super, U";
    toggleGroup = "Super, Comma";

    moveWindow = "Super, Z";
    resizeWindow = "Super, X";
    windowPip = "Super+Alt, Backslash";
    pinWindow = "Super, P";
    windowFullscreen = "Super, F";
    windowBorderedFullscreen = "Super+Alt, F";
    toggleWindowFloating = "Super, O";
    closeWindow = "Super, Q";

    systemMonitor = "Ctrl+Shift, Escape"; # Btop
    music = "Super, M";                   # Spotify
    communication = "Super, D";           # Discord (Nixcord)
    recording = "Super, R";               # OBS

    terminal = "Super, RETURN";
    browser = "Super, B";
    editor = "Super, C";
    fileExplorer = "Super, E";

    session = "Ctrl+Alt, Delete";
    clearNotifs = "Ctrl+Alt, C";
    showPanels = "Super, K";
    lock = "Super, L";
    restoreLock = "Super+Alt, L";
  };
}
