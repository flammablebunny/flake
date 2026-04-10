{ config, lib, pkgs, inputs, userName, ... }:

{
  # Laptop NixOS config


  boot.kernelPatches = [{
    name = "ucsi-timeout-increase";
    patch = ../../patches/ucsi-timeout.patch;
  }];

  boot.kernelParams = [
    "mem_sleep_default=s2idle"          # hardware only supports S0ix, not S3 deep
    "amdgpu.ppfeaturemask=0xffff7fff"   # all features + overdrive, minus GFXOFF (bit 15) to fix page-flip race
    "amdgpu.runpm=0"                    # disable runtime PM - prevents dGPU PCIe bus loss on resume
    "amdgpu.gpu_recovery=1"             # enable GPU reset on hang
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
  environment.systemPackages = with pkgs; let
    btop-gpu = btop.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ makeWrapper ];
      postFixup = (old.postFixup or "") + ''
        wrapProgram $out/bin/btop \
          --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
            rocmPackages.rocm-smi
            rocmPackages.amdsmi
          ]}
      '';
    });
  in [
    btop-gpu
    slack
    chromium
    moonlight-qt
    wakeonlan
    openssh
  ];

  # Open WebUI access from local network
  networking.firewall.allowedTCPPorts = [ 8080 ];

  # Ollama (local LLM inference on 7900 XTX via ROCm)
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    environmentVariables = {
      ROCR_VISIBLE_DEVICES = "1";
    };
  };
}
