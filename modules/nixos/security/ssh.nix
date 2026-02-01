{ config, lib, pkgs, ... }:

{
  # Enable SSH daemon to generate host keys
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
    # Generate ed25519 host key for agenix
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
}
