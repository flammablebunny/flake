-- Indentation (2 spaces)
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 3 -- Size of an indent
vim.opt.tabstop = 3 -- Number of spaces tabs count for
vim.opt.softtabstop = 3

-- UI Config
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true -- Show relative line numbers (great for jumping)
vim.opt.cursorline = true -- Highlight the text line of the cursor
vim.opt.wrap = false -- Disable text wrapping (set to true if you want wrapping)

-- Invisible Characters
vim.opt.list = false -- Set to true to see dots/dashes for spaces
-- If you DO want to see them, uncomment the line below:
-- vim.opt.listchars = { space = "·", tab = "» ", trail = "·", nbsp = "␣" }

-- Search
vim.opt.ignorecase = true -- Ignore case when searching...
vim.opt.smartcase = true -- ...unless you type a capital letter
