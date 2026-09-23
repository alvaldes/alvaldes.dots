--- Keep the vault's descriptive filenames instead of slugifying them.
---
--- The vault contract (`~/Documents/second-brain/AGENTS.md` §3.2) wants a self-sufficient Spanish
--- title as the filename (spaces, capitals, emoji, em dash are all part of the established style) and
--- forbids overwriting an existing note, so a collision gets a ` 2`, ` 3`, … suffix.
---
---@param title string|?
---@param dir obsidian.Path
---@return string
local function vault_note_id(title, dir)
  if type(title) ~= "string" or vim.trim(title) == "" then
    return tostring(os.time())
  end
  local Path = require("obsidian.path")
  local base = vim.trim(title)
  local candidate, idx = base, 2
  while (Path.new(dir) / candidate):with_suffix(".md", true):exists() do
    candidate = string.format("%s %d", base, idx)
    idx = idx + 1
  end
  return candidate
end

-- Obsidian integration for the `second-brain` vault.
--
-- The vault has a human-authored contract (`~/Documents/second-brain/AGENTS.md`) that wins over this
-- plugin's defaults, so this spec follows it instead:
--   * `frontmatter.enabled = false` (§3.3): the vault's `_templates/*` already carry the exact
--     frontmatter (`created`/`type`/`status`/`source`/`tags`). The plugin's default writer injects
--     `id` and `aliases`, re-sorts the keys, and drops the trailing space of empty values, which
--     breaks the template byte-for-byte. Disabled, the template's frontmatter is written verbatim.
--   * `note.template = "Captura"` (§3.3): a note created without an explicit template starts from the
--     vault's capture template. It also keeps the previous point safe, because the plugin discards its
--     *own* default template when frontmatter is off.
--   * `note_id_func = vault_note_id` (§3.2): descriptive filenames, never overwritten.
--   * `00 - Inbox` (§3.2) for new and daily notes, matching the app's `.obsidian/daily-notes.json`.
return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = false, -- the vault is a main workspace: load it unconditionally
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    legacy_commands = false,
    workspaces = {
      {
        name = "SecondBrain",
        path = vim.fn.expand("~/Documents/second-brain"),
      },
    },
    -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', 'mini.pick' or 'snacks.pick'.
    picker = {
      name = "snacks.picker",
    },
    -- New notes land in the vault's capture inbox (§3.2).
    notes_subdir = "00 - Inbox",
    new_notes_location = "notes_subdir",
    note = {
      template = "Captura",
    },
    note_id_func = vault_note_id,
    frontmatter = {
      enabled = false,
    },
    templates = {
      folder = "_templates",
      date_format = "YYYY-MM-DD",
      time_format = "HH:mm",
    },
    daily_notes = {
      enabled = true,
      folder = "00 - Inbox",
      date_format = "YYYY-MM-DD",
    },
  },
}
