vim.g.mapleader = ","
vim.g.maplocalleader = ","

local map = vim.keymap.set

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window" })

-- neo-tree
map("n", "<C-n>", "<cmd>Neotree toggle<CR>", { desc = "Toggle file tree" })
map("n", "<leader>e", "<cmd>Neotree focus<CR>", { desc = "Focus file tree" })
map("n", "<leader>eb", "<cmd>Neotree buffers<CR>", { desc = "Open buffers panel" })
map("n", "<leader>eg", "<cmd>Neotree git_status<CR>", { desc = "Open git status panel" })

-- Lazygit
map("n", "<leader>gg", function() require("snacks").lazygit() end, { desc = "Lazygit" })

-- Lazy plugin manager
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy plugin manager" })