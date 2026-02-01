{ inputs, pkgs, config, userName, ... }:

{
  xdg.configFile."caelestia/shell.json".source = ../../assets/shell-laptop.json;
}
