{ config, lib, pkgs, inputs, userName, ... }:

let
  # Patches fetched from GitHub
  patchRepo = "https://raw.githubusercontent.com/flammablebunny/waywall-vulkan-chat/main/patches";
in
{
  imports = [
    ../../modules/nixos/hardware/intel-arc.nix
    ../../modules/nixos/remotessh
  ];

  # Intel Mesa (iris) linear dmabuf stride padding for cross-GPU P2P (PC only)
  nixpkgs.overlays = [
    (final: prev: {
      mesa = prev.mesa.overrideAttrs (old: {
        patches = (old.patches or []) ++ [
          (pkgs.fetchpatch {
            url = "${patchRepo}/mesa-iris-linear-stride-256.patch";
            hash = "sha256-A0hWyO67AlF6eDyohIv+HFqTfWGI0Phq6W3VWb4gEO4=";
          })
        ];
      });
    })
  ];

  # Passwordless Sudo For (PC only for security)
  security.sudo.extraRules = [
    {
      users = [ userName ];
      commands = [ { command = "ALL"; options = [ "NOPASSWD" ]; } ];
    }
  ];

  # Dual GPU Kernel Params
  boot.kernelParams = [
    "amdgpu.sg_display=0"
    "amdgpu.ppfeaturemask=0xffffffff"  # Enable AMD GPU overclocking
    "i915.enable_guc=3"
    "xe.vram_bar_size=0"
    "xe.dmabuf_pin_vram=1"
    "loglevel=3"
    "xe.enable_flipq=1"
  ];

  boot.kernelPatches = [
    {
      name = "xe-p2p-no-wait-gpu";
      patch = pkgs.fetchpatch {
        url = "${patchRepo}/xe-p2p-no-wait-gpu-6.18.7.patch";
        hash = "sha256-bpcJdiK95NujTYeByQWORCPnNaghljw2fAXq4/JJL60=";
      };
    }
    {
      name = "xe-dmabuf-pin-vram";
      patch = pkgs.fetchpatch {
        url = "${patchRepo}/xe-dmabuf-pin-vram-6.18.7.patch";
        hash = "sha256-dJyQkhe0gsGWBnkA3JJcWRJFleoqVPGJ6Hhe3xNU9G8=";
      };
    }
    {
      name = "amdgpu-allow-p2p-scanout";
      patch = pkgs.fetchpatch {
        url = "${patchRepo}/amdgpu-allow-p2p-scanout-6.18.7.patch";
        hash = "sha256-gWUEAJht6SbnbXkM5xXoAnDm2UGg5GS0/xJwX3Xv0uI=";
      };
    }
  ];

  environment.sessionVariables.HYPRLAND_TRACE_FENCE_WAIT = "1";

  # Duplicate Audio Params to Enable Pulse on PC 
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Auto Mount OBS Drive
  fileSystems."/mnt/OBS" = {
    device = "/dev/disk/by-uuid/d561203b-5da5-436a-ae47-732bd2310955";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

   # Wooting Keyboard
  hardware.wooting.enable = true;

  # OpenRGB for RGB Control
  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
    motherboard = "amd";
  };

  networking.firewall.allowedUDPPorts = [ 6767 ];

  # I2C for better RGB device detection
  hardware.i2c.enable = true;

  # PC Specific Apps
  environment.systemPackages = with pkgs; [
    wootility
  ];
  
  systemd.services.lactd = {
    description = "AMDGPU Control Daemon";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.lact}/bin/lact daemon";
      Restart = "always";
    };
  };

  # Tmpfs for practice maps)
  fileSystems."/home/bunny/mcsr/tmpfs" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "size=4G" "mode=0755" "uid=bunny" "gid=users" ];
  };

  systemd.tmpfiles.rules = [
    "d /home/bunny/mcsr/tmpfs/ranked 0755 bunny users -"
    "d /home/bunny/mcsr/tmpfs/SeedQueue 0755 bunny users -"
    "d /home/bunny/mcsr/tmpfs/RPS 0755 bunny users -"
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
        mkdir -p /home/bunny/mcsr/tmpfs/SeedQueue
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
        # Cleanup for ranked and SeedQueue minecraft saves
        while true; do
          if [ -d /home/bunny/mcsr/tmpfs/ranked ]; then
            cd /home/bunny/mcsr/tmpfs/ranked
            ls -t1 --ignore='Z*' 2>/dev/null | tail -n +7 | while read save; do
              rm -rf "/home/bunny/mcsr/tmpfs/ranked/$save"
            done
          fi
          if [ -d /home/bunny/mcsr/tmpfs/SeedQueue ]; then
            cd /home/bunny/mcsr/tmpfs/SeedQueue
            ls -t1 --ignore='Z*' 2>/dev/null | tail -n +7 | while read save; do
              rm -rf "/home/bunny/mcsr/tmpfs/SeedQueue/$save"
            done
          fi
          if [ -d /home/bunny/mcsr/tmpfs/RPS ]; then
            cd /home/bunny/mcsr/tmpfs/RPS
            ls -t1 --ignore='Z*' 2>/dev/null | tail -n +7 | while read save; do
              rm -rf "/home/bunny/mcsr/tmpfs/RPS/$save"
            done
          fi
          sleep 300
        done
      '';
    };
  };
}
