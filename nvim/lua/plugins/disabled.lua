-- Toggle board for plugins that have their own spec elsewhere under
-- `lua/plugins/` — with one exception, `vague2k/huez.nvim`, whose spec in
-- `huez.lua` is commented out, so the entry below is its only live
-- declaration. Each entry sets `enabled`, and that value wins the merge over
-- the plugin's own file:
--   * `enabled = false` parks the plugin: its spec file stays in the repo, ready
--     to be switched back on, but nothing loads;
--   * `enabled = true` marks the plugin currently in use. `true` is Neovim's
--     default, so these entries document intent rather than change behaviour.
--
-- The AI/assistant family is one-at-a-time: exactly one of avante,
-- copilot.lua + CopilotChat, codecompanion or opencode should be enabled here,
-- which is why the large config files of the parked ones are not dead code.

return {
  {
    -- Plugin: bufferline.nvim
    -- URL: https://github.com/akinsho/bufferline.nvim
    -- Description: A snazzy buffer line (with tabpage integration) for Neovim.
    "akinsho/bufferline.nvim",
    enabled = true, -- on by default; listed here to make the state explicit
  },
  -- obsidian.nvim is deliberately NOT listed here. Its own spec declares
  -- `enabled = function() return not vim.g.disable_obsidian end`, and nothing in
  -- this repo ever sets `vim.g.disable_obsidian`, so that function is the value
  -- that wins the merge no matter what this file says — an `enabled = false`
  -- entry here would look like a switch but would not switch anything. To park
  -- Obsidian, remove or change that function in `lua/plugins/obsidian.lua`.
  {
    -- Plugin para mejorar la experiencia de edición en Neovim
    -- URL: https://github.com/yetone/avante.nvim
    -- Description: Este plugin ofrece una serie de mejoras y herramientas para optimizar la edición de texto en Neovim.
    "yetone/avante.nvim",
    enabled = false,
  },
  {
    -- CopilotChat: part of the mutually exclusive AI family (see the header)
    "CopilotC-Nvim/CopilotChat.nvim",
    enabled = false,
  },
  {
    "zbirenbaum/copilot.lua",
    enabled = false,
  },
  {
    "NickvanDyke/opencode.nvim",
    enabled = true, -- the AI family member currently in use
  },
  {
    "olimorris/codecompanion.nvim",
    enabled = false,
  },
  {
    "tris203/precognition.nvim",
    enabled = false,
  },

  {
    "sphamba/smear-cursor.nvim",
    enabled = false,
  },
  {
    -- Plugin: claude-code.nvim
    -- URL: https://github.com/greggh/claude-code.nvim
    -- Description: Neovim integration for Claude Code AI assistant
    "coder/claudecode.nvim",
    enabled = false,
  },
  {
    -- Plugin: huez.nvim
    -- URL: https://github.com/vague2k/huez.nvim
    -- Description: A colorscheme picker for Neovim.
    "vague2k/huez.nvim",
    enabled = false, -- parked; the only live declaration of this plugin (huez.lua is commented out)
  },
}
