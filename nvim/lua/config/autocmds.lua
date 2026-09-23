-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Warn once per session about spelling languages whose dictionary is missing.
-- `spelllang` can name languages such as `es` without any `.spl` file being
-- installed (the Spanish dictionary is not vendored in `nvim/spell/`); Vim then
-- silently checks only the languages it does have and the user never learns
-- why corrections look English-only. This guard only reports the problem and
-- the exact fix: it never sets options, never writes files and never downloads
-- anything by itself.
do
  -- Resolved at most once per session: one scan of `runtimepath` for real
  -- dictionaries, `spell/<lang>.<encoding>.spl`. Compiled personal lists
  -- (`*.add.spl`) are not dictionaries and must not satisfy a language.
  local dictionaries = nil
  local notified = {}

  local function spell_dictionaries()
    if dictionaries then
      return dictionaries
    end
    dictionaries = {}
    -- `all = true`: every `spell/*.spl` on the runtimepath counts, not just
    -- the first hit. Never fails: wrapped so an odd `runtimepath` cannot error.
    local ok, files = pcall(vim.api.nvim_get_runtime_file, "spell/*.spl", true)
    if ok and type(files) == "table" then
      for _, file in ipairs(files) do
        local name = vim.fs.basename(file)
        if not name:find("%.add%.") and not name:match("%.add%.spl$") then
          -- `es.utf-8.spl` -> language `es`
          dictionaries[name:match("^[^.]+")] = true
        end
      end
    end
    return dictionaries
  end

  local function check_spell_languages()
    -- Only report when spell checking is actually on, and each language once.
    if not vim.o.spell then
      return
    end
    local available = spell_dictionaries()
    for lang in vim.gsplit(vim.o.spelllang, ",", { plain = true }) do
      lang = vim.trim(lang)
      -- Skip empty entries and file-path entries (`spelllang` accepts paths,
      -- and a path is not the name of a shipped dictionary).
      if lang ~= "" and not lang:find("[/\\]") and not notified[lang] and not available[lang] then
        notified[lang] = true
        vim.notify(
          ("No spell dictionary installed for '%s': spell checking is silently skipping it. Run :set spelllang=%s and answer 'y' to the download prompt."):format(
            lang,
            lang
          ),
          vim.log.levels.WARN
        )
      end
    end
  end

  -- Autocmds load on VeryLazy, after startup has already entered the first
  -- buffer with its final `spelllang`, so check the current state directly.
  check_spell_languages()

  local group = vim.api.nvim_create_augroup("config_spell_guard", { clear = true })
  -- Later buffers and runtime changes via the `<leader>msl*` keymaps.
  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    callback = check_spell_languages,
  })
  vim.api.nvim_create_autocmd("OptionSet", {
    group = group,
    pattern = "spelllang",
    callback = check_spell_languages,
  })
end
