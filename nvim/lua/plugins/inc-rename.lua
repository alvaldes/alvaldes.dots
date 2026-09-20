-- Incremental LSP rename with live preview.
--
-- `<leader>cr` (LSP rename, gated by `has = "rename"`) is provided by
-- lazyvim.plugins.extras.editor.inc-rename, which also enables the noice.nvim
-- `inc_rename` preset. This file adds a direct keymap for renaming the word
-- under the cursor without depending on the buffer having a rename provider.
return {
  "smjonas/inc-rename.nvim",
  cmd = "IncRename",
  -- stylua: ignore
  keys = {
    {
      "<leader>rn",
      function()
        local inc_rename = require("inc_rename")
        return ":" .. inc_rename.config.cmd_name .. " " .. vim.fn.expand("<cword>")
      end,
      expr = true,
      desc = "Rename (incremental)",
    },
  },
  opts = {},
}
