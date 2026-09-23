-- This file contains the configuration for the which-key.nvim plugin in Neovim.
--
-- It is also the single home for the *names and icons* of the `<leader>` groups.
--
-- Why here and not in a plugin's `keys` field: `keys` is lazy.nvim's lazy-load list, and lazy only
-- acts on an entry that has an `rhs`/callback (`lazy/core/handler/keys.lua`, `M:_set`:
-- `if keys.rhs then`). A bare `{ "<leader>o", group = "Obsidian" }` there never reaches which-key, and
-- the group renders nameless and iconless: nameless because which-key falls back to a keymap count
-- when no description was registered (`which-key/lua/which-key/view.lua`,
-- `desc = child_count .. " keymaps"`), and iconless because the icon rules match the description text
-- and nothing matches a name that was never registered.
--
-- `require("which-key").add(...)` does work, but its queue is flushed exactly once, inside which-key's
-- own `setup` (`which-key/config.lua`), so anything added after that is silently dropped and the
-- declaration becomes ordering-dependent. `opts.spec` is applied at setup, so it cannot be lost.
--
-- `opts_extend` appends to LazyVim's own spec instead of replacing it. Without it, LazyVim's groups
-- (buffer, code, debug, file/find, git, ui, diagnostics/quickfix) would lose their names.

return {
  -- Plugin: which-key.nvim
  -- URL: https://github.com/folke/which-key.nvim
  -- Description: A Neovim plugin that displays a popup with possible keybindings of the command you started typing.
  "folke/which-key.nvim",

  event = "VeryLazy", -- Load this plugin on the 'VeryLazy' event

  opts_extend = { "spec" },

  opts = {
    spec = {
      -- Icons are written as `vim.fn.nr2char(<codepoint>)` on purpose: pasting the glyph itself would
      -- put an invisible private-use character in the source. Each codepoint below was checked against
      -- the cmap of IosevkaTerm NF, the font this config runs on.
      {
        mode = { "n", "v" },
        { "<leader>m", group = "markdown", icon = { icon = vim.fn.nr2char(0xE73E), color = "blue" } }, -- nf-dev-markdown
        { "<leader>mf", group = "fold" },
        { "<leader>ms", group = "spell" },
        { "<leader>msl", group = "language" },
      },
      {
        "<leader>o",
        group = "Obsidian",
        icon = { icon = vim.fn.nr2char(0xF219), color = "purple" }, -- nf-fa-diamond
      },
      {
        "<leader>od",
        group = "Daily",
        icon = { icon = vim.fn.nr2char(0xF073), color = "azure" }, -- nf-fa-calendar
      },
      -- No explicit icon here: which-key's own rule `{ pattern = "%f[%a]ai" }` already gives this group
      -- the green robot glyph, and a second definition would only be dead weight.
      { "<leader>a", group = "ai" },
      {
        "<leader>i",
        group = "image",
        icon = { icon = vim.fn.nr2char(0xF03E), color = "cyan" }, -- nf-fa-image
      },
      {
        "<leader>r",
        group = "rename",
        icon = { icon = vim.fn.nr2char(0xF246), color = "yellow" }, -- nf-fa-i-cursor
      },
      {
        "<leader>t",
        group = "Latex",
        icon = { icon = vim.fn.nr2char(0xF1C1), color = "orange" }, -- nf-fa-file-pdf-o
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
      desc = "Buffer Keymaps (which-key)",
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
