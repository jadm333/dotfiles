vim.g.mapleader = " "
vim.g.maplocalleader = ","

local map = vim.keymap.set

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window" })

-- Terminal toggle (alternative for Latin America keyboard layout)
map("n", "<leader>tt", function() require("snacks").terminal() end, { desc = "Toggle Terminal" })
map("t", "<leader>tt", function() require("snacks").terminal() end, { desc = "Toggle Terminal" })

-- nvimtree
map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })
map("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "nvimtree focus window" })