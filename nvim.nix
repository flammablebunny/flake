{ pkgs, ... }:

let
  claude-code-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "claude-code-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "greggh";
      repo = "claude-code.nvim";
      rev = "main";
      sha256 = "0crfj852lwif5gipckb3hzagrvjccl6jg7xghs02d0v1vjx0yhk4";
    };
    dependencies = [ pkgs.vimPlugins.plenary-nvim ];
  };

  cord-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "cord.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "vyfor";
      repo = "cord.nvim";
      rev = "master";
      sha256 = "sha256-iatVlFU44iigiQKuXO3fS0OnKAZbgpBImaTLi6uECXs=";
    };
    doCheck = false;
  };

in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraLuaConfig = ''
      -- Minimal test: just cord and noice, no LazyVim
      require("lazy").setup({
        spec = {
          -- Cord.nvim for Discord RPC
          {
            "vyfor/cord.nvim",
            build = false,
            config = function()
              require("cord").setup()
            end,
          },

          -- Noice for enhanced command-line UI
          {
            "folke/noice.nvim",
            dependencies = { "MunifTanjim/nui.nvim" },
            config = function()
              require("noice").setup()
            end,
          },
        },
        defaults = { lazy = false, version = false },
        install = { missing = true },
        change_detection = { enabled = false, notify = false },
        performance = {
          reset_packpath = false,
          rtp = { reset = false },
        },
      })
    '';

    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      plenary-nvim
      noice-nvim
      nui-nvim
      cord-nvim
    ];

    extraPackages = with pkgs; [
      git lazygit ripgrep fd unzip gzip curl
      gcc gnumake
      nodejs_22
      lua-language-server nil stylua shfmt
      cargo rustc
      tree-sitter
    ];
  };

  xdg.configFile = {
    "nvim/lua/config/options.lua".source = ./lua/config/options.lua;
    "nvim/lua/config/keymaps.lua".source = ./lua/config/keymaps.lua;
  };
}
