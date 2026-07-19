vim.g.mapleader = ","
vim.g.maplocalleader = ","

local map = vim.keymap.set

-- Window navigation: <C-h/j/k/l> now handled by smart-splits.nvim
-- (crosses the nvim<->tmux boundary). See lua/plugins/navigation.lua.

-- neo-tree
map("n", "<C-n>", "<cmd>Neotree toggle<CR>", { desc = "Toggle file tree" })
map("n", "<leader>e", "<cmd>Neotree focus<CR>", { desc = "Focus file tree" })
map("n", "<leader>eb", "<cmd>Neotree buffers<CR>", { desc = "Open buffers panel" })
map("n", "<leader>eg", "<cmd>Neotree git_status<CR>", { desc = "Open git status panel" })

-- Lazygit
map("n", "<leader>gg", function() require("snacks").lazygit() end, { desc = "Lazygit" })

-- Lazy plugin manager
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy plugin manager" })

-- Delete/change without yanking (preserves clipboard)
map("x", "d", '"_d', { desc = "Delete without yanking" })
map("x", "c", '"_c', { desc = "Change without yanking" })

-- Move selected lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
