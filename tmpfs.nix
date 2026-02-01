{ config, pkgs, ... }:

{
  fileSystems."/home/bunny/mcsr/tmpfs" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "size=4G" "mode=0755" "uid=bunny" "gid=users" ];
  };

  systemd.tmpfiles.rules = [
    "d /home/bunny/mcsr/tmpfs/ranked 0755 bunny users -"
  ];

  systemd.services.mc-tmpfs-setup = {
    description = "Minecraft tmpfs practice map symlinks";
    wantedBy = [ "multi-user.target" ];
    after = [ "home-bunny-mcsr-tmpfs.mount" ];
    serviceConfig = {
      Type = "oneshot";
      User = "bunny";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "mc-setup" ''
        mkdir -p /home/bunny/mcsr/tmpfs/ranked
        ln -sf "/home/bunny/mcsr/practice-maps/Z_Blaze Practice" /home/bunny/mcsr/tmpfs/ranked/
        ln -sf "/home/bunny/mcsr/practice-maps/Z_BT Practice v1.3" /home/bunny/mcsr/tmpfs/ranked/
        ln -sf "/home/bunny/mcsr/practice-maps/Z_Crafting Practice v2" /home/bunny/mcsr/tmpfs/ranked/
        ln -sf "/home/bunny/mcsr/practice-maps/Z_LBP 3.14.0" /home/bunny/mcsr/tmpfs/ranked/
        ln -sf "/home/bunny/mcsr/practice-maps/Z_OW Practice V2" /home/bunny/mcsr/tmpfs/ranked/
        ln -sf "/home/bunny/mcsr/practice-maps/Z_Portal Practice v2" /home/bunny/mcsr/tmpfs/ranked/
        ln -sf "/home/bunny/mcsr/practice-maps/Z_Zero Practice v1.2.1" /home/bunny/mcsr/tmpfs/ranked/
        ln -sf "/home/bunny/mcsr/practice-maps/Z_Lama's Practice Map" /home/bunny/mcsr/tmpfs/ranked/
      '';
    };
  };

  systemd.services.mc-tmpfs-cleanup = {
    description = "Minecraft tmpfs cleanup";
    wantedBy = [ "multi-user.target" ];
    after = [ "home-bunny-mcsr-tmpfs.mount" "mc-tmpfs-setup.service" ];
    serviceConfig = {
      Type = "simple";
      User = "bunny";
      Restart = "always";
      ExecStart = pkgs.writeShellScript "mc-cleanup" ''
        while true; do
          if [ -d /home/bunny/mcsr/tmpfs/ranked ]; then
            cd /home/bunny/mcsr/tmpfs/ranked
            ls -t1 --ignore='Z*' 2>/dev/null | tail -n +6 | while read save; do
              rm -rf "/home/bunny/mcsr/tmpfs/ranked/$save"
            done
          fi
          sleep 300
        done
      '';
    };
  };
}
