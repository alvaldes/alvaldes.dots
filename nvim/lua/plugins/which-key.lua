-- This file contains the configuration for the which-key.nvim plugin in Neovim.

return {
  -- Plugin: which-key.nvim
  -- URL: https://github.com/folke/which-key.nvim
  -- Description: A Neovim plugin that displays a popup with possible keybindings of the command you started typing.
  "folke/which-key.nvim",

  event = "VeryLazy", -- Load this plugin on the 'VeryLazy' event

  keys = {
    {
      -- Keybinding to show which-key popup
      "<leader>?",
      function()
        require("which-key").show({ global = false }) -- Show the which-key popup for local keybindings
      end,
    },
    {
      -- Define a group for Obsidian-related commands
      "<leader>o",
      group = "Obsidian",
    },
    {
      "<leader>t",
      function()
        require("which-key").show({ group = "Latex" })
      end,
      desc = "Latex",
    },
    {
      -- Daily-notes subgroup of Obsidian; its keymaps live in `lua/config/keymaps.lua`.
      -- Note: `require("which-key").show({ group = ... })` is NOT a group filter — `wk.Filter` has no
      -- `group` field, so that call showed the entire global keymap popup. A `group` declaration is
      -- what actually builds the subgroup.
      "<leader>od",
      group = "Daily",
    },
  },
}
