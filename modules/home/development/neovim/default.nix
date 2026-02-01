{ pkgs, inputs, ... }:

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
  imports = [ inputs.nvf.homeManagerModules.default ];

  programs.nvf = {
    enable = true;

    settings.vim = {
      # Aliases
      viAlias = true;
      vimAlias = true;

      # Editor options
      options = {
        shiftwidth = 3;
        tabstop = 3;
        softtabstop = 3;
        expandtab = true;
        number = true;
        relativenumber = true;
        cursorline = true;
        wrap = false;
        list = false;
        ignorecase = true;
        smartcase = true;
      };

      # Theme - catppuccin (caelestia.lua will override colors)
      theme = {
        enable = true;
        name = "catppuccin";
        style = "mocha";
      };

      # Treesitter
      treesitter = {
        enable = true;
        autotagHtml = true;
      };

      # LSP
      lsp = {
        enable = true;
        lspconfig.enable = true;
      };

      # Languages
      languages = {
        enableLSP = true;
        enableTreesitter = true;
        nix.enable = true;
        lua.enable = true;
        rust.enable = true;
        ts.enable = true;
        html.enable = true;
        css.enable = true;
        bash.enable = true;
      };

      # Autocomplete - DISABLED (causes segfault on ";" key)
      autocomplete.nvim-cmp.enable = false;

      # Snippets
      snippets.luasnip.enable = true;

      # Telescope
      telescope.enable = true;

      # File tree
      filetree.neo-tree.enable = true;

      # Status line
      statusline.lualine.enable = true;

      # Tab line / bufferline
      tabline.nvimBufferline.enable = true;

      # Git
      git = {
        enable = true;
        gitsigns.enable = true;
      };

      # Which-key
      binds.whichKey.enable = true;

      # Extra plugins not built into nvf
      extraPlugins = {
        # Discord Rich Presence
        cord = {
          package = cord-nvim;
          setup = ''
            require('cord').setup {
              usercmds = true,
              timer = {
                enable = true,
                show_time = true,
              },
              editor = {
                client = "neovim",
                tooltip = "The Superior Text Editor",
              },
              display = {
                theme = "default",
              },
            }
          '';
        };

        # Claude Code integration
        claude-code = {
          package = claude-code-nvim;
          setup = "require('claude-code').setup {}";
        };

        # Surround
        surround = {
          package = pkgs.vimPlugins.vim-surround;
        };

        # Targets.vim for text objects
        targets = {
          package = pkgs.vimPlugins.targets-vim;
        };

        # Noice for better UI
        noice = {
          package = pkgs.vimPlugins.noice-nvim;
          setup = "require('noice').setup {}";
        };

        # Nui (dependency for noice)
        nui = {
          package = pkgs.vimPlugins.nui-nvim;
        };

        # Todo comments
        todo-comments = {
          package = pkgs.vimPlugins.todo-comments-nvim;
          setup = "require('todo-comments').setup {}";
        };

        # Conform for formatting
        conform = {
          package = pkgs.vimPlugins.conform-nvim;
          setup = ''
            require('conform').setup {
              formatters_by_ft = {
                lua = { "stylua" },
                nix = { "nixfmt" },
                sh = { "shfmt" },
              },
            }
          '';
        };

        # Persistence for session management
        persistence = {
          package = pkgs.vimPlugins.persistence-nvim;
          setup = "require('persistence').setup {}";
        };

        # Mini.nvim collection
        mini = {
          package = pkgs.vimPlugins.mini-nvim;
        };

        # Plenary (dependency for many plugins)
        plenary = {
          package = pkgs.vimPlugins.plenary-nvim;
        };
      };

      # Custom Lua config - caelestia colorscheme integration
      luaConfigRC.caelestia = ''
        -- Caelestia colorscheme integration
        ${builtins.readFile ./lua/caelestia.lua}
      '';

      # Disable Arrow Keys - FT. Arsoniv
      luaConfigRC.keymaps = ''
        -- Disable arrow keys
        vim.keymap.set("n", "<left>", '<cmd>echo "NAUGHTLY ARROW KEY USING BUNNY"<CR>')
        vim.keymap.set("n", "<right>", '<cmd>echo "NAUGHTLY ARROW KEY USING BUNNY"<CR>')
        vim.keymap.set("n", "<up>", '<cmd>echo "NAUGHTLY ARROW KEY USING BUNNY"<CR>')
        vim.keymap.set("n", "<down>", '<cmd>echo "NAUGHTLY ARROW KEY USING BUNNY"<CR>')
      '';

      # Extra packages for LSP, formatters, etc.
      extraPackages = with pkgs; [
        git
        lazygit
        ripgrep
        fd
        unzip
        gzip
        curl
        gcc
        gnumake
        nodejs_22
        lua-language-server
        nil
        stylua
        shfmt
        cargo
        rustc
        tree-sitter
      ];
    };
  };
}
