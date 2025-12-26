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
}