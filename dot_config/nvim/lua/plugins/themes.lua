return {
    -- -------------------------------
    -- {
    -- 'ribru17/bamboo.nvim',
    -- lazy = false,
    -- priority = 1000,
    -- config = function()
    --     require('bamboo').setup {
    --         style = 'multiplex',
    --     }
    --     require('bamboo').load()
    -- end,
    -- },
    -- -------------------------------
    -- {
    --     "folke/tokyonight.nvim",
    --     lazy = false,
    --     priority = 1000,
    --     opts = { style = "moon" },
    --     config = function(_, opts)
    --         require("tokyonight").setup(opts)
    --         vim.cmd.colorscheme("tokyonight-moon")
    --     end,
    -- },
    -- -------------------------------
    -- {
    --     "catppuccin/nvim",
    --     lazy = false,
    --     priority = 1000,
    --     name = "catppuccin",
    --     config = function(_, opts)
    --         require("catppuccin").setup(opts)
    --         vim.cmd.colorscheme("catppuccin")
    --     end,
    --     opts = {
    --         flavour = "frappe",
    --         lsp_styles = {
    --         underlines = {
    --             errors = { "undercurl" },
    --             hints = { "undercurl" },
    --             warnings = { "undercurl" },
    --             information = { "undercurl" },
    --         },
    --         },
    --         integrations = {
    --         aerial = true,
    --         alpha = true,
    --         cmp = true,
    --         dashboard = true,
    --         flash = true,
    --         fzf = true,
    --         grug_far = true,
    --         gitsigns = true,
    --         headlines = true,
    --         illuminate = true,
    --         indent_blankline = { enabled = true },
    --         leap = true,
    --         lsp_trouble = true,
    --         mason = true,
    --         mini = true,
    --         navic = { enabled = true, custom_bg = "lualine" },
    --         neotest = true,
    --         neotree = true,
    --         noice = true,
    --         notify = true,
    --         snacks = true,
    --         telescope = true,
    --         treesitter_context = true,
    --         which_key = true,
    --         },
    --     },
    -- },
    -- -------------------------------
    {
        "scottmckendry/cyberdream.nvim",
        lazy = false,
        priority = 1000,
        config = function(_, opts)
            require("cyberdream").setup(opts)
            vim.cmd.colorscheme("cyberdream")
        end,
        opts = {
            transparent = false,
            -- variant = "auto",
            extensions = {
                default = false,
                blinkcmp = true,
                gitsigns = true,
                grugfar = true,
                indentblankline = true,
                lazy = true,
                mini = true,
                noice = true,
                notify = true,
                snacks = true,
                telescope = true,
                treesitter = true,
                trouble = true,
                whichkey = true,
            },
        },
    }
}
