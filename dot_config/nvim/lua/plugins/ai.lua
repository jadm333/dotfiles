-- Phase 1 of the tmux migration (see repo tmux-migration-plan.md):
-- claudecode.nvim only HOSTS the WebSocket server now (terminal.provider =
-- "none"); tmux owns the Claude pane lifecycle. The IDE integration
-- (<leader>as, diffs, file mentions) still travels over the socket and keeps
-- working as long as this nvim stays open.

-- Drive the Claude CLI running in a tmux pane. These shell out to tmux, so
-- nvim must itself be running inside a tmux session.
local claude_pane = nil

local function in_tmux()
    if vim.env.TMUX == nil or vim.env.TMUX == "" then
        vim.notify("Not inside tmux — start nvim within a tmux session", vim.log.levels.WARN)
        return false
    end
    return true
end

local function pane_alive()
    if not claude_pane then
        return false
    end
    local panes = vim.fn.system({ "tmux", "list-panes", "-a", "-F", "#{pane_id}" })
    return panes:find(claude_pane, 1, true) ~= nil
end

-- Split below (portrait monitor: stack panes vertically) and run Claude,
-- remembering the pane id so we can toggle it later.
local function spawn_claude(extra)
    local cmd = "claude --ide"
    if extra then
        cmd = cmd .. " " .. extra
    end
    local out = vim.fn.system({ "tmux", "split-window", "-v", "-P", "-F", "#{pane_id}", cmd })
    claude_pane = vim.trim(out)
end

local function toggle_claude()
    if not in_tmux() then
        return
    end
    if pane_alive() then
        vim.fn.system({ "tmux", "kill-pane", "-t", claude_pane })
        claude_pane = nil
    else
        spawn_claude(nil)
    end
end

local function resume_claude()
    if in_tmux() then
        spawn_claude("--resume")
    end
end

local function continue_claude()
    if in_tmux() then
        spawn_claude("--continue")
    end
end

return {
    -- Claude Code plugin
    {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },
        -- Load eagerly (like flash) instead of lazy-loading on keys. A key-triggered
        -- lazy load uses an `expr` mapping that replays the keys via feedkeys; in
        -- visual mode that replay drops the selection and the trailing `s` of
        -- <leader>as leaks through to flash.nvim's `s`. Loading here makes <leader>as
        -- a real <cmd> mapping, which preserves the visual selection.
        event = "VeryLazy",
        opts = {
            -- Host the WebSocket server only; no in-nvim terminal. tmux renders Claude.
            terminal = { provider = "none" },
            diff_opts = {
                auto_close_on_accept = true,
                -- vertical_split = true,
                open_in_current_tab = false,
                keep_terminal_focus = true, -- If true, moves focus back to terminal after diff opens
            },
        },
        keys = {
            { "<leader>a", nil, desc = "AI/Claude Code" },
            -- Rebound to tmux (was in-nvim terminal management).
            { "<leader>ac", toggle_claude, desc = "Toggle Claude (tmux pane)" },
            { "<leader>ar", resume_claude, desc = "Resume Claude (tmux pane)" },
            { "<leader>aC", continue_claude, desc = "Continue Claude (tmux pane)" },
            { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
            { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
            {
                "<leader>as",
                "<cmd>ClaudeCodeTreeAdd<cr>",
                desc = "Add file",
                ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw", "snacks_picker_list" },
            },
            -- Diff management
            { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
            { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
        },
    },
}
