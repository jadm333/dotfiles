return {
	{
		"marko-cerovac/material.nvim",
		version = "*",
		config = function()
			require("material").setup({
				contrast = {
					sidebars = true, -- Enable contrast for sidebars, such as NvimTree and Telescope
					floating_windows = true, -- Enable contrast for floating windows
				},
				plugins = {
					telescope = true, -- Enable telescope plugin
					nvimtree = true, -- Enable nvim-tree plugin
				},
				
			})
			vim.cmd.colorscheme("material")
		end,
	},
}