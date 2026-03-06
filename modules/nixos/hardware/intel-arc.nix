# Intel Arc B580 GPU configuration
# This module is PC-specific and uses hardware detection

{ config, pkgs, lib, ... }:

let
  # Hardware detection - checks for Intel GPU at eval time
  hasIntelGPU = builtins.pathExists "/sys/class/drm/card1";
in
{
  config = lib.mkIf hasIntelGPU {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = with pkgs; [
        # Intel
        intel-media-driver
        libvdpau-va-gl
        intel-compute-runtime
        vpl-gpu-rt
        # AMD (ROCm OpenCL for DaVinci Resolve) 
        # Im putting this here because you only need
        # these when you also have an intel gpu
        rocmPackages.clr
        rocmPackages.clr.icd
      ];

      extraPackages32 = with pkgs.pkgsi686Linux; [
        intel-media-driver
      ];
    };

    services.udev.extraRules = ''
      KERNEL=="dri/card*", GROUP="video"
      KERNEL=="dri/renderD*", GROUP="video"
    '';
      
    boot.kernelModules = [ "xe" ];

    boot.kernelParams = [
      "amdgpu.sg_display=0"
      "i915.enable_guc=3"
      "xe.vram_bar_size=0"
    ];

    environment.variables = {
      HSA_OVERRIDE_GFX_VERSION = "11.0.0";
      LIBVA_DRIVER_NAME = "iHD";
      # AQ_DRM_DEVICES = "/dev/dri/card2;/dev/dri/card1";  # re-enable with 7900XTX
      # AQ_SECONDARY_NO_RENDERER = "1";  # re-enable with 7900XTX
      __GL_SYNC_TO_VBLANK = "0";
      __GLX_VENDOR_LIBRARY_NAME = "mesa";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      NVD_BACKEND = "direct";
      WLR_NO_HARDWARE_CURSORS = "1";
    };
  };
}
