let
  bunnyAge = "age1vt7xwl0rgxcn2dadz7cq33vq74wzvcf6n9c4c09wgca0hrdqsecssyth5t";

  users = [ bunnyAge ];
in
{
  "waywall-oauth.age".publicKeys = users;

  "paceman-key.age".publicKeys = users;

  "wallpapers/rabbit_forest.png.age".publicKeys = users;
  "wallpapers/rabbit_forest_no_grain.png.age".publicKeys = users;
  "wallpapers/rabbit_forest_no_grain_no_particles.png.age".publicKeys = users;
  "wallpapers/rabbit_forest_no_particles.png.age".publicKeys = users;
  "wallpapers/rabbit_forest_no_sign.png.age".publicKeys = users;
  "wallpapers/rabbit_forest_no_sign_no_grain.png.age".publicKeys = users;
  "wallpapers/rabbit_forest_no_sign_no_grain_no_particles.png.age".publicKeys = users;
  "wallpapers/rabbit_forest_no_sign_no_particles.png.age".publicKeys = users;
}
