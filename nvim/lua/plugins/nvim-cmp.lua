return {
  {
    "hrsh7th/nvim-cmp", -- Complemento principal para autocompletado
    dependencies = {
      "hrsh7th/cmp-buffer", -- Fuente para contenido del buffer
      "hrsh7th/cmp-path", -- Fuente para rutas de archivo
      "hrsh7th/cmp-nvim-lsp", -- Fuente para LSP
      "hrsh7th/cmp-cmdline", -- Fuente para línea de comandos
      "L3MON4D3/LuaSnip", -- Soporte para snippets
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = {
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
}
