{ config, lib, pkgs, userName, ... }:

let
  cfg = config.custom.persistence;
  homeDir = config.home.homeDirectory;
in
{
  options.custom.persistence = {
    enable = lib.mkEnableOption "Home directory persistence via impermanence";

    persistPath = lib.mkOption {
      type = lib.types.str;
      default = "/persist/home/${userName}";
      description = "Path to persistent home storage";
    };

    extraDirectories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Additional directories to persist";
    };

    extraFiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Additional files to persist";
    };
  };

  config = lib.mkIf cfg.enable {
    home.persistence.${cfg.persistPath} = {
      allowOther = true;

      directories = [
        # === Browser ===
        ".zen"                           # Zen Browser profile
        ".mozilla"                       # Firefox/Mozilla sync data
        ".config/chromium"               # Chromium profile

        # === Development ===
        ".ssh"                           # SSH keys and config
        ".config/git"                    # Git config
        ".config/JetBrains"              # JetBrains IDE config
        ".local/share/JetBrains"         # JetBrains IDE data
        ".gradle"                        # Gradle cache
        ".m2"                            # Maven cache
        ".npm"                           # npm cache
        ".npm-global"                    # Global npm packages
        ".java"                          # Java settings
        ".jdks"                          # Java JDKs
        ".android"                       # Android SDK

        # === AI/CLI Tools ===
        ".claude"                        # Claude CLI config
        ".claude.json"
        ".config/Antigravity"            # Antigravity AI

        # === Applications ===
        ".config/discord"                # Discord
        ".config/Equicord"               # Equicord (Discord mod)
        ".config/spotify"                # Spotify
        ".config/obs-studio"             # OBS Studio
        ".local/share/Steam"             # Steam games and config
        ".steam"                         # Steam runtime
        ".config/easyeffects"            # EasyEffects audio
        ".local/share/easyeffects"       # EasyEffects presets
        ".config/Mullvad VPN"            # Mullvad VPN settings
        ".mullvad"                       # Mullvad data
        ".config/OpenRGB"                # OpenRGB profiles
        ".config/cava"                   # Cava audio visualizer
        ".config/lact"                   # LACT GPU control

        # === Gaming ===
        ".local/share/PrismLauncher"     # Prism Launcher (Minecraft)
        ".local/share/MCSRLauncher"      # MCSR Launcher
        ".minecraft"                     # Minecraft data
        "mcsr"                           # MCSR files
        ".wine"                          # Wine prefix
        ".renpy"                         # Ren'Py game saves
        "Doki_Doki_Mods"                 # DDLC mods

        # === Shell ===
        ".local/share/fish"              # Fish shell history

        # === Editor ===
        ".local/share/nvim"              # Neovim state
        ".local/state/nvim"              # Neovim state

        # === System ===
        ".cache/cliphist"                # Clipboard cache
        ".config/agenix"                 # Age encryption key
        ".local/share/keyrings"          # GNOME Keyring
        ".pki"                           # Certificates

        # === Media ===
        ".local/share/DaVinciResolve"    # DaVinci Resolve

        # === User Files ===
        "Documents"
        "Downloads"
        "Pictures"
        "Videos"
        "Music"
        "pro"                            # Projects
        "Projects"                       # Projects (alternate)
        "Commisions"                     # Commissions folder
        "Important"                      # Important files

        # === Persist Backup ===
        ".local/share/flake-persistent"    # Encrypted backup repo
      ] ++ cfg.extraDirectories;

      files = [
        ".config/monitors.xml"           # Display configuration
      ] ++ cfg.extraFiles;
    };
  };
}
