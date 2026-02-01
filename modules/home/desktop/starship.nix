{ pkgs, userName, ... }:

{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = true;

      format = "$username$hostname:$directory$git_branch$git_status$character";

      username = {
        show_always = true;
        style_user = "cyan";
        style_root = "bold red";
        format = "[$user]($style)";
      };

      hostname = {
        ssh_only = false;
        style = "purple";
        format = "@[$hostname]($style)";
      };

      directory = {
        style = "bold cyan";
        format = "[$path]($style)[$read_only]($read_only_style) ";
        truncation_length = 3;
        truncate_to_repo = true;
      };

      git_branch = {
        style = "bold purple";
        format = "[$symbol$branch]($style) ";
        symbol = " ";
      };

      git_status = {
        style = "bold red";
        format = "[$all_status$ahead_behind]($style)";
      };

      character = {
        success_symbol = "[\\$](white) ";
        error_symbol = "[\\$](bold red) ";
      };

      # Disable modules we don't need
      aws.disabled = true;
      gcloud.disabled = true;
      kubernetes.disabled = true;
    };
  };
}
