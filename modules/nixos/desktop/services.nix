{ config, lib, pkgs, ... }:

{
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.udisks2.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.geoclue2.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  systemd.services.set-performance-profile = {
    description = "Set power profile to performance";
    wantedBy = [ "multi-user.target" ];
    after = [ "power-profiles-daemon.service" ];
    requires = [ "power-profiles-daemon.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance";
      RemainAfterExit = true;
    };
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
