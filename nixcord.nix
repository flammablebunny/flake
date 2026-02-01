{ inputs, pkgs, ... }:

{
  imports = [ 
    inputs.nixcord.homeManagerModules.nixcord 
  ];

  programs.nixcord = {
    enable = true;

    discord = {
      enable = true;
      
      openasar.enable = true;
      equicord.enable = true;
      vencord.enable = false;
    };

    config = {
      # themeLinks = [ "url_to_theme.css" ];
    };
  };
}
