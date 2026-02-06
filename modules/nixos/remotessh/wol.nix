{ config, lib, pkgs, ... }:

{
  # Enable Wake-on-LAN for remote wake-up
  environment.systemPackages = with pkgs; [
    ethtool
  ];

  # Systemd service to enable WOL on boot
  systemd.services.wol-enable = {
    description = "Enable Wake-on-LAN on network interface";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      # Enable WOL with magic packet (g flag) on enp13s0
      ExecStart = "${pkgs.ethtool}/bin/ethtool -s enp13s0 wol g";
      RemainAfterExit = true;
    };
  };
}
