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
      
      enabledThemes = [ "Caelestia" ];
      themes = {
        "Caelestia" = builtins.readFile ./themes/caelestia/caelestia.theme.css;
      };

      plugins = {
        allCallTimers = {
          enable = true;
          format = "stopwatch";
          showRoleColor = true;
          showSeconds = true;
          showWithoutHover = true;
          trackSelf = true;
          watchLargeGuilds = false;
        };

        alwaysAnimate = {
          enable = true;
          icons = true;
          nameplates = true;
          roleGradients = true;
          serverBanners = true;
          statusEmojis = true;
        };

        alwaysExpandProfiles = {
          enable = true;
        };

        anammox = {
          enable = true;
          billing = true;
          dms = true;
          emojiList = true;
          gift = true;
          serverBoost = true;
        };

        betterActivities = {
          enable = true;
        };

        betterBlockedUsers = {
          enable = true;
        };

        betterFolders = {
          enable = true;
          closeAllFolders = false;
          closeAllHomeButton = false;
          closeOthers = false;
          closeServerFolder = false;
          forceOpen = false;
          keepIcons = false;
          showFolderIcon = 1;
          sidebar = true;
          sidebarAnim = true;
        };

        betterGifPicker = {
          enable = true;
        };

        betterQuickReact = {
          enable = true;
          columns = 4.0;
          compactMode = false;
          frequentEmojis = true;
          rows = 2.0;
          scroll = true;
        };

        blurNsfw = {
          enable = true;
          blurAllChannels = false;
          blurAmount = 10;
        };

        callTimer = {
          enable = true;
          format = "stopwatch";
        };

        clearUrLs = {
          enable = true;
        };

        copyFileContents = {
          enable = true;
        };

        crashHandler = {
          enable = true;
          attemptToNavigateToHome = false;
          attemptToPreventCrashes = true;
        };

        disableCallIdle = {
          enable = true;
        };

        expressionCloner = {
          enable = true;
        };

        favoriteGifSearch = {
          enable = true;
          searchOption = "hostandpath";
        };

        fixImagesQuality = {
          enable = true;
        };

        fixSpotifyEmbeds = {
          enable = true;
          volume = 10.0;
        };

        fixYoutubeEmbeds = {
          enable = true;
        };

        fontLoader = {
          enable = true;
          applyOnCodeBlocks = false;
          fontSearch = {};
        };

        forceOwnerCrown = {
          enable = true;
        };

        gifPaste = {
          enable = true;
        };

        gifRoulette = {
          enable = true;
          pingOwnerChance = true;
        };

        ignoreTerms = {
          enable = true;
        };

        imageZoom = {
          enable = true;
          invertScroll = true;
          nearestNeighbour = false;
          saveZoomValues = true;
          size = 100.0;
          square = false;
          zoom = 2.0;
          zoomSpeed = 0.5;
        };

        keyboardNavigation = {
          enable = false;
          allowMouseControl = true;
          hotkey = [];
        };

        memberCount = {
          enable = true;
          memberList = true;
          toolTip = true;
          voiceActivity = true;
        };

        messageClickActions = {
          enable = true;
          enableDeleteOnClick = true;
          enableDoubleClickToEdit = true;
          enableDoubleClickToReply = true;
          requireModifier = false;
        };

        noF1 = {
          enable = true;
        };

        noOnboardingDelay = {
          enable = true;
        };

        petpet = {
          enable = true;
        };

        reverseImageSearch = {
          enable = true;
        };

        showHiddenThings = {
          enable = true;
        };

        songLink = {
          enable = true;
          servicesComponent = {};
          servicesSettings = {};
          userCountry = "US";
        };

        themeAttributes = {
          enable = true;
        };

        timezones = {
          enable = true;
          _24hTime = false;
          databaseUrl = "https://timezone.creations.works";
          preferDatabaseOverLocal = true;
          resetDatabaseTimezone = {};
          setDatabaseTimezone = {};
          showMessageHeaderTime = true;
          showOwnTimezone = true;
          showProfileTime = true;
          showTimezoneInfo = true;
          useDatabase = true;
        };

        translate = {
          enable = true;
          autoTranslate = false;
          deeplApiKey = "";
          service = "google";
          shavian = true;
          showAutoTranslateTooltip = true;
          sitelen = true;
          target = "en";
          toki = true;
        };

        voiceMessages = {
          enable = true;
          echoCancellation = true;
          noiseSuppression = true;
        };

        volumeBooster = {
          enable = true;
          multiplier = 2.0;
        };

        whosWatching = {
          enable = true;
          showPanel = true;
        };

        equicordHelper = {
          enable = true;
          disableDmContextMenu = false;
          noMirroredCamera = false;
          removeActivitySection = false;
        };
      };
    };
  };
}
