-- This file contains the configuration for disabling specific Neovim plugins.

return {
  {
    -- Plugin: bufferline.nvim
    -- URL: https://github.com/akinsho/bufferline.nvim
    -- Description: A snazzy buffer line (with tabpage integration) for Neovim.
    "akinsho/bufferline.nvim",
    enabled = false, -- Disable this plugin
  },
  -- {
  --   -- Plugin para mejorar la experiencia de edición en Neovim
  --   -- URL: https://github.com/yetone/avante.nvim
  --   -- Description: Este plugin ofrece una serie de mejoras y herramientas para optimizar la edición de texto en Neovim.
  --   "yetone/avante.nvim",
  --   enabled = false,
  -- },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    enabled = false,
  },
  {
    -- Plugin: huez.nvim
    -- URL: https://github.com/vague2k/huez.nvim
    -- Description: A colorscheme picker for Neovim.
    "vague2k/huez.nvim",
    enabled = false,
  },
  -- {
  --   -- Plugin: nvim-cmp
  --   -- URL: https://github.com/hrsh7th/nvim-cmp
  --   -- Description: A completion plugin for neovim coded in Lua
  --   "nvim-cmp",
  --   dependencies = {
  --     "supermaven-inc/supermaven-nvim",
  --     config = function()
  --       require("supermaven-nvim").setup({
  --         keymaps = {
  --           accept_suggestion = "<C-k>",
  --           clear_suggestions = "<C-l>",
  --           accept_word = "<C-j>",
  --         },
  --         -- disable_inline_completion = true to use with cmp and all supermaven as cp source
  --         disable_inline_completion = true,
  --         disable_keymaps = true,
  --       })
  --     end,
  --   },
  --   opts = {
  --     sources = {
  --       { name = "supermaven" },
  --     },
  --   },
  -- },
  -- {
  --   -- Plugin: supermaven-nvim
  -- URL: https://github.com/supermaven-inc/supermaven-nvim
  -- Description: AI code completion plugin for Neovim
  --   "supermaven-inc/supermaven-nvim",
  --   config = function()
  --     require("supermaven-nvim").setup({
  --       keymaps = {
  --         accept_suggestion = "<C-g>",
  --         clear_suggestions = "<C-l>",
  --         accept_word = "<C-j>",
  --       },
  --       -- disable_inline_completion = true to use with cmp and all supermaven as cp source
  --       disable_inline_completion = false,
  --       disable_keymaps = false,
  --     })
  --   end,
  -- },
}
