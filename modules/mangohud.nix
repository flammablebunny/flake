{ pkgs, ... }:

{
  programs.mangohud = {
    enable = true;

    settings = {
      fps_limit = 180;
      no_display = true;
      gl_version = "2.1";
      opengl_core_context = false;
    };
  };
}
