return {
    {
        -- Python LSP configuration using Neovim 0.11+ native API
        "mason-org/mason.nvim",
        dependencies = { "saghen/blink.cmp" },
        ft = "python",
        config = function()
            -- Get blink.cmp capabilities if available
            local has_blink, blink = pcall(require, 'blink.cmp')
            local capabilities = has_blink and blink.get_lsp_capabilities() or nil

            -- Get Mason's bin directory
            local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

            -- Configure Ruff LSP for linting and formatting
            vim.lsp.config.ruff = {
                cmd = { mason_bin .. "/ruff", "server" },
                filetypes = { "python" },
                root_markers = {
                    "pyproject.toml",
                    "setup.py",
                    "setup.cfg",
                    "requirements.txt",
                    "Pipfile",
                    ".git",
                },
                capabilities = capabilities,
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
                cmd = { mason_bin .. "/ty", "server" },
                filetypes = { "python" },
                root_markers = {
                    "pyproject.toml",
                    "setup.py",
                    "setup.cfg",
                    "requirements.txt",
                    "Pipfile",
                    ".git",
                },
                capabilities = capabilities,
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