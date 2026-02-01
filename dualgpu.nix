# Configuration Settings for Dual Dedicated GPU (Intel B580 + 7900xtx) Setup.

{ config, pkgs, lib, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      intel-media-driver
      libvdpau-va-gl
      intel-compute-runtime
      vpl-gpu-rt
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver
    ];
  };

  services.udev.extraRules = ''
    KERNEL=="dri/card*", GROUP="video"
    KERNEL=="dri/renderD*", GROUP="video"
  '';

  boot.kernelParams = [
    "amdgpu.sg_display=0"
    "i915.enable_guc=3"
    "xe.vram_bar_size=0"
  ];

  environment.variables = {
    LIBVA_DRIVER_NAME = "iHD";

    AQ_DRM_DEVICES = "/dev/dri/by-path/pci-0000:03:00.0-card;/dev/dri/by-path/pci-0000:09:00.0-card";
    
    __GL_SYNC_TO_VBLANK = "0";
    __GLX_VENDOR_LIBRARY_NAME = "mesa";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    NVD_BACKEND = "direct";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

}
