{
  description = "Bunny's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/d03c4f8db69c22c9603da69a8df445f78c69a522";  # Feb 4 - before mesa 26 broke

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixcord = {
      url = "github:kaylorben/nixcord";
    };

    nixcraft = {
      url = "github:flammablebunny/nixcraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Custom Hyprland fork for PC (cross-GPU P2P support)
    hyprland-custom = {
      url = "github:flammablebunny/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.aquamarine.url = "github:flammablebunny/aquamarine";
    };

    # Standard Hyprland for laptop
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mcsr-nixos = {
      url = "git+https://git.uku3lig.net/uku/mcsr-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ninjabrain-bot-nix = {
      url = "https://tangled.org/althaea.zone/ninjabrain-bot-nix/archive/trunk";
      inputs.mcsr-nixos.follows = "mcsr-nixos";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";

    # Read laptop username from local file (because my laptop name is my real name)
    laptopUserFile = /etc/nixos/username.txt;
    laptopUser = if builtins.pathExists laptopUserFile
      then builtins.replaceStrings ["\n"] [""] (builtins.readFile laptopUserFile)
      else "nixos"; 

    mkHost = { hostDir, userName, useCustomHyprland ? false }: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit userName inputs; };
      modules = [
        ./hosts/common/default.nix
        ./hosts/${hostDir}/default.nix
        ./hosts/${hostDir}/hardware-configuration.nix
        # Use custom Hyprland fork for PC, standard for laptop
        (if useCustomHyprland
          then inputs.hyprland-custom.nixosModules.default
          else inputs.hyprland.nixosModules.default)
        inputs.agenix.nixosModules.default
        inputs.impermanence.nixosModules.impermanence
        home-manager.nixosModules.home-manager
        {
          networking.hostName = "iusenixbtw";

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = { inherit userName inputs; };
            users.${userName} = { ... }: {
              imports = [
                ./hosts/common/home.nix
                ./hosts/${hostDir}/home.nix
              ];
            };
          };
        }
      ];
    };
  in {
    nixosConfigurations = {
      pc = mkHost { hostDir = "pc"; userName = "bunny"; useCustomHyprland = true; };
      laptop = mkHost { hostDir = "laptop"; userName = laptopUser; useCustomHyprland = false; };
      iusenixbtw = mkHost { hostDir = "pc"; userName = "bunny"; useCustomHyprland = true; };
    };
  };
}
