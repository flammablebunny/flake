{ inputs, pkgs, ... }:

{
  imports = [ 
    inputs.nixcord.homeModules.nixcord 
  ];

  programs.nixcord = {
    enable = true;

    discord = {
      enable = true;
      
      package = pkgs.discord.override { withOpenASAR = true; };

      equicord.enable = true;
      vencord.enable = false;
    };

    config = {
      # themeLinks = [ "url_to_theme.css" ];
    };
  };
}
