return {
    -- Claude Code plugin
    {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },
        opts = {
            terminal = {
                snacks_win_opts = {
                    keys = {
                        nav_h = { "<C-h>", function() vim.cmd("wincmd h") end, mode = "t", desc = "Navigate left" },
                        nav_j = { "<C-j>", function() vim.cmd("wincmd j") end, mode = "t", desc = "Navigate down" },
                        nav_k = { "<C-k>", function() vim.cmd("wincmd k") end, mode = "t", desc = "Navigate up" },
                        nav_l = { "<C-l>", function() vim.cmd("wincmd l") end, mode = "t", desc = "Navigate right" },
                    },
                },
            },
            diff_opts = {
                auto_close_on_accept = true,
                -- vertical_split = true,
                open_in_current_tab = true,
                keep_terminal_focus = true, -- If true, moves focus back to terminal after diff opens
            },
        },
        keys = {
            { "<leader>a", nil, desc = "AI/Claude Code" },
            { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
            { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
            { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
            { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
            { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
            { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
            { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
            {
                "<leader>as",
                "<cmd>ClaudeCodeTreeAdd<cr>",
                desc = "Add file",
                ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
            },
            -- Diff management
            { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
            { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
        },
    },
}