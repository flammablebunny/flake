return {
  {
    "vyfor/cord.nvim",
    event = "VeryLazy", -- Loads slightly later to not slow down startup
    opts = {
      usercmds = true, -- Enable commands like :CordConnect
      timer = {
        enable = true,
        show_time = true,
      },
      editor = {
        client = "neovim", -- Shows the Neovim icon in Discord
        tooltip = "The Superior Text Editor",
      },
      display = {
        theme = "default", -- Matches your other setup!
      },
    },
  },
}
