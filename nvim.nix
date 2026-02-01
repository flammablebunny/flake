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

  claudeLua = ''
    return {
      {
        "greggh/claude-code.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        cmd = "ClaudeCode",
        keys = { { "<leader>cc", "<cmd>ClaudeCode<CR>", desc = "Toggle Claude Code" } },
        config = function() require("claude-code").setup() end,
      }
    }
  '';

  caelestiaLua = ''
    return {
      {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = function(_, opts)
          opts.flavour = "mocha"
          opts.transparent_background = true

          local function get_caelestia_data()
            local home = os.getenv("HOME")
            local cmd = 'ls -td ' .. home .. '/.cache/caelestia/schemes/*/ 2>/dev/null | head -1'
            local handle = io.popen(cmd)
            local latest_dir = handle:read("*a"):gsub("\n", "")
            handle:close()

            if latest_dir == "" then return nil end
            local file = io.open(latest_dir .. "/vibrant/dark.json", "r")
            if not file then return nil end
            local content = file:read("*a")
            file:close()
            local ok, data = pcall(vim.json.decode, content)
            if not ok then return nil end
            return data
          end

          local c = get_caelestia_data()
          if c then
            local function h(hex) return "#" .. (hex or "000000") end
            opts.color_overrides = {
              mocha = {
                base = h(c.base),
                mantle = h(c.mantle),
                crust = h(c.crust),
                text = h(c.text),
                blue = h(c.blue),
              },
            }
          end
        end,
      },
      { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
    }
  '';

in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraLuaConfig = ''
      require("lazy").setup({
        spec = {
          { "LazyVim/LazyVim", import = "lazyvim.plugins" },
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

  xdg.configFile."nvim/lua/plugins/caelestia.lua".text = caelestiaLua;
  xdg.configFile."nvim/lua/plugins/claude.lua".text = claudeLua;
  xdg.configFile."nvim/lua/config/options.lua".source = ./lua/config/options.lua;
  xdg.configFile."nvim/lua/config/keymaps.lua".source = ./lua/config/keymaps.lua;
  xdg.configFile."nvim/lua/plugins/cord.lua".source = ./lua/plugins/cord.lua;
}
