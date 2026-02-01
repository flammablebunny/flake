{ pkgs, ... }:

{
  programs.foot = {
    enable = true;

    settings = {
      main = {
        shell = "fish";
        title = "foot";
        font = "JetBrains Mono Nerd Font:size=12";
        letter-spacing = 0;
        dpi-aware = "no";
        pad = "25x25";
        bold-text-in-bright = "no";
        gamma-correct-blending = "no";
      };

      scrollback = {
        lines = 10000;
      };

      cursor = {
        style = "beam";
        beam-thickness = "1.5";
      };

      colors = {
        alpha = "0.78";
        background = "131317";
        foreground = "e5e1e7";

        # Caelestia terminal colors (from colors.nix)
        regular0 = "353434";  # black
        regular1 = "ac73ff";  # red (purple-ish)
        regular2 = "44def5";  # green -> cyan (INFO)
        regular3 = "ffdcf2";  # yellow (pinkish - WARN)
        regular4 = "99aad8";  # blue
        regular5 = "b49fea";  # magenta/purple (hostname)
        regular6 = "9dceff";  # cyan
        regular7 = "e8d3de";  # white

        # Bright colors
        bright0 = "ac9fa9";
        bright1 = "c093ff";
        bright2 = "89ecff";
        bright3 = "fff0f6";
        bright4 = "b5c1dd";
        bright5 = "c9b5f4";
        bright6 = "bae0ff";
        bright7 = "ffffff";
      };

      key-bindings = {
        scrollback-up-page = "Page_Up";
        scrollback-down-page = "Page_Down";
        search-start = "Control+Shift+f";
      };

      search-bindings = {
        cancel = "Escape";
        find-prev = "Shift+F3";
        find-next = "F3 Control+G";
      };
    };
  };
}
