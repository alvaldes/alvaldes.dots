local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- `opts` plus a which-key description.
local function with_desc(desc)
	return vim.tbl_extend("force", opts, { desc = desc })
end

-- Do things without updating the registers
keymap.set("n", "x", '"_x', { desc = "Delete character (keep register)" })
keymap.set("n", "<Leader>p", '"0p', { desc = "Paste last yank after cursor" })
keymap.set("n", "<Leader>P", '"0P', { desc = "Paste last yank before cursor" })
keymap.set("v", "<Leader>p", '"0p', { desc = "Replace selection with last yank" })
keymap.set("n", "<Leader>c", '"_c', { desc = "Change without yanking" })
keymap.set("n", "<Leader>C", '"_C', { desc = "Change to end of line without yanking" })
keymap.set("v", "<Leader>c", '"_c', { desc = "Change selection without yanking" })
keymap.set("v", "<Leader>C", '"_C', { desc = "Change lines without yanking" })
keymap.set("n", "<Leader>d", '"_d', { desc = "Delete without yanking" })
keymap.set("n", "<Leader>D", '"_D', { desc = "Delete to end of line without yanking" })
keymap.set("v", "<Leader>d", '"_d', { desc = "Delete selection without yanking" })
keymap.set("v", "<Leader>D", '"_D', { desc = "Delete lines without yanking" })

-- Increment/decrement
keymap.set("n", "+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "_", "<C-x>", { desc = "Decrement number" })

-- Delete a word backwards
keymap.set("n", "dw", 'vb"_d', { desc = "Delete word backwards (no yank)" })

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G", { desc = "Select all" })

-- Save file
keymap.set("n", "<C-s>", ":w<CR>", with_desc("Save file"))

-- Disable continuations
keymap.set("n", "<Leader>o", "o<Esc>^Da", with_desc("New line below (no comment leader)"))
keymap.set("n", "<Leader>O", "O<Esc>^Da", with_desc("New line above (no comment leader)"))

-- Jumplist navigation (<C-i> is <Tab>, which is taken by :tabnext)
keymap.set("n", "[j", "<C-o>", { noremap = true, silent = true, desc = "Jump back (jumplist)" })
keymap.set("n", "]j", "<C-i>", { noremap = true, silent = true, desc = "Jump forward (jumplist)" })

-- Toggle the fold under the cursor with <CR>. Special buffers (quickfix,
-- help, terminal, cmdwin, ...) keep their native <CR> behavior.
keymap.set("n", "<CR>", function()
	if vim.bo.buftype ~= "" or vim.fn.getcmdwintype() ~= "" then
		return "<CR>"
	end
	if vim.fn.foldlevel(".") == 0 then
		vim.notify("No fold found", vim.log.levels.INFO)
		return ""
	end
	return "za"
end, { expr = true, silent = true, desc = "Toggle fold under cursor" })

-- New tab
keymap.set("n", "te", ":tabedit<CR>", { desc = "New tab" })
keymap.set("n", "<tab>", ":tabnext<CR>", with_desc("Next tab"))
keymap.set("n", "<s-tab>", ":tabprev<CR>", with_desc("Previous tab"))

-- Split window
keymap.set("n", "ss", ":split<Return>", with_desc("Split window horizontally"))
keymap.set("n", "sv", ":vsplit<Return>", with_desc("Split window vertically"))

-- Move window
keymap.set("n", "sh", "<C-w>h", { desc = "Focus window left" })
keymap.set("n", "sk", "<C-w>k", { desc = "Focus window above" })
keymap.set("n", "sj", "<C-w>j", { desc = "Focus window below" })
keymap.set("n", "sl", "<C-w>l", { desc = "Focus window right" })

-- Toggle inlay hints
keymap.set("n", "<leader>i", function()
	local filter = { bufnr = 0 }
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
end, { desc = "Toggle inlay hints (buffer)" })

-- Yank current file path
keymap.set("n", "<leader>yf", function()
	require("alvaldes.utils.editor").yank_relative_path_with_line()
end, { desc = "Copy relative path:line" })

keymap.set("n", "<leader>yp", function()
	require("alvaldes.utils.editor").yank_absolute_path_with_line()
end, { desc = "Copy absolute path:line" })

keymap.set("v", "<leader>cc", ":<C-u>lua require('alvaldes.utils.editor').copy_as_codeblock()<CR>", { desc = "Copy selection as Markdown code block" })

keymap.set("n", "<leader>j", function()
	require("alvaldes.utils.editor").open_package_json()
end, { desc = "Open package.json (float)" })

keymap.set("n", "<leader>bd", function()
	require("alvaldes.utils.editor").delete_hidden_buffers()
end, { desc = "Close buffers not shown in any window" })

-- Spelling (same keys as the old gentle config)
local function set_spelllang(langs, label)
	return function()
		vim.opt_local.spelllang = langs
		vim.notify("Spell language: " .. label)
	end
end
keymap.set("n", "<leader>msle", set_spelllang({ "en" }, "English"), { desc = "Set spell language: English" })
keymap.set("n", "<leader>msls", set_spelllang({ "es" }, "Spanish"), { desc = "Set spell language: Spanish" })
keymap.set("n", "<leader>mslb", set_spelllang({ "en", "es" }, "English + Spanish"), { desc = "Set spell language: English + Spanish" })
keymap.set("n", "<leader>mss", "1z=", { desc = "Fix word with first suggestion" })
keymap.set("n", "<leader>msg", "zg", { desc = "Add word to dictionary" })
keymap.set("n", "<leader>msu", "zug", { desc = "Remove word from dictionary" })
keymap.set("n", "<leader>msr", "<Cmd>spellrepall<CR>", { desc = "Apply last fix to all matches" })
keymap.set("n", "<leader>mst", function()
	vim.opt_local.spell = not vim.opt_local.spell:get()
	vim.notify("Spell checking " .. (vim.opt_local.spell:get() and "on" or "off"))
end, { desc = "Toggle spell check (buffer)" })
