{ config, lib, pkgs, userName, ... }:

let
  cfg = config.custom.persistence;
in
{
  options.custom.persistence = {
    enable = lib.mkEnableOption "Impermanence - ephemeral root filesystem";

    persistPath = lib.mkOption {
      type = lib.types.str;
      default = "/persist";
      description = "Path to the persistent storage partition";
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure persist mount point exists
    systemd.tmpfiles.rules = [
      "d ${cfg.persistPath} 0755 root root -"
      "d ${cfg.persistPath}/system 0755 root root -"
      "d ${cfg.persistPath}/home 0755 root root -"
      "d ${cfg.persistPath}/home/${userName} 0700 ${userName} users -"
    ];

    # System-level persistence
    environment.persistence."${cfg.persistPath}/system" = {
      hideMounts = true;

      directories = [
        # System state
        "/var/lib/bluetooth"
        "/var/lib/NetworkManager"
        "/var/lib/systemd/coredump"
        "/var/lib/nixos" # NixOS state (user UIDs, etc.)

        # Network connections
        "/etc/NetworkManager/system-connections"
      ];

      files = [
        # Machine identity
        "/etc/machine-id"

        # SSH host keys (required for agenix)
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];
    };

    # Warn user if persist partition doesn't exist
    assertions = [{
      assertion = builtins.pathExists cfg.persistPath;
      message = ''
        Impermanence is enabled but ${cfg.persistPath} doesn't exist!

        You need to either:
        1. Create and mount a persistent partition at ${cfg.persistPath}
        2. Disable custom.persistence.enable until you set this up

        See: https://github.com/nix-community/impermanence
      '';
    }];
  };
}
