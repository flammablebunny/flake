let
  # User's personal age key (for encrypting/editing secrets)
  bunnyAge = "age1vt7xwl0rgxcn2dadz7cq33vq74wzvcf6n9c4c09wgca0hrdqsecssyth5t";

  # SSH key locations
  pc = "/run/agenix.d/17/ssh-private-key";
  laptop = ""; # TODO: Add after installing nix on laptop

  # All keys that can decrypt (user key always included for editing)
  allKeys = [ bunnyAge ] ++ (if pc != "" then [ pc ] else []) ++ (if laptop != "" then [ laptop ] else []);
  pcKeys = [ bunnyAge ] ++ (if pc != "" then [ pc ] else []);
in
{
  # SSH keys (needed on all machines)
  "ssh/id_ed25519.age".publicKeys = allKeys;
  "ssh/id_ed25519.pub.age".publicKeys = allKeys;
  "ssh/known_hosts.age".publicKeys = allKeys;

  # App secrets
  "waywall-oauth.age".publicKeys = pcKeys;
  "paceman-key.age".publicKeys = pcKeys;

  # Wallpapers
  "wallpapers/rabbit_forest.png.age".publicKeys = allKeys;
}
