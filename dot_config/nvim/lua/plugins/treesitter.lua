return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		version = false, -- last release is way too old and doesn't work on Windows
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile", "BufWritePre", "VeryLazy" },
		cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
		opts = {
			highlight = { enable = true },
			indent = { enable = true },
			injections = { enable = true },
			ensure_installed = {
				"bash",
				"c",
				"diff",
				"dockerfile",
				"fish",
				"html",
				"javascript",
				"jsdoc",
				"json",
				"jsonc",
				"lua",
				"luadoc",
				"luap",
				"markdown",
				"markdown_inline",
				"ninja",
				"printf",
				"python",
				"query",
				"regex",
				"rst",
				"toml",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"xml",
				"yaml",
			},
		},
		config = function(_, opts)
			require("nvim-treesitter").setup(opts)

			-- Enable treesitter highlighting with injection support
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local ok, parser = pcall(vim.treesitter.get_parser, args.buf)
					if ok and parser then
						vim.treesitter.start(args.buf, parser:lang())
					end
				end,
			})

			-- Check for missing parsers and notify
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local lang = vim.treesitter.language.get_lang(args.match)
					if not lang then
						return
					end

					-- Check if parser is installed
					local ok = pcall(vim.treesitter.language.add, lang)
					if not ok then
						-- Parser not installed, show notification
						if vim.fn.exists(":Snacks") == 2 then
							require("snacks").notifier.notify(
								string.format("Treesitter parser for '%s' is not installed. Run :TSInstall %s", lang, lang),
								"warn",
								{ title = "Treesitter" }
							)
						else
							vim.notify(
								string.format("Treesitter parser for '%s' is not installed. Run :TSInstall %s", lang, lang),
								vim.log.levels.WARN
							)
						end
					end
				end,
			})
		end,
	},
}