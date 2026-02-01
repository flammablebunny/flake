{ config, pkgs, lib, ... }:

{
  # Enable hardware graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      # Intel media driver for hardware video acceleration (VA-API)
      intel-media-driver
      # VAAPI support
      libvdpau-va-gl
      # Vulkan support for Intel Arc
      intel-compute-runtime
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver
    ];
  };

  # Make sure every render node is available to the user.
  services.udev.extraRules = ''
    KERNEL=="dri/card*", GROUP="video"
    KERNEL=="dri/renderD*", GROUP="video"
  '';

  # Environment variables for Multi-GPU setup
  environment.variables = {
    # Set Intel for VA-API encoding
    LIBVA_DRIVER_NAME = "iHD";

    # Tell Aquamarine/Hyprland to use both GPUs, with AMD as primary
    # Using ';' delimiter (patched Aquamarine) because PCI paths contain ':'
    AQ_DRM_DEVICES = "/dev/dri/by-path/pci-0000:03:00.0-card;/dev/dri/by-path/pci-0000:09:00.0-card";
    
    # Let Hyprland auto-select the renderer, which should be the default OpenGL
    # WLR_RENDERER = "vulkan";

    # Misc
    __GL_SYNC_TO_VBLANK = "0";
    __GLX_VENDOR_LIBRARY_NAME = "mesa";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    NVD_BACKEND = "direct";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  # Kernel parameters for both GPUs
  boot.kernelParams = [
    # For AMD GPU
    "amdgpu.sg_display=0"
    # For Intel Arc
    "i915.enable_guc=3"
  ];
}
