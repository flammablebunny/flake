{ inputs, pkgs, lib, config, ... }:

let
  # Firefox addons from the flake
  addons = inputs.firefox-addons.packages.${pkgs.system};

  # Wrapper that forces Zen to use the HM-managed profile directory,
  # bypassing the install-hash profile selection that creates stale
  # "Default (release)" profiles on every package rebuild.
  zenLauncher = pkgs.writeShellScriptBin "zen-launch" ''
    exec zen-beta --profile "$HOME/.zen/vt6h1pep.Default Profile" "$@"
  '';
in
{
  home.packages = [ zenLauncher ];

  xdg.desktopEntries."zen-beta" = {
    name = "Zen Browser (Beta)";
    genericName = "Web Browser";
    exec = "zen-launch --name zen-beta %U";
    icon = "zen-browser";
    terminal = false;
    categories = [ "Network" "WebBrowser" ];
    mimeType = [
      "text/html"
      "text/xml"
      "application/xhtml+xml"
      "application/vnd.mozilla.xul+xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
    startupNotify = true;
    settings = {
      StartupWMClass = "zen-beta";
    };
    actions = {
      "new-private-window" = {
        name = "New Private Window";
        exec = "zen-launch --private-window %U";
      };
      "new-window" = {
        name = "New Window";
        exec = "zen-launch --new-window %U";
      };
      "profile-manager-window" = {
        name = "Profile Manager";
        exec = "zen-beta --ProfileManager";
      };
    };
  };

  programs.firefox = {
    enable = true;
    package = inputs.zen-browser.packages.${pkgs.system}.default;

    # Policies applied to the browser
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFirefoxAccounts = false; # Firefox Sync
      DisableSetDesktopBackground = true;
      DisplayBookmarksToolbar = "newtab";

      # Don't override homepage since we want session restore
      # Homepage = { StartPage = "previous-session"; };
    };

    profiles.default = {
      isDefault = true;
      name = "Default Profile";

      # Extensions (declaratively managed)
      extensions.packages = with addons; [
        ublock-origin
        clearurls
        consent-o-matic
        darkreader
        privacy-badger
      ];

      # Browser settings
      settings = {
        # ===================
        # STARTUP & SESSION
        # ===================
        "browser.startup.page" = 3; # Resume previous session
        "browser.sessionstore.resume_session_once" = false;
        "browser.sessionstore.resume_from_crash" = true;
        "browser.sessionstore.max_tabs_undo" = 50;
        "browser.sessionstore.max_windows_undo" = 5;

        # ===================
        # TABS
        # ===================
        "browser.tabs.closeWindowWithLastTab" = false;
        "browser.ctrlTab.sortByRecentlyUsed" = false; # Ctrl+Tab in tab order
        "privacy.userContext.enabled" = true; # Enable containers
        "privacy.userContext.ui.enabled" = true;

        # ===================
        # DOWNLOADS
        # ===================
        "browser.download.useDownloadDir" = true; # Save to default location
        "browser.download.folderList" = 1; # 1 = Downloads folder
        "browser.download.always_ask_before_handling_new_types" = false;

        # ===================
        # BROWSING & DRM
        # ===================
        "general.smoothScroll" = true;
        "media.eme.enabled" = true; # DRM content
        "media.videocontrols.picture-in-picture.enabled" = true;
        "media.videocontrols.picture-in-picture.video-toggle.enabled" = true;

        # ===================
        # SEARCH
        # ===================
        "browser.search.suggest.enabled" = false; # No search suggestions
        "browser.urlbar.suggest.searches" = false;
        "browser.urlbar.suggest.history" = true;
        "browser.urlbar.suggest.bookmark" = true;
        "browser.urlbar.suggest.openpage" = true;
        "browser.urlbar.suggest.topsites" = false;
        "browser.urlbar.shortcuts.bookmarks" = true;
        "browser.urlbar.shortcuts.history" = true;
        "browser.urlbar.shortcuts.tabs" = true;

        # ===================
        # PRIVACY & TRACKING
        # ===================
        "privacy.donottrackheader.enabled" = true;
        "privacy.globalprivacycontrol.enabled" = true; # GPC
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.trackingprotection.cryptomining.enabled" = true;
        "privacy.trackingprotection.fingerprinting.enabled" = true;
        "network.cookie.cookieBehavior" = 5; # Standard protection

        # ===================
        # PASSWORDS & AUTOFILL (Disabled)
        # ===================
        "signon.rememberSignons" = false;
        "signon.autofillForms" = false;
        "signon.generation.enabled" = false;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;

        # ===================
        # HISTORY
        # ===================
        "places.history.enabled" = true;
        "browser.formfill.enable" = false; # Don't remember form history

        # ===================
        # SECURITY
        # ===================
        "browser.safebrowsing.malware.enabled" = true;
        "browser.safebrowsing.phishing.enabled" = true;
        "browser.safebrowsing.downloads.enabled" = true;
        "browser.safebrowsing.downloads.remote.block_potentially_unwanted" = true;
        "browser.safebrowsing.downloads.remote.block_uncommon" = true;

        # ===================
        # DNS OVER HTTPS (Cloudflare)
        # ===================
        "network.trr.mode" = 2; # Enable DoH
        "network.trr.uri" = "https://mozilla.cloudflare-dns.com/dns-query";

        # ===================
        # FIREFOX SYNC
        # ===================
        "identity.fxaccounts.enabled" = true;
        "services.sync.engine.tabs" = true;
        "services.sync.engine.bookmarks" = true;
        "services.sync.engine.history" = true;
        "services.sync.engine.prefs" = true;
        "services.sync.engine.addons" = true;

        # ===================
        # TELEMETRY (Disabled)
        # ===================
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.ping-centre.telemetry" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.archive.enabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;

        # ===================
        # PERFORMANCE
        # ===================
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true; # Hardware video decode
        "layers.acceleration.force-enabled" = true;

        # ===================
        # UI
        # ===================
        "browser.toolbars.bookmarks.visibility" = "newtab";
      };

      # Search engines
      search = {
        force = true;
        default = "ddg";
        engines = {
          "Nix Packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                { name = "type"; value = "packages"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
          "NixOS Options" = {
            urls = [{
              template = "https://search.nixos.org/options";
              params = [
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };
          "Home Manager Options" = {
            urls = [{
              template = "https://home-manager-options.extranix.com/";
              params = [
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            definedAliases = [ "@hm" ];
          };
          "GitHub" = {
            urls = [{
              template = "https://github.com/search";
              params = [
                { name = "q"; value = "{searchTerms}"; }
              ];
            }];
            definedAliases = [ "@gh" ];
          };
        };
      };
    };
  };
}
