{ pkgs, config, ... }:

{
  home.pointerCursor = {
    name = "catppuccin-frappe-dark-cursors";
    package = pkgs.catppuccin-cursors.frappeDark;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
  };
}
