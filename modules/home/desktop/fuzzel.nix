{ pkgs, ... }:

{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "foot";
        layer = "overlay";
        prompt = "❯ ";
        icon-theme = "Papirus-Dark";
        font = "JetBrainsMono Nerd Font:size=12";
        dpi-aware = "no";
        width = 35;
        lines = 10;
        horizontal-pad = 20;
        vertical-pad = 15;
        inner-pad = 5;
      };
      colors = {
        background = "1e1e2edd";
        text = "cdd6f4ff";
        selection = "45475add";
        selection-text = "cdd6f4ff";
        border = "b4befeff";
        match = "f38ba8ff";
      };
      border = {
        width = 2;
        radius = 15;
      };
    };
  };
}
