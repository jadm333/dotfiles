return {
    {
        "olimorris/onedarkpro.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            -- Semantic tokens must have higher priority than onedarkpro's treesitter (126)
            vim.highlight.priorities.semantic_tokens = 127

            require("onedarkpro").setup({})
            vim.cmd("colorscheme onedark_vivid")

            -- Get theme colors and apply semantic token highlights
            local c = require("onedarkpro.helpers").get_colors()
            local hl = vim.api.nvim_set_hl

            -- Python semantic tokens from pyright
            hl(0, "@lsp.type.parameter.python", { fg = c.orange })
            hl(0, "@lsp.type.variable.python", { fg = c.fg })
            hl(0, "@lsp.type.property.python", { fg = c.cyan })
            hl(0, "@lsp.type.function.python", { fg = c.blue })
            hl(0, "@lsp.type.method.python", { fg = c.blue })
            hl(0, "@lsp.type.class.python", { fg = c.yellow })
            hl(0, "@lsp.type.namespace.python", { fg = c.yellow })
            hl(0, "@lsp.type.decorator.python", { fg = c.purple })
            hl(0, "@lsp.type.typeParameter.python", { fg = c.cyan, italic = true })
            hl(0, "@lsp.type.enum.python", { fg = c.yellow })
            hl(0, "@lsp.type.enumMember.python", { fg = c.orange })

            -- Pyright uses modifiers for self/cls: @lsp.typemod.parameter.definition.python
            hl(0, "@lsp.typemod.parameter.definition.python", { fg = c.red })
        end,
    },
}
