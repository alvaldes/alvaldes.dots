-- Bufferline: buffers mode, one mental model (decision D4, reverted 2026-09-19).
--
-- The bar lists *buffers* and every bufferline key keeps acting on buffers, so
-- everything is a buffer and nothing has to be remembered as "tab or buffer".
-- `mode = "tabs"` was tried and rolled back (see
-- `odd/tasks/nvim-plugin-cleanup.md`, WU3a): in tabs mode `<S-h>`/`<S-l>` and
-- `[b`/`]b` start moving tabpages while `<leader>bd` still deletes buffers, and
-- the tabs-specific `close_command`/`right_mouse_command` overrides are only
-- correct while the id bufferline passes is a tab number.
--
-- Nothing is overridden from LazyVim's bufferline opts, on purpose: in buffers
-- mode its `close_command` and `right_mouse_command` (`Snacks.bufdelete`) are
-- correct, and so are the pin and group keys. The only addition here is a fast
-- way to cycle the bar entries. Tabpage management stays on LazyVim's
-- `<leader><tab>*` group.
return {
  {
    "akinsho/bufferline.nvim",
    keys = {
      { "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next Buffer" },
      { "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev Buffer" },
    },
  },
}
