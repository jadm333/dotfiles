return {
    {"tris203/precognition.nvim", config = function() require("precognition").setup() end},
    -- Indent blankline
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		---@module "ibl"
		---@type ibl.config
		opts = {},
		config = function()
			local highlight = {
				"RainbowRed",
				"RainbowYellow",
				"RainbowBlue",
				"RainbowOrange",
				"RainbowGreen",
				"RainbowViolet",
				"RainbowCyan",
			}
			local hooks = require("ibl.hooks")
			hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
				vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
				vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
				vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
				vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
				vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
				vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
				vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
			end)
			local ibl = require("ibl")
			ibl.setup({indent = { highlight = highlight } })
		end
	},

    -- Formatting client: conform.nvim
	-- - configured to use black & isort in python
	-- - use the taplo-LSP for formatting in toml
	-- - Formatting is triggered via `<leader>f`, but also automatically on save
	{
		"stevearc/conform.nvim",
		event = "BufWritePre", -- load the plugin before saving
		keys = {
			{
				"<leader>f",
				function() require("conform").format({ lsp_fallback = true }) end,
				desc = "Format",
			},
		},
		opts = {
			formatters_by_ft = {
				-- first use isort and then black
				python = { "isort", "black" },
				-- "inject" is a special formatter from conform.nvim, which
				-- formats treesitter-injected code. Basically, this makes
				-- conform.nvim format python codeblocks inside a markdown file.
				markdown = { "inject" },
			},
			-- enable format-on-save
			format_on_save = {
				-- when no formatter is setup for a filetype, fallback to formatting
				-- via the LSP. This is relevant e.g. for taplo (toml LSP), where the
				-- LSP can handle the formatting for us
				lsp_fallback = true,
			},
		},
	},
    -- REPL
	-- A basic REPL that opens up as a horizontal split
	-- - use `<leader>i` to toggle the REPL
	-- - use `<leader>I` to restart the REPLnvim-cmp
	-- - `+` serves as the "send to REPL" operator. That means we can use `++`
	-- to send the current line to the REPL, and `+j` to send the current and the
	-- following line to the REPL, like we would do with other vim operators.
	{
		"Vigemus/iron.nvim",
		keys = {
			{ "<leader>i", vim.cmd.IronRepl, desc = "󱠤 Toggle REPL" },
			{ "<leader>I", vim.cmd.IronRestart, desc = "󱠤 Restart REPL" },

			-- these keymaps need no right-hand-side, since that is defined by the
			-- plugin config further below
			{ "+", mode = { "n", "x" }, desc = "󱠤 Send-to-REPL Operator" },
			{ "++", desc = "󱠤 Send Line to REPL" },
		},

		-- since irons's setup call is `require("iron.core").setup`, instead of
		-- `require("iron").setup` like other plugins would do, we need to tell
		-- lazy.nvim which module to via the `main` key
		main = "iron.core",

		opts = {
			keymaps = {
				send_line = "++",
				visual_send = "+",
				send_motion = "+",
			},
			config = {
				-- This defines how the repl is opened. Here, we set the REPL window
				-- to open in a horizontal split to the bottom, with a height of 10.
				repl_open_cmd = "horizontal bot 10 split",

				-- This defines which binary to use for the REPL. If `ipython` is
				-- available, it will use `ipython`, otherwise it will use `python3`.
				-- since the python repl does not play well with indents, it's
				-- preferable to use `ipython` or `bypython` here.
				-- (see: https://github.com/Vigemus/iron.nvim/issues/348)
				repl_definition = {
					python = {
						command = function()
							local ipythonAvailable = vim.fn.executable("ipython") == 1
							local binary = ipythonAvailable and "ipython" or "python3"
							return { binary }
						end,
					},
				},
			},
		},
	},

    -- Docstring creation
	-- - quickly create docstrings via `<leader>a`
	{
		"danymat/neogen",
		opts = true,
		keys = {
			{
				"<leader>a",
				function() require("neogen").generate() end,
				desc = "Add Docstring",
			},
		},
	},

    -- f-strings
	-- - auto-convert strings to f-strings when typing `{}` in a string
	-- - also auto-converts f-strings back to regular strings when removing `{}`
	{
		"chrisgrieser/nvim-puppeteer",
		dependencies = "nvim-treesitter/nvim-treesitter",
	},
}