{ config, lib, pkgs, ... }:

{
  # Sunshine game streaming server for remote desktop
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;  # Required for proper input capture
  };

  # Firewall rules for Sunshine
  networking.firewall = {
    allowedTCPPorts = [
      47984  # HTTPS Web UI
      47989  # HTTP Web UI
      47990  # RTSP
      48010  # Control
    ];
    allowedUDPPorts = [
      47998  # Video
      47999  # Control
      48000  # Audio
      48010  # Control
    ];
  };

  # System packages
  environment.systemPackages = with pkgs; [
    sunshine
  ];

  # Enable uinput for virtual input devices (required for mouse/keyboard control)
  boot.kernelModules = [ "uinput" ];

  # Udev rule for uinput permissions
  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
  '';
}
