{ config, lib, pkgs, inputs, userName, ... }:

{
  # Laptop NixOS config


  boot.kernelPatches = [{
    name = "ucsi-timeout-increase";
    patch = ../../patches/ucsi-timeout.patch;
  }];

  boot.kernelParams = [
    "mem_sleep_default=deep"
    "amdgpu.ppfeaturemask=0xffffffff"  # enable all power features including overdrive
    "amdgpu.gfxoff=0"                  # disable GFX power gating (fixes page-flip race)
    "amdgpu.gpu_recovery=1"            # enable GPU reset on hang
  ];

  hardware.cpu.amd.updateMicrocode = true;

  # Blacklist ucsi_acpi at boot - AMD EC isn't ready in time, causing
  # UCSI PPM init timeout and broken USB-PD negotiation (5-15W instead of 65W)
  boot.blacklistedKernelModules = [ "ucsi_acpi" ];

  systemd.services.ucsi-acpi-reload = {
    description = "Deferred load of ucsi_acpi for USB-PD charging";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 45";
      ExecStart = "${pkgs.kmod}/bin/modprobe ucsi_acpi";
      RemainAfterExit = true;
    };
  };

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
    openssh
  ];




}
