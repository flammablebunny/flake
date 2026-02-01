{ config, lib, pkgs, ... }:

{
  security.polkit.enable = true;

  # Allow users in wheel/networkmanager groups to manage WiFi without password
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("org.freedesktop.NetworkManager.") == 0 &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';
}
