{ config, lib, pkgs, userName, ... }:

{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      # Personal GitHub (default)
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "/home/${userName}/.ssh/id_ed25519";
        identitiesOnly = true;
      };
      # Professional GitHub (for orgs like team5419)
      "github-pro" = {
        hostname = "github.com";
        user = "git";
        identityFile = "/home/${userName}/.ssh/id_ed2026";
        identitiesOnly = true;
      };
    };
  };

  programs.git = {
    enable = true;
    settings.user.name = "flammablebunny";
    settings.user.email = "theflammablebunny@gmail.com";

    includes = [
      {
        condition = "gitdir:~/pro/";
        path = "~/.config/git/pro-identity";
      }
    ];
  };

  home.activation.setupProIdentity = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    IDENTITY_FILE="/run/agenix/professional-identity"
    OUTPUT_DIR="$HOME/.config/git"
    OUTPUT_FILE="$OUTPUT_DIR/pro-identity"

    if [ -f "$IDENTITY_FILE" ]; then
      mkdir -p "$OUTPUT_DIR"

      PRO_NAME=$(${lib.getExe' pkgs.gnugrep "grep"} '^name=' "$IDENTITY_FILE" | cut -d'=' -f2-)
      PRO_EMAIL=$(${lib.getExe' pkgs.gnugrep "grep"} '^email=' "$IDENTITY_FILE" | cut -d'=' -f2-)

      printf '[user]\n    name = %s\n    email = %s\n' "$PRO_NAME" "$PRO_EMAIL" > "$OUTPUT_FILE"
      chmod 600 "$OUTPUT_FILE"
    fi
  '';

  # Ensure ~/pro directory exists for school repos
  home.file.".keep-pro-dir" = {
    target = "pro/.gitkeep";
    text = "";
  };
}
