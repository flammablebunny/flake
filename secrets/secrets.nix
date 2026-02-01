# This file defines which public keys can decrypt which secrets.

let
  # Dedicated age key for agenix (no passphrase required)
  bunnyAge = "age1vt7xwl0rgxcn2dadz7cq33vq74wzvcf6n9c4c09wgca0hrdqsecssyth5t";

  users = [ bunnyAge ];
in
{
  # Waywall Twitch OAuth token
  "waywall-oauth.age".publicKeys = users;

  # PaceMan access key
  "paceman-key.age".publicKeys = users;

  # Wallpapers
  "wallpapers/rabbit_forest.png.age".publicKeys = users;
  "wallpapers/rabbit_forest_no_grain.png.age".publicKeys = users;
  "wallpapers/rabbit_forest_no_grain_no_particles.png.age".publicKeys = users;
  "wallpapers/rabbit_forest_no_particles.png.age".publicKeys = users;
  "wallpapers/rabbit_forest_no_sign.png.age".publicKeys = users;
  "wallpapers/rabbit_forest_no_sign_no_grain.png.age".publicKeys = users;
  "wallpapers/rabbit_forest_no_sign_no_grain_no_particles.png.age".publicKeys = users;
  "wallpapers/rabbit_forest_no_sign_no_particles.png.age".publicKeys = users;
}
