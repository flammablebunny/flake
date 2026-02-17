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
      sha256 = "sha256-lQgto4Sp50P9PZ3lxdqFaMA1bwidHII9GhTaXwSMW7o=";
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

      # Leader key
      globals.mapleader = " ";

      # Theme
      theme = {
        enable = true;
        name = "catppuccin";
        style = "mocha";
      };

      # Treesitter
      treesitter = {
        enable = true;
        addDefaultGrammars = true;
        grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          markdown
          markdown_inline
          html
          latex
          yaml
        ];
      };

      # LSP
      lsp = {
        enable = true;
        lspconfig.enable = true;
      };

      # Languages
      languages = {
        nix.enable = true;
        lua.enable = true;
        rust.enable = false;  # using rustaceanvim instead
        ts.enable = true;
        html.enable = false;  # disabled - superhtml package broken upstream
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

        # Auto-close brackets/quotes
        autopairs = {
          package = pkgs.vimPlugins.nvim-autopairs;
          setup = "require('nvim-autopairs').setup {}";
        };

        # Toggle comments (gcc, gc)
        comment = {
          package = pkgs.vimPlugins.comment-nvim;
          setup = "require('Comment').setup {}";
        };

        # Floating terminal
        toggleterm = {
          package = pkgs.vimPlugins.toggleterm-nvim;
          setup = ''
            require('toggleterm').setup {
              open_mapping = [[<C-\>]],
              direction = 'float',
              float_opts = {
                border = 'curved',
              },
            }
          '';
        };

        # Better Lua LSP for nvim configs
        lazydev = {
          package = pkgs.vimPlugins.lazydev-nvim;
          setup = "require('lazydev').setup {}";
        };

        # Enhanced Rust tooling
        rustaceanvim = {
          package = pkgs.vimPlugins.rustaceanvim;
        };

        # Better TypeScript/JS support
        typescript-tools = {
          package = pkgs.vimPlugins.typescript-tools-nvim;
          setup = "require('typescript-tools').setup {}";
        };

        # Java LSP
        nvim-jdtls = {
          package = pkgs.vimPlugins.nvim-jdtls;
        };

        # Markdown preview/rendering
        markview = {
          package = pkgs.vimPlugins.markview-nvim;
          setup = "require('markview').setup {}";
        };

        # Markdown browser preview
        markdown-preview = {
          package = pkgs.vimPlugins.markdown-preview-nvim;
        };
      };

      # Disable semantic tokens (prevents green overload from rust-analyzer)
      luaConfigRC.semantic-tokens = ''
        vim.api.nvim_create_autocmd("LspAttach", {
          callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client then
              client.server_capabilities.semanticTokensProvider = nil
            end
          end,
        })
      '';


/*
      # Disable Arrow Keys
      luaConfigRC.keymaps = ''
        -- Disable arrow keys in all modes
        local arrows = { "<Up>", "<Down>", "<Left>", "<Right>" }
        local modes = { "n", "i", "v", "x", "s", "o", "c" }
        for _, mode in ipairs(modes) do
          for _, key in ipairs(arrows) do
            vim.keymap.set(mode, key, '<cmd>echo "NAUGHTLY ARROW KEY USING BUNNY"<CR>')
          end
        end

        -- File explorer (Neo-tree)
        vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "Toggle Neo-tree" })
        vim.keymap.set("n", "<leader>E", "<cmd>Neotree reveal<CR>", { desc = "Reveal file in Neo-tree" })
      '';
*/
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
        rust-analyzer
        tree-sitter
        jdt-language-server
        maven
      ];
    };
  };
}
