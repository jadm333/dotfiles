return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
		  require("copilot").setup {}
		end,
		opts = {
			filetypes = { ["*"] = true },
		},
	},
	{
		"zbirenbaum/copilot-cmp",
		config = function ()
			require("copilot_cmp").setup({
				suggestion = { enabled = false },
				panel = { enabled = false },
			  })
		end
	},
    -- Completion via nvim-cmp
	-- - Confirm a completion with `<CR>` (Return)
	-- - select an item with `<Tab>`/`<S-Tab>`
	{
		"hrsh7th/nvim-cmp",
		dependencies = {"hrsh7th/cmp-nvim-lsp", "mtoohey31/cmp-fish"}, -- use suggestions from the LSP
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				-- register the lsp as completion provider
				sources = cmp.config.sources({
					{ name = "copilot" },
					{ name = "nvim_lsp" },
					{ name = "buffer" },
					{ name = 'path' },
					{ name = "fish" , option = { fish_path = "/opt/homebrew/bin/fish" }}
				}),

				-- Define the mappings for the completion. The `fallback()` call
				-- ensures that when there is no suggestion window open, the mapping
				-- falls back to the default behavior (adding indentation).
				mappings = cmp.mapping.preset.insert({
					mapping = {
    						['<C-n>'] = {
								i = function()
									if cmp.visible() then
									cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
									else
									cmp.complete()
									end
								end,
							},
							['<C-p>'] = {
								i = function()
									if cmp.visible() then
									cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
									else
									cmp.complete()
									end
								end,
							},
							['<C-h>'] = {
								i = cmp.mapping.scroll_docs(-4),
							},
							['<C-l>'] = {
								i = cmp.mapping.scroll_docs(4),
							},
							['<C-Enter>'] = {
								i = cmp.mapping.complete(),
							},
							['<C-e>'] = {
								i = cmp.mapping.abort(),
							},
							['<C-y>'] = {
								i = cmp.mapping.confirm({ select = true }),
							},
							['<C-f>'] = {
								i = cmp.mapping.complete({
									config = {
									sources = {
										{ name = 'path' }
									},
									},
								})
							},
							['<Tab>'] = {
								c = function()
									if cmp.visible() then
									cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
									else
									cmp.complete()
									end
								end,
							},
							['<M-Tab>'] = {
								c = function()
									if cmp.visible() then
									cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
									else
									cmp.complete()
									end
								end,
							},
						},
				}),
			})
		end,
	},
}