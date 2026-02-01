{
  description = "Bunny's Caelestia NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "quickshell";
    };

    caelestia-cli = {
      url = "github:caelestia-dots/cli";
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

    hyprland = {
      url = "github:flammablebunny/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
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

    mkHost = { hostDir, userName }: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit userName inputs; };
      modules = [
        ./hosts/common/default.nix
        ./hosts/${hostDir}/default.nix
        ./hosts/${hostDir}/hardware-configuration.nix
        inputs.hyprland.nixosModules.default
        inputs.agenix.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          networking.hostName = "iusenixbtw";

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
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
      pc = mkHost { hostDir = "pc"; userName = "bunny"; };
      laptop = mkHost { hostDir = "laptop"; userName = laptopUser; };
      iusenixbtw = mkHost { hostDir = "pc"; userName = "bunny"; };
    };
  };
}
