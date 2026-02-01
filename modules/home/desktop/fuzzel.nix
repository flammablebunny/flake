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
        font = "JetBrainsMono Nerd Font:size=14";
        width = 80;
        lines = 12;
      };
      colors = {
        background = "1e1e2edd";
        text = "cdd6f4ff";
        selection = "45475add";
        selection-text = "cdd6f4ff";
        border = "89b4faff";
        match = "f38ba8ff";
      };
      border = {
        width = 2;
        radius = 15;
      };
    };
  };
}
