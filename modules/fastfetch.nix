{ pkgs, ... }:

{
  xdg.configFile."fastfetch/config.jsonc".source = ./fastfetch/config.jsonc;
}
