-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Key-sequence timeout. The `;`-prefixed picker keys and `[b`/`]b` are two-key
-- sequences, so a long timeout makes the first key feel slow. 300 ms restores
-- the value that `lua/plugins/which-key.lua` used to set ineffectively, before
-- `init.lua` overwrote it with 1000.
vim.opt.timeoutlen = 300

-- Do not wait for terminal key codes, so <Esc> and friends stay instant.
vim.opt.ttimeoutlen = 0
