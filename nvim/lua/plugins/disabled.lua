-- This file contains the configuration for disabling specific Neovim plugins.

return {
  {
    -- Plugin: bufferline.nvim
    -- URL: https://github.com/akinsho/bufferline.nvim
    -- Description: A snazzy buffer line (with tabpage integration) for Neovim.
    "akinsho/bufferline.nvim",
    enabled = true, -- Disable this plugin
  },
  {
    -- Plugin para mejorar la experiencia de edición en Neovim
    -- URL: https://github.com/yetone/avante.nvim
    -- Description: Este plugin ofrece una serie de mejoras y herramientas para optimizar la edición de texto en Neovim.
    "yetone/avante.nvim",
    enabled = false,
  },
  {
    -- For free enabled = true and set to false every other copilot plugin
    "CopilotC-Nvim/CopilotChat.nvim",
    enabled = false,
  },
  {
    "NickvanDyke/opencode.nvim",
    enabled = true,
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
    enabled = false,
  },
}
