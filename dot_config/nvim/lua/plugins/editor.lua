return {
    -- session management (auto-save/restore per directory)
    {
        "rmagatti/auto-session",
        lazy = false,
        opts = {
            suppressed_dirs = { "~/", "~/Downloads", "/" },
            bypass_save_filetypes = { "NvimTree", "neo-tree", "terminal" },
            pre_save_cmds = {
                function()
                    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                        local bt = vim.bo[buf].buftype
                        -- Close terminal buffers before saving
                        if bt == "terminal" then
                            vim.api.nvim_buf_delete(buf, { force = true })
                        -- Wipe unnamed empty buffers that get marked modified
                        elseif vim.api.nvim_buf_get_name(buf) == "" and bt == "" then
                            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                            if #lines <= 1 and (lines[1] or "") == "" then
                                vim.api.nvim_buf_delete(buf, { force = true })
                            end
                        end
                    end
                end,
            },
        },
        init = function()
            -- Clear modified flag on unnamed buffers before quit so neo-tree's
            -- close_if_last_window doesn't choke on phantom [No Name] buffers
            vim.api.nvim_create_autocmd("QuitPre", {
                callback = function()
                    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                        if vim.api.nvim_buf_is_valid(buf)
                            and vim.api.nvim_buf_get_name(buf) == ""
                            and vim.bo[buf].buftype == ""
                            and vim.bo[buf].modified
                        then
                            vim.bo[buf].modified = false
                        end
                    end
                end,
            })
            -- Kill standalone Claude CLI processes when leaving nvim
            -- Pattern matches only "claude" or "claude --resume", not Desktop app or VSCode extension
            vim.api.nvim_create_autocmd("VimLeavePre", {
                callback = function()
                    vim.fn.jobstart([[pkill -f '^claude( --resume)?$']], { detach = true })
                end,
            })
        end,
    },
    -- search/replace in multiple files
    {
        "MagicDuck/grug-far.nvim",
        opts = { headerMaxWidth = 80 },
        cmd = { "GrugFar", "GrugFarWithin" },
        keys = {
            {
            "<leader>sr",
            function()
                local grug = require("grug-far")
                local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
                grug.open({
                transient = true,
                prefills = {
                    filesFilter = ext and ext ~= "" and "*." .. ext or nil,
                },
                })
            end,
            mode = { "n", "x" },
            desc = "Search and Replace",
            },
        },
    },
    -- git signs highlights text that has changed since the list git commit, and also lets you interactively stage & unstage hunks in a commit.
    {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {
        signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
        },
        signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        },
        on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
        end

        -- stylua: ignore start
        map("n", "]h", function()
            if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
            else
            gs.nav_hunk("next")
            end
        end, "Next Hunk")
        map("n", "[h", function()
            if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
            else
            gs.nav_hunk("prev")
            end
        end, "Prev Hunk")
        map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
        map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
        map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
        end,
    },
    },
    -- multiple cursors
    {
        "jake-stewart/multicursor.nvim",
        branch = "1.0",
        config = function()
            local mc = require("multicursor-nvim")
            mc.setup()

            local set = vim.keymap.set

            -- Add cursors above/below
            set({"n", "x"}, "<m-down>", function() mc.lineAddCursor(1) end)
            set({"n", "x"}, "<m-up>", function() mc.lineAddCursor(-1) end)
            set({"n", "x"}, "<leader><down>", function() mc.lineSkipCursor(1) end)
            set({"n", "x"}, "<leader><up>", function() mc.lineSkipCursor(-1) end)

            -- Match word/selection forward/backward
            set({"n", "x"}, "<leader>mn", function() mc.matchAddCursor(1) end)
            set({"n", "x"}, "<leader>mN", function() mc.matchAddCursor(-1) end)
            set({"n", "x"}, "<leader>ms", function() mc.matchSkipCursor(1) end)
            set({"n", "x"}, "<leader>mS", function() mc.matchSkipCursor(-1) end)

            -- Mouse support
            set("n", "<c-leftmouse>", mc.handleMouse)
            set("n", "<c-leftdrag>", mc.handleMouseDrag)
            set("n", "<c-leftrelease>", mc.handleMouseRelease)

            -- Toggle cursor under main cursor
            set({"n", "x"}, "<c-q>", mc.toggleCursor)

            -- Keybindings only active when multiple cursors exist
            mc.addKeymapLayer(function(layerSet)
                layerSet({"n", "x"}, "<left>", mc.prevCursor)
                layerSet({"n", "x"}, "<right>", mc.nextCursor)
                layerSet({"n", "x"}, "<leader>mx", mc.deleteCursor)
                layerSet("n", "<esc>", function()
                    if not mc.cursorsEnabled() then
                        mc.enableCursors()
                    else
                        mc.clearCursors()
                    end
                end)
            end)

            -- Highlights
            local hl = vim.api.nvim_set_hl
            hl(0, "MultiCursorCursor", { reverse = true })
            hl(0, "MultiCursorVisual", { link = "Visual" })
            hl(0, "MultiCursorSign", { link = "SignColumn" })
            hl(0, "MultiCursorMatchPreview", { link = "Search" })
            hl(0, "MultiCursorDisabledCursor", { reverse = true })
            hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
            hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
        end,
    },
    -- better diagnostics list and others
    {
  "folke/trouble.nvim",
    cmd = { "Trouble" },
    opts = {
        modes = {
        lsp = {
            win = { position = "right" },
        },
        },
    },
    keys = {
        { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
        { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
        { "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
        { "<leader>cS", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references/definitions/... (Trouble)" },
        { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
        { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
        {
        "[q",
        function()
            if require("trouble").is_open() then
            require("trouble").prev({ skip_groups = true, jump = true })
            else
            local ok, err = pcall(vim.cmd.cprev)
            if not ok then
                vim.notify(err, vim.log.levels.ERROR)
            end
            end
        end,
        desc = "Previous Trouble/Quickfix Item",
        },
        {
        "]q",
        function()
            if require("trouble").is_open() then
            require("trouble").next({ skip_groups = true, jump = true })
            else
            local ok, err = pcall(vim.cmd.cnext)
            if not ok then
                vim.notify(err, vim.log.levels.ERROR)
            end
            end
        end,
        desc = "Next Trouble/Quickfix Item",
        },
    },
    },
    
}