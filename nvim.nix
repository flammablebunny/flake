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
      -- LazyVim + cord + noice (without LazyVim's default imports which conflict)
      require("lazy").setup({
        spec = {
          -- LazyVim without auto-importing plugins (to avoid conflicts)
          { "folke/LazyVim", version = false },

          -- Core LazyVim plugins manually
          { "LazyVim/LazyVim", version = false },
          { "nvim-lua/plenary.nvim" },
          { "folke/snacks.nvim" },
          { "folke/trouble.nvim" },
          { "folke/which-key.nvim" },
          { "nvim-telescope/telescope.nvim" },
          { "nvim-neo-tree/neo-tree.nvim" },
          { "nvim-treesitter/nvim-treesitter" },
          { "nvim-treesitter/nvim-treesitter-textobjects" },
          { "neovim/nvim-lspconfig" },
          { "hrsh7th/nvim-cmp", lazy = true },
          { "L3MON4D3/LuaSnip", lazy = true },

          -- Visual and UI plugins
          {
            "catppuccin/nvim",
            name = "catppuccin",
            lazy = false,
            priority = 1000,
            config = function()
              dofile(vim.fn.expand("~/.config/nvim/lua/caelestia.lua"))
            end,
          },
          { "nvim-lualine/lualine.nvim" },
          { "akinsho/bufferline.nvim" },
          { "nvim-tree/nvim-web-devicons" },
          { "echasnovski/mini.nvim" },
          { "stevearc/conform.nvim" },
          { "mfussenegger/nvim-lint" },
          { "lewis6991/gitsigns.nvim" },
          { "folke/todo-comments.nvim" },
          { "folke/persistence.nvim" },
          { "nvim-ts-autotag" },
          { "wellle/targets.vim" },
          { "jiangmiao/auto-pairs" },
          { "tpope/vim-surround" },

          -- Cord for Discord RPC
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
        ui = { backdrop = 100 },
        rocks = { enabled = false },
        performance = {
          reset_packpath = false,
          rtp = { reset = false, disabled_plugins = { "editorconfig", "gzip", "netrw", "netrwPlugin", "netrwSettings", "netrwFileHandlers", "matchit", "2html_plugin", "getscript", "getscriptPlugin", "logipat", "rrhelper", "spellfile_plugin", "vimball", "vimballPlugin" } },
        },
      })
    '';

    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      LazyVim

      # Core plugins
      plenary-nvim
      snacks-nvim
      trouble-nvim
      which-key-nvim
      telescope-nvim
      neo-tree-nvim
      nvim-treesitter
      nvim-treesitter-textobjects
      nvim-lspconfig
      blink-cmp
      luasnip

      # Visual & UI
      catppuccin-nvim
      lualine-nvim
      bufferline-nvim
      nvim-web-devicons
      conform-nvim
      nvim-lint
      gitsigns-nvim
      todo-comments-nvim
      persistence-nvim
      nvim-ts-autotag

      # Editor enhancements
      flash-nvim
      nui-nvim
      noice-nvim
      targets-vim
      vim-surround

      # Mini plugins
      mini-ai
      mini-icons
      mini-pairs

      # Custom & extras
      catppuccin-nvim
      claude-code-nvim
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
    "nvim/lua/caelestia.lua".source = ./lua/caelestia.lua;
  };
}
