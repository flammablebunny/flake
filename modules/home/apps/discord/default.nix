{ inputs, pkgs, lib, ... }:

{
  imports = [
    inputs.nixcord.homeModules.nixcord
  ];

  programs.nixcord = {
    enable = true;

    discord = {
    enable = true;
    openASAR.enable = true;
    equicord.enable = true;
    vencord.enable = false;
    # Discord downloads OpenH264 from Cisco for H.264 decoding (Tenor MP4 "GIFs"),
    # but the downloaded .so lacks execute permission and RPATH on NixOS, so dlopen() fails.
    # Replace it at launch with the nix store version (has RUNPATH + correct perms).
    package = (pkgs.callPackage "${inputs.nixcord}/pkgs/discord.nix" {}).overrideAttrs (old: {
      postFixup = (old.postFixup or "") + ''
        wrapProgram $out/opt/Discord/Discord \
          --run '${pkgs.writeShellScript "fix-openh264" ''
            cache="$HOME/.config/discord/discord_asset_cache/openh264"
            if [ -d "$cache" ]; then
              rm -f "$cache"/*.so
              ln -sf ${pkgs.openh264}/lib/libopenh264.so "$cache/libopenh264-2.5.1-linux64.7.so"
            fi
          ''}'
      '';
    });
  };
    

    config = {
      autoUpdate = false;
      autoUpdateNotification = false;
      enableReactDevtools = false;
      frameless = false;
      notifyAboutUpdates = false;
      transparent = false;

      plugins = {

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

#        anammox = {
#          enable = true;
#          billing = true;
#          dms = true;
#          emojiList = true;
#          gift = true;
#          serverBoost = true;
#        };

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

#        betterQuickReact = {
#          enable = true;
#          columns = 4.0;
#          compactMode = false;
#          frequentEmojis = true;
#          rows = 2.0;
#          scroll = true;
#        };

        callTimer = {
          enable = true;
          format = "stopwatch";
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

       # fontLoader = {
       #   enable = true;
       #   applyOnCodeBlocks = false;
       #   fontSearch = {};
       # };

        forceOwnerCrown = {
          enable = true;
        };

        gifCollections = {
          enable = true;
        };

        gifPaste = {
          enable = true;
        };

#        gifRoulette = {
#          enable = true;
#          pingOwnerChance = true;
#        };

#        ignoreTerms = {
#          enable = true;
#        };

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

#        songLink = {
#          enable = true;
#          servicesComponent = {};
#          servicesSettings = {};
#          userCountry = "US";
#        };

        themeAttributes = {
          enable = true;
        };

#       timezones = {
#          enable = true;
#          _24hTime = false;
#          databaseUrl = "https://timezone.creations.works";
#          preferDatabaseOverLocal = true;
#          resetDatabaseTimezone = {};
#          setDatabaseTimezone = {};
#          showMessageHeaderTime = true;
#          showOwnTimezone = true;
#          showProfileTime = true;
#          showTimezoneInfo = true;
#          useDatabase = true;
#        };

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
          noMirroredCamera = false;
          removeActivitySection = false;
        };

#dragFavoriteEmotes = {
#enable = true;
#};

#messageClickActions = {
# enable = true;
#  backspaceClickAction = "delete";
#   doubleClickAction = "edit";
#   doubleClickOthersAction = "reply";
#    disableInDms = false;
#     disableInSystemDms = true;
#     clickTimeout = 300;
#    };
      };
    };
  };
}
