return {
    -- Manager for external tools (LSPs, linters, debuggers, formatters)
	-- auto-install of those external tools
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = {
			{ "williamboman/mason.nvim", opts = true },
			{ "williamboman/mason-lspconfig.nvim", opts = true },
		},
		opts = {
			ensure_installed = {
				"pyright", -- LSP for python
				"ruff", -- linter for python (includes flake8, pep8, etc.)
				"debugpy", -- debugger
				"black", -- formatter
				"isort", -- organize imports
				"taplo", -- LSP for toml (for pyproject.toml files)
			},
		},
	},
}