{ pkgs, ... }:

{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      # Fastfetch on new terminal
      fastfetch

      # Starship custom prompt
      starship init fish | source

      # Direnv + Zoxide
      command -v direnv &> /dev/null && direnv hook fish | source
      command -v zoxide &> /dev/null && zoxide init fish --cmd cd | source

      # Better ls
      alias ls='eza --icons --group-directories-first -1'

      # Java fix
      set -gx JAVA_HOME (dirname (dirname (readlink -f (which java))))

      # Custom colours
      cat ~/.local/state/caelestia/sequences.txt 2> /dev/null

      # For jumping between prompts in foot terminal
      function mark_prompt_start --on-event fish_prompt
          echo -en "\e]133;A\e\\"
      end
    '';

    shellAbbrs = {
      # Git abbreviations
      lg = "lazygit";
      gd = "git diff";
      ga = "git add .";
      gc = "git commit -am";
      gl = "git log";
      gs = "git status";
      gst = "git stash";
      gsp = "git stash pop";
      gp = "git push";
      gpl = "git pull";
      gsw = "git switch";
      gsm = "git switch main";
      gb = "git branch";
      gbd = "git branch -d";
      gco = "git checkout";
      gsh = "git show";

      # ls abbreviations
      l = "ls";
      ll = "ls -l";
      la = "ls -a";
      lla = "ls -la";

      # NixOS rebuild
      nr = "/etc/nixos/scripts/rebuild.sh";
    };
  };
}
