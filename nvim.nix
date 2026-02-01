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
      -- All plugin specifications defined directly in Nix for reproducibility
      -- Plugins with native builds that cause ABI incompatibility are disabled
      require("lazy").setup({
        spec = {
          { "LazyVim/LazyVim", import = "lazyvim.plugins", build = false },

          -- Catppuccin theme with Mocha flavor
          {
            "catppuccin/nvim",
            name = "catppuccin",
            priority = 1000,
            build = false,
            config = function()
              require("catppuccin").setup({
                flavour = "mocha",
              })
              vim.cmd("colorscheme catppuccin")
            end,
          },

          -- Claude Code plugin integration
          {
            "greggh/claude-code.nvim",
            build = false,
            dependencies = { "nvim-lua/plenary.nvim" },
          },

          -- Disable problematic plugins with native builds or command-line hooks
          {
            "vyfor/cord.nvim",
            enabled = false,  -- Requires zig build, causes segfault
          },

          {
            "nvim-treesitter/nvim-treesitter",
            enabled = false,  -- Parser compilation causes ABI issues
          },

          {
            "folke/noice.nvim",
            enabled = false,  -- UI replacement causes segfault on command mode
          },

          {
            "folke/snacks.nvim",
            enabled = false,  -- UI modifications cause segfault with command-line
          },

          {
            "saghen/blink.cmp",
            build = false,  -- Disable native fuzzy matcher
          },

          -- Import any user plugins (if plugins dir exists)
          { import = "plugins" },
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
      LazyVim

      blink-cmp
      bufferline-nvim
      flash-nvim
      mini-ai
      mini-icons
      mini-pairs
      neo-tree-nvim
      noice-nvim
      nui-nvim
      nvim-lint
      nvim-lspconfig
      persistence-nvim
      plenary-nvim
      snacks-nvim
      telescope-nvim
      todo-comments-nvim
      tokyonight-nvim
      trouble-nvim
      ts-comments-nvim
      which-key-nvim

      catppuccin-nvim
      claude-code-nvim
      cord-nvim
    ];

    extraPackages = with pkgs; [
      git lazygit ripgrep fd unzip gzip curl
      gcc gnumake
      nodejs_22
      lua-language-server nil stylua shfmt
      cargo rustc
    ];
  };

  xdg.configFile = {
    "nvim/lua/config/options.lua".source = ./lua/config/options.lua;
    "nvim/lua/config/keymaps.lua".source = ./lua/config/keymaps.lua;
  };
}
