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
      require("lazy").setup({
        spec = {
          { "LazyVim/LazyVim", import = "lazyvim.plugins" },

          -- Catppuccin theme with Mocha flavor
          {
            "catppuccin/nvim",
            name = "catppuccin",
            priority = 1000,
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
            dependencies = { "nvim-lua/plenary.nvim" },
          },

          -- Cord.nvim for Discord RPC
          {
            "vyfor/cord.nvim",
            build = false,  -- Disable native build to avoid segfault
            -- config disabled to test if setup() call causes segfault
            -- config = function()
            --   require("cord").setup()
            -- end,
          },

          -- Noice for enhanced command-line UI
          {
            "folke/noice.nvim",
            dependencies = { "MunifTanjim/nui.nvim" },
            -- config disabled to test if setup() call causes segfault
            -- config = function()
            --   require("noice").setup()
            -- end,
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
      tree-sitter
    ];
  };

  xdg.configFile = {
    "nvim/lua/config/options.lua".source = ./lua/config/options.lua;
    "nvim/lua/config/keymaps.lua".source = ./lua/config/keymaps.lua;
  };
}
