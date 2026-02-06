{ config, lib, pkgs, inputs, userName, ... }:

{
  # Laptop NixOS config


  boot.kernelParams = [ "mem_sleep_default=deep" ];

  hardware.cpu.amd.updateMicrocode = true;


  # PipeWire
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

   # Laptop Specific Apps
  environment.systemPackages = with pkgs; [
    slack
    chromium
    moonlight-qt  # Remote desktop client for Sunshine
    wakeonlan     # Wake-on-LAN utility
  ];




}
