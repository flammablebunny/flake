{ pkgs, inputs, ... }:

let
  claude-code-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "claude-code-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "greggh";
      repo = "claude-code.nvim";
      rev = "main";
      sha256 = "sha256-HBHlP2k4vUCbE+Sgm6vN5XE7UGnioFvj8CI6h5H+8x8=";
    };
    dependencies = [ pkgs.vimPlugins.plenary-nvim ];
  };

  minuet-ai-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "minuet-ai-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "milanglacier";
      repo = "minuet-ai.nvim";
      rev = "33c6f4ad809bb28347c275cffc3e5700057d1c3c";
      sha256 = "sha256-7s3t1mr6BFQD9bP3Wzg/m0SDWswufrVVYaxLSG4zt8k=";
    };
    dependencies = [ pkgs.vimPlugins.plenary-nvim ];
    nvimRequireCheck = "minuet";
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
        # Folding (nvim-ufo manages actual folding)
        foldcolumn = "1";
        foldlevel = 99;
        foldlevelstart = 99;
        foldenable = true;
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

      # nvim-cmp disabled (segfault on ";") using blink.cmp instead
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
          package = pkgs.vimPlugins.cord-nvim;
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
                rust = { "rustfmt" },
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

        # Crate version management in Cargo.toml
        crates = {
          package = pkgs.vimPlugins.crates-nvim;
          setup = ''
            require('crates').setup {
              lsp = {
                enabled = true,
                actions = true,
                completion = true,
                hover = true,
              },
            }
          '';
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

        # Direnv integration (auto-loads nix develop shells)
        direnv = {
          package = pkgs.vimPlugins.direnv-vim;
        };

        # AI completions (minuet-ai via local Ollama)
        minuet-ai = {
          package = minuet-ai-nvim;
          setup = ''
            require('minuet').setup {
              provider = 'openai_fim_compatible',
              n_completions = 1,
              context_window = 512,
              provider_options = {
                openai_fim_compatible = {
                  api_key = 'TERM',
                  name = 'Ollama',
                  end_point = 'http://localhost:11434/v1/completions',
                  model = 'qwen2.5-coder:7b',
                  optional = {
                    max_tokens = 56,
                    top_p = 0.9,
                  },
                },
              },
            }
          '';
        };

        # Autocompletion (blink.cmp replaces nvim-cmp)
        blink-cmp = {
          package = pkgs.vimPlugins.blink-cmp;
          setup = ''
            require('blink.cmp').setup {
              keymap = {
                preset = 'none',
                ['<CR>'] = { 'accept', 'fallback' },
                ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
                ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
                ['<C-space>'] = { 'show', 'hide' },
                ['<C-e>'] = { 'cancel', 'fallback' },
                ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
                ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
              },
              fuzzy = { implementation = 'lua' },
              appearance = { nerd_font_variant = 'mono' },
              sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer', 'minuet' },
                providers = {
                  minuet = {
                    name = 'minuet',
                    module = 'minuet.blink',
                    async = true,
                    timeout_ms = 3000,
                    score_offset = 50,
                  },
                },
              },
              completion = {
                accept = { auto_brackets = { enabled = true } },
                documentation = { auto_show = true, auto_show_delay_ms = 200 },
                trigger = { prefetch_on_insert = false },
              },
              signature = { enabled = true },
            }
          '';
        };

        # Debugging
        nvim-dap = {
          package = pkgs.vimPlugins.nvim-dap;
        };

        nvim-nio = {
          package = pkgs.vimPlugins.nvim-nio;
        };

        nvim-dap-ui = {
          package = pkgs.vimPlugins.nvim-dap-ui;
        };

        # Diagnostics list
        trouble = {
          package = pkgs.vimPlugins.trouble-nvim;
          setup = "require('trouble').setup {}";
        };

        # Quick file navigation
        harpoon = {
          package = pkgs.vimPlugins.harpoon2;
          setup = "require('harpoon'):setup()";
        };

        # Better folds
        promise-async = {
          package = pkgs.vimPlugins.promise-async;
        };

        nvim-ufo = {
          package = pkgs.vimPlugins.nvim-ufo;
          setup = ''
            require('ufo').setup {
              provider_selector = function()
                return { 'treesitter', 'indent' }
              end,
            }
          '';
        };

        # Code outline / symbol sidebar
        outline = {
          package = pkgs.vimPlugins.outline-nvim;
          setup = "require('outline').setup {}";
        };

        # Project-wide search & replace
        spectre = {
          package = pkgs.vimPlugins.nvim-spectre;
          setup = "require('spectre').setup {}";
        };

        # Indent guides
        indent-blankline = {
          package = pkgs.vimPlugins.indent-blankline-nvim;
          setup = "require('ibl').setup {}";
        };

        # Linting
        nvim-lint = {
          package = pkgs.vimPlugins.nvim-lint;
        };

        # Image preview 
        image = {
          package = pkgs.vimPlugins.image-nvim;
          setup = ''
            require('image').setup {
              backend = "kitty",
              integrations = {
                markdown = { enabled = true },
              },
            }
          '';
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



      # DAP (debugger) setup
      luaConfigRC.dap-setup = ''
        local dap = require('dap')
        local dapui = require('dapui')
        dapui.setup()

        -- Auto open/close DAP UI
        dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end
        dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
        dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end

        -- lldb adapter for C/C++ (Rust is handled by rustaceanvim)
        dap.adapters.lldb = {
          type = 'executable',
          command = 'lldb-dap',
          name = 'lldb',
        }
      '';

      # Lint setup
      luaConfigRC.lint-setup = ''
        local lint = require('lint')
        lint.linters_by_ft = {
          javascript = { 'eslint' },
          typescript = { 'eslint' },
          sh = { 'shellcheck' },
          bash = { 'shellcheck' },
        }
        vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
          callback = function()
            lint.try_lint()
          end,
        })
      '';

      # Disable Arrow Keys + all keymaps
      luaConfigRC.keymaps = ''
        -- Disable arrow keys in all modes
        -- local arrows = { "<Up>", "<Down>", "<Left>", "<Right>" }
        -- local modes = { "n", "i", "v", "x", "s", "o", "c" }
        -- for _, mode in ipairs(modes) do
        --   for _, key in ipairs(arrows) do
        --     vim.keymap.set(mode, key, '<cmd>echo "NAUGHTLY ARROW KEY USING BUNNY"<CR>')
        --   end
        -- end

        -- File explorer (Neo-tree)
        vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "Toggle Neo-tree" })
        vim.keymap.set("n", "<leader>E", "<cmd>Neotree reveal<CR>", { desc = "Reveal file in Neo-tree" })

        -- Trouble (diagnostics)
        vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Diagnostics (Trouble)" })
        vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Buffer diagnostics" })
        vim.keymap.set("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>", { desc = "Symbols (Trouble)" })
        vim.keymap.set("n", "<leader>xq", "<cmd>Trouble qflist toggle<CR>", { desc = "Quickfix (Trouble)" })

        -- Harpoon
        local harpoon = require('harpoon')
        vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon add file" })
        vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })
        vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon file 1" })
        vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon file 2" })
        vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon file 3" })
        vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon file 4" })

        -- DAP (debugging)
        vim.keymap.set("n", "<leader>db", function() require('dap').toggle_breakpoint() end, { desc = "Toggle breakpoint" })
        vim.keymap.set("n", "<leader>dc", function() require('dap').continue() end, { desc = "Continue" })
        vim.keymap.set("n", "<leader>di", function() require('dap').step_into() end, { desc = "Step into" })
        vim.keymap.set("n", "<leader>do", function() require('dap').step_over() end, { desc = "Step over" })
        vim.keymap.set("n", "<leader>dO", function() require('dap').step_out() end, { desc = "Step out" })
        vim.keymap.set("n", "<leader>dr", function() require('dap').restart() end, { desc = "Restart" })
        vim.keymap.set("n", "<leader>dt", function() require('dap').terminate() end, { desc = "Terminate" })
        vim.keymap.set("n", "<leader>du", function() require('dapui').toggle() end, { desc = "Toggle DAP UI" })

        -- Outline (symbol sidebar)
        vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>", { desc = "Toggle code outline" })

        -- Spectre (project-wide search & replace)
        vim.keymap.set("n", "<leader>sr", function() require('spectre').toggle() end, { desc = "Search & replace (Spectre)" })
        vim.keymap.set("n", "<leader>sw", function() require('spectre').open_visual({ select_word = true }) end, { desc = "Search current word" })

        -- Crates.nvim (Cargo.toml)
        vim.keymap.set("n", "<leader>ct", function() require('crates').toggle() end, { desc = "Toggle crate info" })
        vim.keymap.set("n", "<leader>cu", function() require('crates').update_crate() end, { desc = "Update crate" })
        vim.keymap.set("n", "<leader>cU", function() require('crates').upgrade_crate() end, { desc = "Upgrade crate" })
        vim.keymap.set("n", "<leader>ci", function() require('crates').show_popup() end, { desc = "Crate info popup" })
        vim.keymap.set("n", "<leader>cf", function() require('crates').show_features_popup() end, { desc = "Crate features" })
        vim.keymap.set("n", "<leader>cd", function() require('crates').show_dependencies_popup() end, { desc = "Crate dependencies" })

        -- Folding (nvim-ufo)
        vim.keymap.set("n", "zR", function() require('ufo').openAllFolds() end, { desc = "Open all folds" })
        vim.keymap.set("n", "zM", function() require('ufo').closeAllFolds() end, { desc = "Close all folds" })
        vim.keymap.set("n", "zK", function() require('ufo').peekFoldedLinesUnderCursor() end, { desc = "Peek fold" })
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
        rust-analyzer
        rustfmt
        clippy
        tree-sitter
        jdt-language-server
        maven
        # Linters
        shellcheck
        eslint
        # Debugger adapter
        lldb
        # Image preview
        imagemagick
      ];
    };
  };
}
