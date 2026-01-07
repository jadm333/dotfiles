return {
    {
        "mason-org/mason.nvim",
        opts = {
            ensure_installed = {
                "ruff",
                "ty",
            },
        },
    },
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = {
            "mason-org/mason.nvim",
        },
        opts = {
            ensure_installed = {
                "ruff",
                "ty",
            },
        },
    },
    {
        "saghen/blink.cmp",
        version = "1.*",
        opts = {
            keymap = {
                preset = "default",
                ["<Tab>"] = { "select_next", "fallback" },
                ["<S-Tab>"] = { "select_prev", "fallback" },
                ["<CR>"] = { "accept", "fallback" },
                ["<C-k>"] = { "show_documentation", "hide_documentation" },
            },
            appearance = {
                use_nvim_cmp_as_default = true,
                nerd_font_variant = "mono",
            },
            completion = {
                menu = {
                    draw = {
                        columns = {
                            { "kind_icon" },
                            { "label", "label_description", gap = 1 },
                            { "source_name" },
                        },
                    },
                },
            },
            sources = {
                default = { "lsp", "path", "buffer" },
            },
        },
        opts_extend = { "sources.default" },
    },
}