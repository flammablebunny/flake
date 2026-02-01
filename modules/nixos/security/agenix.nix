{ config, lib, pkgs, inputs, userName, ... }:

{
  # Use SSH host key (auto-generated) with fallback to manual age key
  age.identityPaths = [
    "/etc/ssh/ssh_host_ed25519_key"              # Primary: auto-generated SSH host key
    "/home/${userName}/.config/agenix/key.txt"  # Fallback: manual age key (for bootstrap)
  ];

  age.secrets = {
    # SSH keys - placed in user's .ssh directory
    "ssh-private-key" = {
      file = ../../../secrets/ssh/id_ed25519.age;
      path = "/home/${userName}/.ssh/id_ed25519";
      owner = userName;
      group = "users";
      mode = "0600";
    };
    "ssh-public-key" = {
      file = ../../../secrets/ssh/id_ed25519.pub.age;
      path = "/home/${userName}/.ssh/id_ed25519.pub";
      owner = userName;
      group = "users";
      mode = "0644";
    };
    "ssh-known-hosts" = {
      file = ../../../secrets/ssh/known_hosts.age;
      path = "/home/${userName}/.ssh/known_hosts";
      owner = userName;
      group = "users";
      mode = "0644";
    };

    # App secrets
    waywall-oauth = {
      file = ../../../secrets/waywall-oauth.age;
      owner = userName;
      group = "users";
      mode = "0400";
    };
    paceman-key = {
      file = ../../../secrets/paceman-key.age;
      owner = userName;
      group = "users";
      mode = "0400";
    };

    # Wallpapers
    "wallpaper-rabbit-forest" = {
      file = ../../../secrets/wallpapers/rabbit_forest.png.age;
      path = "/home/${userName}/Pictures/Wallpapers/rabbit forest.png";
      owner = userName;
      group = "users";
      mode = "0644";
    };
    "wallpaper-rabbit-forest-no-grain" = {
      file = ../../../secrets/wallpapers/rabbit_forest_no_grain.png.age;
      path = "/home/${userName}/Pictures/Wallpapers/rabbit forest no grain.png";
      owner = userName;
      group = "users";
      mode = "0644";
    };
    "wallpaper-rabbit-forest-no-grain-no-particles" = {
      file = ../../../secrets/wallpapers/rabbit_forest_no_grain_no_particles.png.age;
      path = "/home/${userName}/Pictures/Wallpapers/rabbit forest no grain no particles.png";
      owner = userName;
      group = "users";
      mode = "0644";
    };
    "wallpaper-rabbit-forest-no-particles" = {
      file = ../../../secrets/wallpapers/rabbit_forest_no_particles.png.age;
      path = "/home/${userName}/Pictures/Wallpapers/rabbit forest no particles.png";
      owner = userName;
      group = "users";
      mode = "0644";
    };
    "wallpaper-rabbit-forest-no-sign" = {
      file = ../../../secrets/wallpapers/rabbit_forest_no_sign.png.age;
      path = "/home/${userName}/Pictures/Wallpapers/rabbit forest no sign.png";
      owner = userName;
      group = "users";
      mode = "0644";
    };
    "wallpaper-rabbit-forest-no-sign-no-grain" = {
      file = ../../../secrets/wallpapers/rabbit_forest_no_sign_no_grain.png.age;
      path = "/home/${userName}/Pictures/Wallpapers/rabbit forest no sign no grain.png";
      owner = userName;
      group = "users";
      mode = "0644";
    };
    "wallpaper-rabbit-forest-no-sign-no-grain-no-particles" = {
      file = ../../../secrets/wallpapers/rabbit_forest_no_sign_no_grain_no_particles.png.age;
      path = "/home/${userName}/Pictures/Wallpapers/rabbit forest no sign no grain no particles.png";
      owner = userName;
      group = "users";
      mode = "0644";
    };
    "wallpaper-rabbit-forest-no-sign-no-particles" = {
      file = ../../../secrets/wallpapers/rabbit_forest_no_sign_no_particles.png.age;
      path = "/home/${userName}/Pictures/Wallpapers/rabbit forest no sign no particles.png";
      owner = userName;
      group = "users";
      mode = "0644";
    };
  };

  systemd.tmpfiles.rules = [
    "d /home/${userName}/Pictures/Wallpapers 0755 ${userName} users -"
    "d /home/${userName}/.ssh 0700 ${userName} users -"
  ];

  environment.systemPackages = [
    inputs.agenix.packages.${pkgs.system}.default
    pkgs.ssh-to-age  # For converting SSH keys to age keys
  ];
}
