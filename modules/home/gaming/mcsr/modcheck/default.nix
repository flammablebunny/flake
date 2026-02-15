{ inputs, pkgs, ... }:

{
  # Install modcheck from mcsr-nixos
  home.packages = [
    inputs.mcsr-nixos.packages.${pkgs.system}.modcheck
  ];
}
