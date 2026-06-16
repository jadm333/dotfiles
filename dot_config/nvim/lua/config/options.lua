-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- Use system clipboard
vim.opt.clipboard = "unnamedplus"

-- Enable mouse support
vim.o.mouse = 'a'

-- Auto-reload files changed outside of Neovim
vim.opt.autoread = true

-- Single global statusline spanning the full width (lualine reads this)
vim.opt.laststatus = 3

vim.wo.number = true
vim.wo.relativenumber = true
vim.wo.foldenable = false

-- Clear search highlight with Escape
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic display
vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})
