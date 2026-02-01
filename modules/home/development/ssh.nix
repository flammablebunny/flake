{ config, lib, userName, ... }:

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
    userName = "flammablebunny";
    userEmail = "theflammablebunny@gmail.com";

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

      # Read name and email from the decrypted secret
      # Expected format: name=Your Name\nemail=your@email.com
      PRO_NAME=$(grep '^name=' "$IDENTITY_FILE" | cut -d'=' -f2-)
      PRO_EMAIL=$(grep '^email=' "$IDENTITY_FILE" | cut -d'=' -f2-)

      # Generate gitconfig include
      cat > "$OUTPUT_FILE" << EOF
[user]
    name = $PRO_NAME
    email = $PRO_EMAIL
EOF
      chmod 600 "$OUTPUT_FILE"
    fi
  '';

  # Ensure ~/pro directory exists for school repos
  home.file.".keep-pro-dir" = {
    target = "pro/.gitkeep";
    text = "";
  };
}
