{ config, lib, pkgs, inputs, userName, ... }:

{
  # Laptop-specific NixOS config
  # TODO: Generate hardware-configuration.nix on laptop with nixos-generate-config

  # PipeWire
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Laptop-specific: Battery management, power saving
  # TODO: Add laptop-specific hardware config
}
