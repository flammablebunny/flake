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
      # Enable WOL with magic packet (g flag) on the ethernet interface
      # enp13s0 with 7900XTX, enp11s0 without (PCIe renumbering)
      ExecStart = "${pkgs.ethtool}/bin/ethtool -s enp11s0 wol g";
      RemainAfterExit = true;
    };
  };
}
