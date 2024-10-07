return {
    -- treesitter for syntax highlighting
	-- - auto-installs the parser for python
	{
		"nvim-treesitter/nvim-treesitter",
		-- automatically update the parsers with every new release of treesitter
		build = ":TSUpdate",

		-- since treesitter's setup call is `require("nvim-treesitter.configs").setup`,
		-- instead of `require("nvim-treesitter").setup` like other plugins do, we
		-- need to tell lazy.nvim which module to via the `main` key
		main = "nvim-treesitter.configs",

		opts = {
			highlight = { enable = true }, -- enable treesitter syntax highlighting
			indent = { enable = true }, -- better indentation behavior
			ensure_installed = {
				-- auto-install the Treesitter parser for python and related languages
				"python",
				"toml",
				"rst",
				"ninja",
				"markdown",
				"markdown_inline",
				"fish",
				"json",
				"query",
				"vimdoc",
                "dockerfile",
                "terraform",
                "yaml",
				"lua",
			},
		},
	},
}