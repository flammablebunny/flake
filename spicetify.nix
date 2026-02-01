{ inputs, pkgs, ... }:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in

{
  imports = [ 
    inputs.spicetify-nix.homeManagerModules.default
  ];

   programs.spicetify = {
    enable = true;

    theme = {
      name = "caelestia";
      src = ./themes/caelestia; 
      
      appendName = true;
      injectCss = true;
      replaceColors = true;
      overwriteAssets = true;
      sidebarConfig = true;
    };

    colorScheme = "caelestia";

    enabledExtensions = with spicePkgs.extensions; [
      beautifulLyrics
      shuffle
    ];
    
    enabledCustomApps = with spicePkgs.apps; [
      marketplace
    ];
  };
}
