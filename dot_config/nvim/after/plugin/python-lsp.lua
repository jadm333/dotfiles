-- Python LSP configuration using Neovim 0.11+ native API
-- Ruff for linting/formatting, ty for type checking
-- Treesitter handles syntax highlighting

-- Get blink.cmp capabilities if available
local capabilities = vim.lsp.protocol.make_client_capabilities()
local has_blink, blink = pcall(require, 'blink.cmp')
if has_blink then
    capabilities = vim.tbl_deep_extend('force', capabilities, blink.get_lsp_capabilities())
end

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
    on_attach = function(client)
        -- Disable hover in favor of ty
        client.server_capabilities.hoverProvider = false
    end,
    settings = {},
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
    settings = {},
}

-- Enable LSP servers for Python
vim.lsp.enable({ "ruff", "ty" })
