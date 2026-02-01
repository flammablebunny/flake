{ inputs, pkgs, ... }:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in
{
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];

  home.username = "bunny";
  home.homeDirectory = "/home/bunny";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  # Spicetify configuration
  programs.spicetify = {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      beautifulLyrics
      SmoothScrolling
      shuffle
    ];
    enabledCustomApps = with spicePkgs.apps; [
      marketplace
    ];
  };
}

