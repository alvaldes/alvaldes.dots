-- This file contains the configuration for the which-key.nvim plugin in Neovim.

return {
  -- Plugin: which-key.nvim
  -- URL: https://github.com/folke/which-key.nvim
  -- Description: A Neovim plugin that displays a popup with possible keybindings of the command you started typing.
  "folke/which-key.nvim",

  event = "VeryLazy", -- Load this plugin on the 'VeryLazy' event

  -- Group names and group icons belong in which-key's own `spec`, never in `keys`.
  --
  -- `keys` is lazy.nvim's lazy-load list, and lazy.nvim only acts on an entry that actually has an
  -- `rhs`/callback (`lazy.nvim/lua/lazy/core/handler/keys.lua`, `M:_set`: `if keys.rhs then`). A bare
  -- `{ "<leader>o", group = "Obsidian" }` therefore never reaches which-key, and the group shows up
  -- nameless and iconless: nameless because which-key falls back to a keymap count when no
  -- description was registered (`which-key/lua/which-key/view.lua`, `desc = child_count .. " keymaps"`),
  -- and iconless because the icon rules match the description text and nothing matches a name that
  -- was never registered.
  --
  -- `opts_extend` appends to LazyVim's own spec instead of replacing it.
  opts_extend = { "spec" },

  opts = {
    spec = {
      {
        "<leader>o",
        group = "Obsidian",
        -- nf-fa-diamond, present in IosevkaTerm NF. `nr2char` keeps the codepoint readable in source
        -- instead of pasting an invisible private-use glyph.
        icon = { icon = vim.fn.nr2char(0xF219), color = "purple" },
      },
      {
        "<leader>od",
        group = "Daily",
        -- nf-fa-calendar
        icon = { icon = vim.fn.nr2char(0xF073), color = "azure" },
      },
    },
  },

  keys = {
    {
      -- Keybinding to show which-key popup
      "<leader>?",
      function()
        require("which-key").show({ global = false }) -- Show the which-key popup for local keybindings
      end,
    },
    {
      "<leader>t",
      function()
        -- `show({ group = ... })` is not a filter — `wk.Filter` has no `group` field — so this used to
        -- show the whole global popup. `keys` is the real filter; this now shows the Latex subtree.
        require("which-key").show({ keys = "<leader>t" })
      end,
      desc = "Latex",
    },
  },
}
