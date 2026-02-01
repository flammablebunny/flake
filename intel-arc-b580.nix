# Temporary Intel Arc B580 (Battlemage) GPU Configuration
# Remove this import from flake.nix when swapping back to your regular GPU

{ config, pkgs, lib, ... }:

{
  # Enable hardware graphics (replaces deprecated hardware.opengl)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      # Intel media driver for hardware video acceleration (VA-API)
      intel-media-driver

      # VAAPI support
      libvdpau-va-gl
      libva-vdpau-driver

      # Vulkan support for Intel Arc
      intel-compute-runtime
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver
    ];
  };

  # Environment variables for Intel Arc GPU
  environment.sessionVariables = {
    # Force Intel media driver
    LIBVA_DRIVER_NAME = "iHD";

    # Vulkan ICD loader - use Intel
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/intel_icd.i686.json";

    # For Wayland/Hyprland - use Vulkan renderer
    WLR_RENDERER = "vulkan";
  };

  # Install useful GPU tools
  environment.systemPackages = with pkgs; [
    # GPU monitoring and info
    intel-gpu-tools
    nvtopPackages.intel

    # VA-API tools for testing hardware acceleration
    libva-utils

    # Vulkan tools
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
  ];

  # Ensure kernel has proper Intel GPU support
  boot.initrd.kernelModules = [ "i915" ];

  # Kernel parameters for Intel Arc
  boot.kernelParams = [
    # Enable GuC/HuC firmware loading for Intel Arc
    "i915.enable_guc=3"
    # Force probe for new Intel GPUs (may help with Battlemage)
    "i915.force_probe=*"
  ];
}
