return {
    {
        -- Python LSP configuration using Neovim 0.11+ native API
        "mason-org/mason.nvim",
        ft = "python",
        config = function()
            -- Configure Ruff LSP for linting and formatting
            vim.lsp.config.ruff = {
                cmd = { "ruff", "server" },
                filetypes = { "python" },
                root_markers = {
                    "pyproject.toml",
                    "setup.py",
                    "setup.cfg",
                    "requirements.txt",
                    "Pipfile",
                    ".git",
                },
                on_attach = function(client, bufnr)
                    -- Disable hover in favor of ty
                    client.server_capabilities.hoverProvider = false
                end,
                settings = {
                    -- Ruff configuration
                    args = {},
                },
            }

            -- Configure ty: Astral's extremely fast Python type checker
            vim.lsp.config.ty = {
                cmd = { "ty", "lsp" },
                filetypes = { "python" },
                root_markers = {
                    "pyproject.toml",
                    "setup.py",
                    "setup.cfg",
                    "requirements.txt",
                    "Pipfile",
                    ".git",
                },
                settings = {
                    -- ty configuration
                    -- See: https://docs.astral.sh/ty/reference/configuration/
                },
            }

            -- Enable both LSP servers for Python
            vim.lsp.enable({ "ruff", "ty" })
        end,
    },
}