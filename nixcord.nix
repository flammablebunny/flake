{ inputs, pkgs, ... }:

{
  imports = [ 
    inputs.nixcord.homeModules.nixcord 
  ];

  programs.nixcord = {
    enable = true;

    discord = {
      enable = true;
      package = pkgs.discord.override { withOpenASAR = true; };
      equicord.enable = true;
      vencord.enable = false;
    };

    config = {
      autoUpdate = false;
      autoUpdateNotification = false;
      enableReactDevtools = false;
      frameless = false;
      notifyAboutUpdates = false;
      transparent = false;
      useQuickCSS = false;
      
      enabledThemes = [ "Caelestia" ];
      themes = {
        "Caelestia" = builtins.readFile /etc/nixos/themes/caelestia/caelestia.theme.css;
      };

      plugins = {

        "AllCallTimers" = {
          enable = true;
          format = "human";
          showRoleColor = true;
          showSeconds = true;
          showWithoutHover = true;
          trackSelf = true;
          watchLargeGuilds = false;
        };

        "AlwaysExpandProfiles" = {
          enable = true;
        };

        "Anammox" = {
          enable = true;
          billing = false;
          dms = true;
          emojiList = false;
          gift = true;
          serverBoost = true;
        };

        "BetterActivities" = {
          enable = true;
          memberList = true;
          iconSize = 15;
          specialFirst = true;
          renderGifs = true;
          removeGameActivityStatus = false;
          userPopout = true;
          hideTooltip = true;
          allActivitiesStyle = "carousel"";
        };

        "BetterBlockedUsers" = {
          enable = true;
        };

        "BetterFolders" = {
          enable = true;
          closeAllFolders = false;
          closeAllHomeButton = false;
          closeOthers = false;
          closeServerFolder = false;
          forceOpen = false;
          keepIcons = false;
          showFolderIcon = "FolderIconDisplay.Always";
          sidebar = true;
          sidebarAnim = true;
        };

        "BetterGifPicker" = {
          enable = true;
        };

        "BetterQuickReact" = {
          enable = true;
          columns = 4.0;
          compactMode = false;
          frequentEmojis = true;
          rows = 2.0;
          scroll = true;
        };

        "BlurNsfw" = {
          enable = true;
          blurAllChannels = false;
          blurAmount = 10;
        };

        "CallTimer" = {
          enable = true;
          format = "human";
        };

        "ClearUrLs" = {
          enable = true;
        };

        "CopyFileContents" = {
          enable = true;
        };

        "CrashHandler" = {
          enable = true;
          attemptToNavigateToHome = false;
          attemptToPreventCrashes = true;
        };

        "DisableCallIdle" = {
          enable = true;
        };

        "ExpressionCloner" = {
          enable = true;
        };

        "FavoriteGifSearch" = {
          enable = true;
          searchOption = "url";
        };

        "FixImagesQuality" = {
          enable = true;
        };

        "FixSpotifyEmbeds" = {
          enable = true;
          volume = 10.0;
        };

        "FixYoutubeEmbeds" = {
          enable = true;
        };

        "ForceOwnerCrown" = {
          enable = true;
        };

        "GifPaste" = {
          enable = true;
        };

        "GifRoulette" = {
          enable = true;
          pingOwnerChance = false;
        };

        "IgnoreTerms" = {
          enable = true;
        };

        "ImageZoom" = {
          enable = true;
          invertScroll = true;
          nearestNeighbour = false;
          saveZoomValues = true;
          size = 100.0;
          square = true;
          zoom = 2.0;
          zoomSpeed = 0.5;
        };

        "KeyboardNavigation" = {
          enable = true;
          allowMouseControl = true;
          hotkey = [];
        };

        "MemberCount" = {
          enable = true;
          memberList = true;
          toolTip = true;
          voiceActivity = true;
        };

        "MessageClickActions" = {
          enable = true;
          enableDeleteOnClick = true;
          enableDoubleClickToEdit = true;
          enableDoubleClickToReply = true;
          requireModifier = false;
        };

        "NoF1" = {
          enable = true;
        };

        "NoOnboardingDelay" = {
          enable = true;
        };

        "Petpet" = {
          enable = true;
        };

        "ReverseImageSearch" = {
          enable = true;
        };

        "ShowHiddenThings" = {
          enable = true;
          showTimeouts = true;
          showInvitesPaused = true;
          showModView = true;
        };

        "ThemeAttributes" = {
          enable = true;
        };

        "Timezones" = {
          enable = true;
          "24h Time" = true;
          databaseUrl = "https://timezone.creations.works";
          preferDatabaseOverLocal = true;
          showMessageHeaderTime = true;
          showOwnTimezone = true;
          showProfileTime = true;
          showTimezoneInfo = true;
          useDatabase = true;
        };

        "Translate" = {
          enable = true;
          autoTranslate = false;
          service = "google";
          showAutoTranslateTooltip = true;
          target = "en";
        };

        "VoiceMessages" = {
          enable = true;
          echoCancellation = true;
          noiseSuppression = true;
        };

        "VolumeBooster" = {
          enable = true;
          multiplier = 2.0;
        };

        "WhosWatching" = {
          enable = true;
          showPanel = true;
        };

        "EquicordHelper" = {
          enable = true;
          disableDmContextMenu = false;
          noMirroredCamera = false;
          removeActivitySection = true;
        };

        "NoTrack" = {
          enable = true;
          disableAnalytics = true;
        };

        "Settings" = {
          enable = true;
          SettingsLocation = "top";
        };

        "SupportHelper" = {
          enable = true;
        };

      };
    };
  };
}
