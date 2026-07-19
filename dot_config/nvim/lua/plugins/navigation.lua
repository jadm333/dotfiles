return {
    -- Seamless <C-h/j/k/l> movement across the nvim<->tmux boundary, so the
    -- tmux Claude pane feels like just another window. Pairs with the matching
    -- bindings in dot_config/tmux/tmux.conf. (tmux migration Phase 1.)
    {
        "mrjones2014/smart-splits.nvim",
        keys = {
            { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Go to left window/pane" },
            { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Go to lower window/pane" },
            { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Go to upper window/pane" },
            { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Go to right window/pane" },
        },
        opts = {},
    },
}
