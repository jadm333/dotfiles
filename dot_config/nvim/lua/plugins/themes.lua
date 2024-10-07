return {
    -- In neovim, the choice of color schemes is unfortunately not purely
	-- aesthetic – treesitter-based highlighting or newer features like semantic
	-- highlighting are not always supported by a color scheme. It's therefore
	-- recommended to use one of the popular, and actively maintained ones to get
	-- the best syntax highlighting experience:
	-- https://dotfyle.com/neovim/colorscheme/top
	{
		"folke/tokyonight.nvim",
		-- ensure that the color scheme is loaded at the very beginning
		lazy = false,
		priority = 1000,
		-- enable the colorscheme
		config = function() vim.cmd.colorscheme("tokyonight") end,
	},
}