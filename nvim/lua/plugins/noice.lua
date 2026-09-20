-- noice.nvim: message, cmdline and popupmenu UI (WU3c).
--
-- LazyVim already configures noice (one route, `lsp.override` and the
-- `bottom_search` / `command_palette` / `long_message_to_split` presets). This
-- file only adds what we want on top:
--   * drop "No information available" notifications entirely;
--   * `:Noice` history in a split with full details;
--   * apply noice's markdown keymaps inside markdown buffers;
--   * enable the rounded border for `lsp_doc_border`.
--
-- Dropped from the original block: routing notifications to the system notifier
-- while the editor is unfocused. It used `view = "notify_send"`, and noice
-- disables that view unless the `notify-send` binary (libnotify) is available
-- (`NotifySendView:is_available()` -> `vim.fn.executable("notify-send") == 1`),
-- which is not the case on this machine: `View.get_view("notify_send")` returns
-- nil, so the router marks the route `skip = true`
-- (noice/message/router.lua:49-56) and never pushes to it.
--
-- The route was harmless only because the block also set
-- `opts = { stop = false }`. A route that matches still stops the routing chain
-- unless `stop` is explicitly false (noice/message/router.lua:194-207), so a
-- skipped route without `stop = false` would shadow every later route and
-- swallow all notifications on a host without libnotify. On a host with
-- libnotify this route can be re-added as a one-liner. The two
-- `FocusGained`/`FocusLost` autocmds that existed only to feed it were removed
-- with it.
--
-- Only `opts` is set on purpose: adding `config` here would replace LazyVim's
-- config function, which is what calls `require("noice").setup(opts)`.
return {
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      table.insert(opts.routes, {
        filter = {
          event = "notify",
          find = "No information available",
        },
        opts = { skip = true },
      })

      opts.commands = {
        all = {
          -- options for the message history that you get with `:Noice`
          view = "split",
          opts = { enter = true, format = "details" },
          filter = {},
        },
      }

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(event)
          vim.schedule(function()
            require("noice.text.markdown").keys(event.buf)
          end)
        end,
      })

      opts.presets.lsp_doc_border = true
    end,
  },
}
