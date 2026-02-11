let
  # personal age key (for encrypting/editing secrets)
  bunnyAge = "age1vt7xwl0rgxcn2dadz7cq33vq74wzvcf6n9c4c09wgca0hrdqsecssyth5t";

  # Age public keys derived from SSH host keys (use: ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub)
  pc = "age153h6ffskfh2xj4zqt6zazrsyuh0v3valdtm8dpsvg8lcpr9uf9vqf096kh";
  laptop = "age153h6ffskfh2xj4zqt6zazrsyuh0v3valdtm8dpsvg8lcpr9uf9vqf096kh";

  # All keys that can decrypt (user key always included for editing)
  allKeys = [ bunnyAge ] ++ (if pc != "" then [ pc ] else []) ++ (if laptop != "" then [ laptop ] else []);
  pcKeys = [ bunnyAge ] ++ (if pc != "" then [ pc ] else []);
in
{
  # SSH keys
  "ssh/id_ed25519.age".publicKeys = allKeys;
  "ssh/id_ed25519.pub.age".publicKeys = allKeys;
  "ssh/id_ed2026.age".publicKeys = allKeys;
  "ssh/id_ed2026.pub.age".publicKeys = allKeys;
  "ssh/known_hosts.age".publicKeys = allKeys;

  # Git identity
  "professional-identity.age".publicKeys = allKeys;

  # App secrets
  "waywall-oauth.age".publicKeys = pcKeys;
  "paceman-key.age".publicKeys = pcKeys;

  # Wallpapers
  "wallpapers/rabbit_forest.png.age".publicKeys = allKeys;
}
