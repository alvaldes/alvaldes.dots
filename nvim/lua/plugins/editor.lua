-- This file contains the configuration for various Neovim plugins related to the editor.

return {
  {
    -- Plugin: goto-preview
    -- URL: https://github.com/rmagatti/goto-preview
    -- Description: Provides preview functionality for definitions, declarations, implementations, type definitions, and references.
    "rmagatti/goto-preview",
    event = "BufEnter", -- Load the plugin when a buffer is entered
    config = true, -- Enable default configuration
    keys = {
      {
        "gpd",
        "<cmd>lua require('goto-preview').goto_preview_definition()<CR>",
        noremap = true, -- Do not allow remapping
        desc = "goto preview definition", -- Description for the keybinding
      },
      {
        "gpD",
        "<cmd>lua require('goto-preview').goto_preview_declaration()<CR>",
        noremap = true,
        desc = "goto preview declaration",
      },
      {
        "gpi",
        "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>",
        noremap = true,
        desc = "goto preview implementation",
      },
      {
        "gpy",
        "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>",
        noremap = true,
        desc = "goto preview type definition",
      },
      {
        "gpr",
        "<cmd>lua require('goto-preview').goto_preview_references()<CR>",
        noremap = true,
        desc = "goto preview references",
      },
      {
        "gP",
        "<cmd>lua require('goto-preview').close_all_win()<CR>",
        noremap = true,
        desc = "close all preview windows",
      },
    },
  },
  {
    -- Plugin: mini.hipatterns
    -- URL: https://github.com/echasnovski/mini.hipatterns
    -- Description: Provides highlighter patterns for various text patterns.
    "nvim-mini/mini.hipatterns",
    event = "BufReadPre", -- Load the plugin before reading a buffer
    opts = {
      highlighters = {
        hsl_color = {
          pattern = "hsl%(%d+,? %d+,? %d+%)", -- Pattern to match HSL color values
          group = function(_, match)
            local utils = require("config.gentleman.utils")
            local h, s, l = match:match("hsl%((%d+),? (%d+),? (%d+)%)")
            h, s, l = tonumber(h), tonumber(s), tonumber(l)
            local hex_color = utils.hslToHex(h, s, l)
            return MiniHipatterns.compute_hex_color_group(hex_color, "bg")
          end,
        },
      },
    },
  },
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>fP",
        function()
          Snacks.picker.files({ cwd = require("lazy.core.config").options.root })
        end,
        desc = "Find Plugin File",
      },
      {
        ";f",
        function()
          Snacks.picker.files({ hidden = true })
        end,
        desc = "Lists files in your current working directory, respects .gitignore",
      },
      {
        ";r",
        function()
          Snacks.picker.grep({ hidden = true })
        end,
        desc = "Search for a string in your current working directory, results update as you type, respects .gitignore",
      },
      {
        "\\\\",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Lists open buffers",
      },
      {
        ";t",
        function()
          Snacks.picker.help()
        end,
        desc = "Lists available help tags and opens a new window with the relevant help info on <cr>",
      },
      {
        ";;",
        function()
          Snacks.picker.resume()
        end,
        desc = "Resume the previous picker",
      },
      {
        ";e",
        function()
          Snacks.picker.diagnostics()
        end,
        desc = "Lists Diagnostics for all open buffers or a specific buffer",
      },
      {
        ";s",
        function()
          Snacks.picker.treesitter()
        end,
        desc = "Lists Function names, variables, from Treesitter",
      },
      {
        "<Leader>sf",
        function()
          Snacks.explorer({ cwd = vim.fn.expand("%:p:h") })
        end,
        desc = "Open File Explorer with the path of the current buffer",
      },
    },
  },
}
