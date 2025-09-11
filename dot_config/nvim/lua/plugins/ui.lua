return {
    -- Side bar tree
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("nvim-tree").setup({
				filters = {
					dotfiles = false,
				},
				view = {
					width = 50,
				}
			})
		end,
	},
    -- which key pop up
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "modern",
			triggers = {
    				{ "<auto>", mode = "nixsotcv" }
			}
		},
		keys = {
			{
				"<leader>",
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
		dependencies = { 'nvim-tree/nvim-web-devicons' }
	},
	-- Required by whichkey
	{
    'nvim-telescope/telescope.nvim', tag = '0.1.x',
      dependencies = { 'nvim-lua/plenary.nvim' }
    },

}