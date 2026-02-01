{ config, lib, pkgs, inputs, userName, ... }:

{
  # Laptop NixOS config
  

  # PipeWire
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };



}
