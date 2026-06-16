return {
    -- Side bar tree (neo-tree)
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		lazy = false,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("neo-tree").setup({
				close_if_last_window = true,
				-- event_handlers = {
				-- 	{
				-- 		event = "neo_tree_buffer_enter",
				-- 		handler = function()
				-- 			vim.opt.guicursor = "a:Cursor/lCursor"
				-- 			vim.cmd("hi Cursor blend=100")
				-- 		end,
				-- 	},
				-- 	{
				-- 		event = "neo_tree_buffer_leave",
				-- 		handler = function()
				-- 			vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"
				-- 			vim.cmd("hi Cursor blend=0")
				-- 		end,
				-- 	},
				-- },
				filesystem = {
					filtered_items = {
						visible = true,
						hide_dotfiles = false,
						hide_gitignored = false,
						never_show = { ".git" },
					},
					follow_current_file = {
						enabled = true,
					},
					use_libuv_file_watcher = true,
				},
				window = {
					width = 36,
					mappings = {
						-- Stop the mouse from starting visual mode on a click-drag
						["<LeftDrag>"] = "noop",
						["<LeftRelease>"] = "noop",
						["<space>"] = "toggle_node",
						["y"] = function(state)
							local node = state.tree:get_node()
							local name = node.name
							vim.fn.setreg("+", name)
							vim.notify("Copied: " .. name)
						end,
						["Y"] = function(state)
							local node = state.tree:get_node()
							local path = vim.fn.fnamemodify(node:get_id(), ":.")
							vim.fn.setreg("+", path)
							vim.notify("Copied: " .. path)
						end,
						["gy"] = function(state)
							local node = state.tree:get_node()
							local path = node:get_id()
							vim.fn.setreg("+", path)
							vim.notify("Copied: " .. path)
						end,
						["Z"] = function(state)
							-- Toggle between expand all and collapse all
							local expanded = state.expanded or false
							if expanded then
								require("neo-tree.sources.filesystem.commands").close_all_nodes(state)
								state.expanded = false
							else
								require("neo-tree.sources.filesystem.commands").expand_all_nodes(state)
								state.expanded = true
							end
						end,
						["w"] = function()
							-- Toggle between 15% and 40% of screen width
							local current_width = vim.api.nvim_win_get_width(0)
							local screen_width = vim.o.columns
							local small = math.floor(screen_width * 0.15)
							local large = math.floor(screen_width * 0.60)
							if current_width < (small + large) / 2 then
								vim.cmd("vertical resize " .. large)
							else
								vim.cmd("vertical resize " .. small)
							end
						end,
					},
				},
				default_component_configs = {
					container = {
						enable_character_fade = true,
						right_padding = 1,
					},
					file_size = {
						enabled = true,
						required_width = 60,
					},
					type = {
						enabled = true,
						required_width = 70,
					},
					last_modified = {
						enabled = true,
						required_width = 100,
					},
					git_status = {
						symbols = {
							added = "",
							modified = "󰏫",
							deleted = "󰧧",
							renamed = "",
							untracked = "",
							ignored = "",
							unstaged = "",
							staged = "",
							conflict = "",
						},
					},
				},
				source_selector = {
					winbar = true,
					sources = {
						{ source = "filesystem", display_name = " Files" },
						{ source = "buffers", display_name = " Buffers" },
						{ source = "git_status", display_name = " Git" },
					},
				},
			})
			vim.api.nvim_set_hl(0, 'NeoTreeGitIgnored', { fg = '#cb7ff2', italic = true })
		end,
	},
    -- which key pop up
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "modern",
		},
		keys = {
			{
				"<leader>",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
			{
				"<localleader>",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
		},
	},
	-- Bottom bar
	{
		'nvim-lualine/lualine.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons', 'folke/snacks.nvim' },
		event = "VeryLazy",
		init = function()
			vim.g.lualine_laststatus = vim.o.laststatus
			if vim.fn.argc(-1) > 0 then
				-- set an empty statusline till lualine loads
				vim.o.statusline = " "
			else
				-- hide the statusline on the starter page
				vim.o.laststatus = 0
			end
		end,
		opts = function()
			-- PERF: we don't need this lualine require madness 🤷
			local lualine_require = require("lualine_require")
			lualine_require.require = require

			local icons = {
				diagnostics = {
					Error = " ",
					Warn = " ",
					Info = " ",
					Hint = " ",
				},
				git = {
					added = " ",
					modified = " ",
					removed = " ",
				},
			}

			vim.o.laststatus = vim.g.lualine_laststatus

			local opts = {
			options = {
				theme = "powerline_dark",
				globalstatus = vim.o.laststatus == 3,
				disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch" },

				lualine_c = {
					{
						"diagnostics",
						symbols = {
							error = icons.diagnostics.Error,
							warn = icons.diagnostics.Warn,
							info = icons.diagnostics.Info,
							hint = icons.diagnostics.Hint,
						},
					},
					{"encoding"},
					{ "filetype", icon_only = false, separator = "", padding = { left = 1, right = 0 } },
					{ "filename", path = 1 },
				},
				lualine_x = {
					-- Snacks.profiler.status(),
					-- stylua: ignore
					{
						function() return require("noice").api.status.command.get() end,
						cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
						color = function() return { fg = Snacks.util.color("Statement") } end,
					},
					-- stylua: ignore
					{
						function() return require("noice").api.status.mode.get() end,
						cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
						color = function() return { fg = Snacks.util.color("Constant") } end,
					},
					-- stylua: ignore
					{
						require("lazy.status").updates,
						cond = require("lazy.status").has_updates,
						color = function() return { fg = Snacks.util.color("Special") } end,
					},
					{
						"diff",
						symbols = {
							added = icons.git.added,
							modified = icons.git.modified,
							removed = icons.git.removed,
						},
						source = function()
							local gitsigns = vim.b.gitsigns_status_dict
							if gitsigns then
								return {
								added = gitsigns.added,
								modified = gitsigns.changed,
								removed = gitsigns.removed,
								}
							end
						end,
					},
				},
				lualine_y = {
					{ "progress", separator = " ", padding = { left = 1, right = 0 } },
					{ "location", padding = { left = 0, right = 1 } },
					{"lsp_status"}
				},
				lualine_z = {
					function()
						return " " .. os.date("%R")
					end,
				},
			},
			extensions = { "neo-tree", "lazy", "fzf" },
			}

			-- do not add trouble symbols if aerial is enabled
			-- And allow it to be overriden for some buffer types (see autocmds)
			if vim.g.trouble_lualine and pcall(require, "trouble") then
			local trouble = require("trouble")
			local symbols = trouble.statusline({
				mode = "symbols",
				groups = {},
				title = false,
				filter = { range = true },
				format = "{kind_icon}{symbol.name:Normal}",
				hl_group = "lualine_c_normal",
			})
			table.insert(opts.sections.lualine_c, {
				symbols and symbols.get,
				cond = function()
				return vim.b.trouble_lualine ~= false and symbols.has()
				end,
			})
			end

			return opts
		end,
	},
	-- Required by whichkey
	{
		'nvim-telescope/telescope.nvim',
		dependencies = { 'nvim-lua/plenary.nvim' },
		config = function()
			require('telescope').setup({
				defaults = {
					layout_strategy = "horizontal",
					layout_config = {
						horizontal = {
							prompt_position = "top",
							preview_width = 0.55,
						},
						width = 0.87,
						height = 0.80,
					},
					path_display = { "smart" },
					sorting_strategy = "ascending",
					file_ignore_patterns = { ".git/" },
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"--hidden",
					},
					preview = {
						wrap = true,
					},
					set_env = {
						["COLORTERM"] = "truecolor",
					},
				},
			})

			-- Set line numbers and wrap in preview window
			vim.api.nvim_create_autocmd("User", {
				pattern = "TelescopePreviewerLoaded",
				callback = function()
					vim.wo.number = true
					vim.wo.wrap = true
				end,
			})
		end,
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
			{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
			{ "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
			{
				"<leader>fc",
				function()
					local actions = require("telescope.actions")
					require("telescope.builtin").live_grep({
						prompt_title = "Cheatsheet",
						search_dirs = { vim.fn.stdpath("config") .. "/cheatsheet.md" },
						default_text = "",
						attach_mappings = function(prompt_bufnr, map)
							local close_only = function()
								actions.close(prompt_bufnr)
							end
							map("i", "<CR>", close_only)
							map("n", "<CR>", close_only)
							map("i", "<C-x>", close_only)
							map("n", "<C-x>", close_only)
							map("i", "<C-v>", close_only)
							map("n", "<C-v>", close_only)
							map("i", "<C-t>", close_only)
							map("n", "<C-t>", close_only)
							return true
						end,
					})
				end,
				desc = "Cheatsheet",
			},
		},
	},
	-- Top buffer (oipen files)
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		dependencies = { "folke/snacks.nvim" },
		keys = {
			{ "gb", "<Cmd>BufferLinePick<CR>", desc = "Pick Buffer" },
			{ "gD", "<Cmd>BufferLinePickClose<CR>", desc = "Pick Buffer to Close" },
		},
		opts = {
			options = {
				separator_style="padded_slant",
				indicator="underline",
				pick = {
					alphabet = "abcdefghijklmopqrstuvwxyz1234567890"
				},
				-- stylua: ignore
				close_command = function(n) Snacks.bufdelete(n) end,
				-- stylua: ignore
				right_mouse_command = function(n) Snacks.bufdelete(n) end,
				diagnostics = "nvim_lsp",
				always_show_bufferline = false,
				-- Filter out terminal buffers (like  lazygit, etc.)
				custom_filter = function(buf_number)
					local buftype = vim.bo[buf_number].buftype
					local filetype = vim.bo[buf_number].filetype
					-- Exclude terminal buffers
					if buftype == "terminal" then
						return false
					end
					return true
				end,
				name_formatter = function(buf)
					return vim.fn.fnamemodify(buf.name, ':t')
				end,
				diagnostics_indicator = function(_, _, diag)
					local icons = {
						Error = " ",
						Warn = " ",
					}
					local ret = (diag.error and icons.Error .. diag.error .. " " or "")
					.. (diag.warning and icons.Warn .. diag.warning or "")
					return vim.trim(ret)
				end,
				offsets = {
					{
						filetype = "NvimTree",
						text = "File Explorer",
						highlight = "Directory",
						text_align = "left",
					},
					{
						filetype = "neo-tree",
						text = "Neo-tree",
						highlight = "Directory",
						text_align = "left",
					},
				},
				---@param opts bufferline.IconFetcherOpts
				get_element_icon = function(opts)
					-- Use mini.icons if available
					if pcall(require, "mini.icons") then
						return require("mini.icons").get("filetype", opts.filetype)
					end
					return nil
				end,
			},
		},
		config = function(_, opts)
			local fill = "#000000" -- bar background
			local inactive = "#1e1547" -- inactive tabs
			local selected = "#3b4ca4" -- active tab

			local highlights = {
				fill = { bg = fill },
				trunc_marker = { bg = fill },
				-- slant separators are drawn with the fill color on top of the tab color
				separator = { fg = fill, bg = inactive },
				separator_visible = { fg = fill, bg = inactive },
				separator_selected = { fg = fill, bg = selected },
				indicator_visible = { bg = inactive },
				indicator_selected = { bg = selected },
			}
			-- every element drawn inside a tab needs that tab's background,
			-- otherwise it keeps the colorscheme default and shows as a patch
			for _, name in ipairs({
				"buffer", "close_button", "modified", "duplicate", "pick", "numbers",
				"diagnostic", "error", "error_diagnostic", "warning", "warning_diagnostic",
				"info", "info_diagnostic", "hint", "hint_diagnostic",
			}) do
				highlights[name == "buffer" and "background" or name] = { bg = inactive }
				highlights[name .. "_visible"] = { bg = inactive }
				highlights[name .. "_selected"] = { bg = selected }
			end
			opts.highlights = highlights

			require("bufferline").setup(opts)
			-- Fix bufferline when restoring a session
			vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
			callback = function()
				vim.schedule(function()
				pcall(nvim_bufferline)
				end)
			end,
			})
		end,
	},

	-- Highly experimental plugin that completely replaces the UI for messages, cmdline and the popupmenu.
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		opts = {
			lsp = {
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true,
			},
			},
			routes = {
			{
				filter = {
				event = "msg_show",
				any = {
					{ find = "%d+L, %d+B" },
					{ find = "; after #%d+" },
					{ find = "; before #%d+" },
				},
				},
				view = "mini",
			},
			},
			presets = {
			bottom_search = true,
			command_palette = true,
			long_message_to_split = true,
			},
		},
		-- stylua: ignore
		keys = {
			{ "<leader>sn", "", desc = "+noice"},
			{ "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
			{ "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
			{ "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History" },
			{ "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All" },
			{ "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
			{ "<leader>snt", function() require("noice").cmd("pick") end, desc = "Noice Picker (Telescope/FzfLua)" },
			{ "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll Forward", mode = {"i", "n", "s"} },
			{ "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll Backward", mode = {"i", "n", "s"}},
		},
		config = function(_, opts)
			-- HACK: noice shows messages from before it was enabled,
			-- but this is not ideal when Lazy is installing plugins,
			-- so clear the messages in this case.
			if vim.o.filetype == "lazy" then
			vim.cmd([[messages clear]])
			end
			require("noice").setup(opts)
		end,
	},
	-- Icons
	{
		"nvim-mini/mini.icons",
		lazy = true,
		opts = {
			file = {
			[".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
			["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
			},
			filetype = {
			dotenv = { glyph = "", hl = "MiniIconsYellow" },
			},
		},
		init = function()
			package.preload["nvim-web-devicons"] = function()
			require("mini.icons").mock_nvim_web_devicons()
			return package.loaded["nvim-web-devicons"]
			end
		end,
	},
	-- Small utilities
	{
		"folke/snacks.nvim",
		opts = function()
			return {
				indent = { enabled = true },
				input = { enabled = true },
				notifier = { enabled = true },
				picker = { enabled = true },
				scope = { enabled = true },
				-- scroll = { enabled = true },
				statuscolumn = { enabled = false }, -- we set this in options.lua
				bigfile = { enabled = true, size = 10 * 1024 * 1024 },
				quickfile = { enabled = true },
				-- cursor = { enable = false },
				terminal = { enabled = false },
				lazygit = {
					enabled = true,
					win = {
						style = "lazygit",
						width = 0.95,  -- 90% of screen width
						height = 0.95, -- 90% of screen height
					},
				},
			}
		end,
		-- stylua: ignore
		keys = {
			{ "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
			{ "<leader>n", function()
			if Snacks.config.picker and Snacks.config.picker.enabled then
				Snacks.picker.notifications()
			else
				Snacks.notifier.show_history()
			end
			end, desc = "Notification History" },
			{ "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
		},
	},
	{
		"sphamba/smear-cursor.nvim",
		event = "VeryLazy",
		cond = vim.g.neovide == nil,
		opts = {
			hide_target_hack = true,
			cursor_color = "none",
		},
		specs = {
			-- disable mini.animate cursor
			{
			"nvim-mini/mini.animate",
			optional = true,
			opts = {
				cursor = { enable = false },
			},
			},
		},
	},
	-- nvim-scrollview removed: caused redraw flicker that looked like neo-tree
	-- closing/reopening on every cursor movement
	-- Smooth scrolling
	{
		"karb94/neoscroll.nvim",
		event = "VeryLazy",
		opts = {
			respect_scrolloff = true,   -- Stop scrolling when the cursor reaches the scrolloff margin of the file
  			cursor_scrolls_alone = false, -- The cursor will keep on scrolling even if the window cannot scroll further
		},
	},
}