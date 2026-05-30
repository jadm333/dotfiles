return {
	{
		"hat0uma/csvview.nvim",
		---@module "csvview"
		---@type CsvView.Options
		opts = {
			parser = { comments = { "#", "//" } },
			keymaps = {
				-- Text objects for selecting fields
				textobject_field_inner = { "if", mode = { "o", "x" } },
				textobject_field_outer = { "af", mode = { "o", "x" } },
				-- Excel-like field/row navigation
				jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
				jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
				jump_next_row = { "<Enter>", mode = { "n", "v" } },
				jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
			},
			view = {
				display_mode = "border",
				header_lnum = true,  -- Auto-detect header (default)
				sticky_header = {
					enabled = true,
					separator = "─",  -- Separator line character
				},
			},
		},
		-- Load (and auto-enable) on CSV/TSV files; commands/keymap allow manual use elsewhere
		ft = { "csv", "tsv" },
		cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
		keys = {
			{ "<leader>cv", "<cmd>CsvViewToggle<cr>", desc = "Toggle CSV view" },
		},
		config = function(_, opts)
			local csvview = require("csvview")
			csvview.setup(opts)
			-- Auto-enable the aligned view whenever a CSV/TSV buffer opens.
			-- lazy.nvim re-fires FileType after loading, so this also catches the
			-- buffer that triggered loading. Guard against re-enabling on :edit.
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("csvview_auto_enable", { clear = true }),
				pattern = { "csv", "tsv" },
				callback = function(args)
					if not csvview.is_enabled(args.buf) then
						csvview.enable(args.buf)
					end
				end,
			})
		end,
	},
}
