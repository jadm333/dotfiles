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
                open_in_current_tab = false,
                keep_terminal_focus = true, -- If true, moves focus back to terminal after diff opens
            },
        },
        keys = {
            { "<leader>a", nil, desc = "AI/Claude Code" },
            { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
            { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
            { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
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
    -- Codex (OpenAI) plugin
    {
        "command-z-z/codex.nvim",
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
                keep_terminal_focus = true,
                hunk_level_review = true,
            },
        },
        keys = {
            { "<leader>o", nil, desc = "AI/Codex" },
            { "<leader>oc", "<cmd>Codex<cr>", desc = "Toggle Codex" },
            { "<leader>or", "<cmd>Codex --resume<cr>", desc = "Resume Codex" },
            { "<leader>oC", "<cmd>Codex --continue<cr>", desc = "Continue Codex" },
            { "<leader>ob", "<cmd>CodexAdd<cr>", desc = "Add current buffer" },
            { "<leader>os", "<cmd>CodexSend<cr>", mode = "v", desc = "Send to Codex" },
            {
                "<leader>os",
                "<cmd>CodexAdd<cr>",
                desc = "Add file",
                ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
            },
            -- Diff management
            { "<leader>oa", "<cmd>CodexDiffAccept<cr>", desc = "Accept diff" },
            { "<leader>od", "<cmd>CodexDiffDeny<cr>", desc = "Deny diff" },
        },
    },
}