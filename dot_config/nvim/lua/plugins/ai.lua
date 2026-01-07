return {
    -- Claude Code plugin
    {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },
        config = true,
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

    -- OpenCode plugin
    {
        "NickvanDyke/opencode.nvim",
        dependencies = {
            { "folke/snacks.nvim" },
        },
        config = function()
            vim.g.opencode_opts = {}
            vim.o.autoread = true
        end,
        keys = {
            { "<leader>o", nil, desc = "OpenCode" },
            { "<leader>oc", function() require("opencode").toggle() end, desc = "Toggle OpenCode" },
            { "<leader>oa", function() require("opencode").ask("@this: ", { submit = false }) end, mode = { "n", "x" }, desc = "Ask OpenCode" },
            { "<leader>oA", function() require("opencode").ask("@this: ", { submit = true }) end, mode = { "n", "x" }, desc = "Ask OpenCode (submit)" },
            { "<leader>os", function() require("opencode").select() end, mode = { "n", "x" }, desc = "OpenCode actions" },
        },
    },
}