return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		version = false,
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile", "BufWritePre", "VeryLazy" },
		cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
		init = function()
			-- Custom highlight for jinja blocks
			local function set_jinja_hl()
				vim.api.nvim_set_hl(0, "JinjaBlock", { bg = "#53002f" })
				vim.api.nvim_set_hl(0, "@markup.raw.block.jinja", { link = "JinjaBlock" })
				-- Bold delimiters: {{ }} {% %}
				vim.api.nvim_set_hl(0, "@keyword.directive", { fg = "#00ff55", bold = true, italic=true })
			end
			set_jinja_hl()
			vim.api.nvim_create_autocmd("ColorScheme", { callback = set_jinja_hl })

			-- dbt SQL files use jinja filetype for proper syntax highlighting
			vim.filetype.add({
				pattern = {
					[".*/models/.*%.sql"] = "jinja",
					[".*/macros/.*%.sql"] = "jinja",
					[".*/tests/.*%.sql"] = "jinja",
					[".*/snapshots/.*%.sql"] = "jinja",
					[".*/analyses/.*%.sql"] = "jinja",
				},
			})
		end,
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
				"jinja",
				"jsdoc",
				"json",
				"jsonc",
				"lua",
				"luadoc",
				"luap",
				"markdown",
				"markdown_inline",
				"printf",
				"python",
				"query",
				"regex",
				"rst",
				"sql",
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
			-- Main branch stores queries in runtime/ subdirectory
			-- Lazy.nvim only adds plugin root to runtimepath, so add runtime manually
			local ts_runtime = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/runtime"
			if vim.fn.isdirectory(ts_runtime) == 1 then
				vim.opt.runtimepath:append(ts_runtime)
			end

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