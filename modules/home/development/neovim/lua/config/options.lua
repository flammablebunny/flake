vim.opt.expandtab = true
vim.opt.shiftwidth = 3
vim.opt.tabstop = 3
vim.opt.softtabstop = 3

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.wrap = false

vim.opt.list = false

vim.opt.ignorecase = true
vim.opt.smartcase = true

-- disable arrow keys
vim.keymap.set("n", "<left>", '<cmd>echo "NAUGHTLY ARROW KEY USING BUNNY"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "NAUGHTLY ARROW KEY USING BUNNY"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "NAUGHTLY ARROW KEY USING BUNNY"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "NAUGHTLY ARROW KEY USING BUNNY"<CR>')
