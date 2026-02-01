{ inputs, pkgs, config, ... }:

{
  imports = [
    ../../modules/home/gaming
  ];

  xdg.configFile."caelestia/shell.json".source = ../../assets/shell-pc.json;
}
