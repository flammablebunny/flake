{ config, lib, pkgs, inputs, userName, ... }:

{
  # Laptop NixOS config


  boot.kernelParams = [
    "mem_sleep_default=deep"
    "amdgpu.ppfeaturemask=0xfffd7fff"  # overclocking without experimental bits that cause crashes
    "amdgpu.gfxoff=0"                  # disable GFX power gating (fixes page-flip race)
    "amdgpu.gpu_recovery=1"            # enable GPU reset on hang
    "pcie_aspm=off"                    # prevent Thunderbolt link downtraining
  ];

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
    moonlight-qt  
    wakeonlan 
  ];




}
