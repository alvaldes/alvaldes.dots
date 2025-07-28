-- This file contains custom key mappings for Neovim.

-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local keymap = vim.keymap

-- Do things without affecting the registers
keymap.set("n", "x", '"_x')

-- Increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- Position cursor at the middle of the screen after scrolling half page
keymap.set("n", "<C-d>", "<C-d>zz") -- Scroll down half a page and center the cursor
keymap.set("n", "<C-u>", "<C-u>zz") -- Scroll up half a page and center the cursor

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- Position cursor at the middle of the screen after moving
-- keymap.set("n", "j", "jzz") -- Move cursor down and center the screen
-- keymap.set("n", "k", "kzz") -- Move cursor up and center the screen

-- Position cursor at the middle of the screen after searching
-- keymap.set("n", "n", "nzz") -- Keep cursor in the middle when searching forward
-- keymap.set("n", "N", "Nzz") -- Keep cursor in the middle when searching backward

-- Map Ctrl+b in insert mode to delete to the end of the word without leaving insert mode
keymap.set("i", "<C-b>", "<C-o>de")

-- Map Ctrl+c to escape from other modes
keymap.set({ "i", "n", "v" }, "<C-c>", [[<C-\><C-n>]])

-- Move lines up and down in visual mode
keymap.set("v", "J", ":move '>+1<CR>gv=gv", { desc = "Move line down in visual mode" })
keymap.set("v", "K", ":move '<-2<CR>gv=gv", { desc = "Move line up in visual mode" })

-- When you do joins with J it will keep your cursor at the beginning instead of at the end
keymap.set("n", "J", "mzJ`z")

----- BufferLine -----
-- keymap.set("n", "<TAB>", "<CMD>BufferLineCycleNext<CR>", { desc = "Next buffer" })
-- keymap.set("n", "<S-TAB>", "<CMD>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })

----- Tmux Navigation ------
-- local nvim_tmux_nav = require("nvim-tmux-navigation")
-- Jump to previous definition and center the cursor
-- keymap.set("n", "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft) -- Navigate to the left pane
-- keymap.set("n", "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown) -- Navigate to the bottom pane
-- keymap.set("n", "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp) -- Navigate to the top pane
-- keymap.set("n", "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight) -- Navigate to the right pane
-- keymap.set("n", "<C-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive) -- Navigate to the last active pane
-- keymap.set("n", "<C-Space>", nvim_tmux_nav.NvimTmuxNavigateNext) -- Navigate to the next pane

-- REQUIRED
local harpoon = require("harpoon")
harpoon:setup()
-- REQUIRED

-- Set keybindings for VimTeX (these are just examples)
keymap.set("n", "<leader>tl", "<cmd>VimtexCompile<CR>", { desc = "Start compiling LaTeX" })
keymap.set("n", "<leader>tv", "<cmd>VimtexView<CR>", { desc = "View compiled PDF" })
keymap.set("n", "<leader>tk", "<cmd>VimtexStop<CR>", { desc = "Stop LaTeX compilation" })
keymap.set("n", "<leader>q", ":!zathura <C-r ≥ expand ('%:r') <cr> - pdf &<cr>", { desc = "Open Zathura" })

----- OBSIDIAN -----
keymap.set(
  "n",
  "<leader>oc",
  "<cmd>lua require('obsidian').util.toggle_checkbox()<CR>",
  { desc = "Obsidian Check Checkbox" }
)
keymap.set("n", "<leader>ot", "<cmd>ObsidianTemplate<CR>", { desc = "Insert Obsidian Template" })
keymap.set("n", "<leader>oo", "<cmd>Obsidian open<CR>", { desc = "Open in Obsidian App" })
keymap.set("n", "<leader>ob", "<cmd>ObsidianBacklinks<CR>", { desc = "Show ObsidianBacklinks" })
keymap.set("n", "<leader>ol", "<cmd>ObsidianLinks<CR>", { desc = "Show ObsidianLinks" })
keymap.set("n", "<leader>on", "<cmd>ObsidianNew<CR>", { desc = "Create New Note" })
keymap.set("n", "<leader>odl", "<cmd>ObsidianDailies<CR>", { desc = "List Dailies" })
keymap.set("n", "<leader>odt", "<cmd>ObsidianToday<CR>", { desc = "Create/Open Today Daily Note" })
keymap.set("n", "<leader>odm", "<cmd>ObsidianTomorrow<CR>", { desc = "Create/Open Tomorrow Daily Note" })
keymap.set("n", "<leader>ody", "<cmd>ObsidianYesterday<CR>", { desc = "Create/Open Yesterday Daily Note" })
keymap.set("n", "<leader>os", "<cmd>ObsidianSearch<CR>", { desc = "Search Obsidian" })
keymap.set("n", "<leader>oq", "<cmd>ObsidianQuickSwitch<CR>", { desc = "Quick Switch" })

-----  OIL -----
keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- Delete all buffers but the current one --
keymap.set(
  "n",
  "<leader>bq",
  '<Esc>:%bdelete|edit #|normal`"<Return>',
  { desc = "Delete other buffers but the current one" }
)

----- mark -----
-- To add a mark (localy), press `m` followed by a letter (a-z)
-- To add a mark (that persist when chage of files), press `m` followed by a letter (A-Z)
-- To go to a mark, press `'` followed by the letter of the mark
-- To see all marks press <leader>sm
-- To delete a mark press <leader>dm

-- Función para eliminar una marca específica
local function delete_mark(mark)
  vim.cmd("delmark " .. mark)
end

-- Keymap para eliminar una marca
keymap.set("n", "<leader>dm", function()
  local mark = vim.fn.input("Enter mark to delete: ")
  delete_mark(mark)
end, { noremap = true, silent = true, desc = "Delete mark" })

----- HARPOON 2 -----
keymap.set("n", "<leader>M", function()
  harpoon:list():add()
end, { desc = "Add harpoon mark" })

keymap.set("n", "<C-e>", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end)

-- keymap.set("n", "<C-H>", function()
--   harpoon:list():select(1)
-- end)
--
-- keymap.set("n", "<C-J>", function()
--   harpoon:list():select(2)
-- end)
--
-- keymap.set("n", "<C-K>", function()
--   harpoon:list():select(3)
-- end)
--
-- keymap.set("n", "<C-L>", function()
--   harpoon:list():select(4)
-- end)

-- Disable key mappings in insert mode
vim.api.nvim_set_keymap("i", "<A-j>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<A-k>", "<Nop>", { noremap = true, silent = true })

-- Disable key mappings in normal mode
vim.api.nvim_set_keymap("n", "<A-j>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-k>", "<Nop>", { noremap = true, silent = true })

-- Disable key mappings in visual block mode
vim.api.nvim_set_keymap("x", "<A-j>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("x", "<A-k>", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("x", "J", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("x", "K", "<Nop>", { noremap = true, silent = true })

-- Open current file in finder
keymap.set("n", "<leader>fO", function()
  local file_path = vim.fn.expand("%:p")
  if file_path ~= "" then
    local command = "open -R " .. vim.fn.shellescape(file_path)
    vim.fn.system(command)
    print("Opened file in Finder: " .. file_path)
  else
    print("No file is currently open")
  end
end, { desc = "Open current file in Finder" })

-- Redefine Ctrl+s to save with the custom function
vim.api.nvim_set_keymap("n", "<C-s>", ":lua SaveFile()<CR>", { noremap = true, silent = true })

-- Custom save function
function SaveFile()
  -- Check if a buffer with a file is open
  if vim.fn.empty(vim.fn.expand("%:t")) == 1 then
    vim.notify("No file to save", vim.log.levels.WARN)
    return
  end

  local filename = vim.fn.expand("%:t") -- Get only the filename
  local success, err = pcall(function()
    vim.cmd("silent! write") -- Try to save the file without showing the default message
  end)

  if success then
    vim.notify(filename .. " Saved!") -- Show only the custom message if successful
  else
    vim.notify("Error: " .. err, vim.log.levels.ERROR) -- Show the error message if it fails
  end
end

-- ############################################################################
-- Begin of markdown section
-- ############################################################################

-- Mappings for creating new groups that don't exist
-- When I press leader, I want to modify the name of the options shown
-- "m" is for "markdown" and "t" is for "todo"
-- https://github.com/folke/which-key.nvim?tab=readme-ov-file#%EF%B8%8F-mappings
local wk = require("which-key")
wk.add({
  {
    mode = { "n", "v" },
    { "<leader>m", group = "markdown" },
    { "<leader>mf", group = "fold" },
    { "<leader>ms", group = "spell" },
    { "<leader>msl", group = "language" },
  },
})

-- Open the current file in the browser
keymap.set("n", "<leader>fo", function()
  local file = vim.fn.expand("%:p") -- Obtener ruta absoluta del archivo actual

  local cmd
  cmd = "open -a 'zen' " .. vim.fn.shellescape(file)
  os.execute(cmd)
end, { desc = "Open current file in browser", silent = true })

-- Toggle bullet point at the beginning of the current line in normal mode
-- If in a multiline paragraph, make sure the cursor is on the line at the top
-- "d" is for "dash" lamw25wmal
-- keymap.set("n", "<leader>md", function()
--   -- Get the current cursor position
--   local cursor_pos = vim.api.nvim_win_get_cursor(0)
--   local current_buffer = vim.api.nvim_get_current_buf()
--   local start_row = cursor_pos[1] - 1
--   local col = cursor_pos[2]
--   -- Get the current line
--   local line = vim.api.nvim_buf_get_lines(current_buffer, start_row, start_row + 1, false)[1]
--   -- Check if the line already starts with a bullet point
--   if line:match("^%s*%-") then
--     -- Remove the bullet point from the start of the line
--     line = line:gsub("^%s*%-", "")
--     vim.api.nvim_buf_set_lines(current_buffer, start_row, start_row + 1, false, { line })
--     return
--   end
--   -- Search for newline to the left of the cursor position
--   local left_text = line:sub(1, col)
--   local bullet_start = left_text:reverse():find("\n")
--   if bullet_start then
--     bullet_start = col - bullet_start
--   end
--   -- Search for newline to the right of the cursor position and in following lines
--   local right_text = line:sub(col + 1)
--   local bullet_end = right_text:find("\n")
--   local end_row = start_row
--   while not bullet_end and end_row < vim.api.nvim_buf_line_count(current_buffer) - 1 do
--     end_row = end_row + 1
--     local next_line = vim.api.nvim_buf_get_lines(current_buffer, end_row, end_row + 1, false)[1]
--     if next_line == "" then
--       break
--     end
--     right_text = right_text .. "\n" .. next_line
--     bullet_end = right_text:find("\n")
--   end
--   if bullet_end then
--     bullet_end = col + bullet_end
--   end
--   -- Extract lines
--   local text_lines = vim.api.nvim_buf_get_lines(current_buffer, start_row, end_row + 1, false)
--   local text = table.concat(text_lines, "\n")
--   -- Add bullet point at the start of the text
--   local new_text = "- " .. text
--   local new_lines = vim.split(new_text, "\n")
--   -- Set new lines in buffer
--   vim.api.nvim_buf_set_lines(current_buffer, start_row, end_row + 1, false, new_lines)
-- end, { desc = "Toggle bullet point (dash)" })

-- Keymap to switch spelling language to English lamw25wmal
-- To save the language settings configured on each buffer, you need to add
-- "localoptions" to vim.opt.sessionoptions in the `lua/config/options.lua` file
keymap.set("n", "<leader>msle", function()
  vim.opt.spelllang = "en"
  vim.cmd("echo 'Spell language set to English'")
end, { desc = "Spelling language English" })

-- Keymap to switch spelling language to Spanish lamw25wmal
keymap.set("n", "<leader>msls", function()
  vim.opt.spelllang = "es"
  vim.cmd("echo 'Spell language set to Spanish'")
end, { desc = "Spelling language Spanish" })

-- Keymap to switch spelling language to both spanish and english lamw25wmal
keymap.set("n", "<leader>mslb", function()
  vim.opt.spelllang = "en,es"
  vim.cmd("echo 'Spell language set to Spanish and English'")
end, { desc = "Spelling language Spanish and English" })

-- Show spelling suggestions / spell suggestions
keymap.set("n", "<leader>mss", function()
  -- Simulate pressing "z=" with "m" option using feedkeys
  -- vim.api.nvim_replace_termcodes ensures "z=" is correctly interpreted
  -- 'm' is the {mode}, which in this case is 'Remap keys'. This is default.
  -- If {mode} is absent, keys are remapped.
  --
  -- I tried this keymap as usually with
  vim.cmd("normal! 1z=")
  -- But didn't work, only with nvim_feedkeys
  -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("z=", true, false, true), "m", true)
end, { desc = "Spelling suggestions" })

-- markdown good, accept spell suggestion
-- Add word under the cursor as a good word
keymap.set("n", "<leader>msg", function()
  vim.cmd("normal! zg")
end, { desc = "Spelling add word to spellfile" })

-- Undo zw, remove the word from the entry in 'spellfile'.
keymap.set("n", "<leader>msu", function()
  vim.cmd("normal! zug")
end, { desc = "Spelling undo, remove word from list" })

-- Repeat the replacement done by |z=| for all matches with the replaced word
-- in the current window.
keymap.set("n", "<leader>msr", function()
  -- vim.cmd(":spellr")
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(":spellr\n", true, false, true), "m", true)
end, { desc = "Spelling repeat" })

-- In visual mode, check if the selected text is already bold and show a message if it is
-- If not, surround it with double asterisks for bold
keymap.set("v", "<leader>mb", function()
  -- Get the selected text range
  local start_row, start_col = unpack(vim.fn.getpos("'<"), 2, 3)
  local end_row, end_col = unpack(vim.fn.getpos("'>"), 2, 3)
  -- Get the selected lines
  local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
  local selected_text = table.concat(lines, "\n"):sub(start_col, #lines == 1 and end_col or -1)
  if selected_text:match("^%*%*.*%*%*$") then
    vim.notify("Text already bold", vim.log.levels.INFO)
  else
    vim.cmd("normal 2gsa*")
  end
end, { desc = "BOLD current selection" })

-- -- Multiline unbold attempt
-- -- In normal mode, bold the current word under the cursor
-- -- If already bold, it will unbold the word under the cursor
-- -- If you're in a multiline bold, it will unbold it only if you're on the
-- -- first line
keymap.set("n", "<leader>mb", function()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local current_buffer = vim.api.nvim_get_current_buf()
  local start_row = cursor_pos[1] - 1
  local col = cursor_pos[2]
  -- Get the current line
  local line = vim.api.nvim_buf_get_lines(current_buffer, start_row, start_row + 1, false)[1]
  -- Check if the cursor is on an asterisk
  if line:sub(col + 1, col + 1):match("%*") then
    vim.notify("Cursor is on an asterisk, run inside the bold text", vim.log.levels.WARN)
    return
  end
  -- Search for '**' to the left of the cursor position
  local left_text = line:sub(1, col)
  local bold_start = left_text:reverse():find("%*%*")
  if bold_start then
    bold_start = col - bold_start
  end
  -- Search for '**' to the right of the cursor position and in following lines
  local right_text = line:sub(col + 1)
  local bold_end = right_text:find("%*%*")
  local end_row = start_row
  while not bold_end and end_row < vim.api.nvim_buf_line_count(current_buffer) - 1 do
    end_row = end_row + 1
    local next_line = vim.api.nvim_buf_get_lines(current_buffer, end_row, end_row + 1, false)[1]
    if next_line == "" then
      break
    end
    right_text = right_text .. "\n" .. next_line
    bold_end = right_text:find("%*%*")
  end
  if bold_end then
    bold_end = col + bold_end
  end
  -- Remove '**' markers if found, otherwise bold the word
  if bold_start and bold_end then
    -- Extract lines
    local text_lines = vim.api.nvim_buf_get_lines(current_buffer, start_row, end_row + 1, false)
    local text = table.concat(text_lines, "\n")
    -- Calculate positions to correctly remove '**'
    -- vim.notify("bold_start: " .. bold_start .. ", bold_end: " .. bold_end)
    local new_text = text:sub(1, bold_start - 1) .. text:sub(bold_start + 2, bold_end - 1) .. text:sub(bold_end + 2)
    local new_lines = vim.split(new_text, "\n")
    -- Set new lines in buffer
    vim.api.nvim_buf_set_lines(current_buffer, start_row, end_row + 1, false, new_lines)
    -- vim.notify("Unbolded text", vim.log.levels.INFO)
  else
    -- Bold the word at the cursor position if no bold markers are found
    local before = line:sub(1, col)
    local after = line:sub(col + 1)
    local inside_surround = before:match("%*%*[^%*]*$") and after:match("^[^%*]*%*%*")
    if inside_surround then
      vim.cmd("normal gsd*.")
    else
      vim.cmd("normal viw")
      vim.cmd("normal 2gsa*")
    end
    vim.notify("Bolded current word", vim.log.levels.INFO)
  end
end, { desc = "BOLD toggle bold markers" })

-- Paste a github link and add it in this format
-- [folke/noice.nvim](https://github.com/folke/noice.nvim){:target="\_blank"}
keymap.set("n", "<leader>mg", function()
  -- Insert the text in the desired format
  vim.cmd('normal! a[](){:target="_blank"} ')
  vim.cmd("normal! F(pv2F/lyF[p")
  -- Leave me in normal mode or command mode
  vim.cmd("stopinsert")
end, { desc = "Paste Github link" })

-------------------------------------------------------------------------------
--                           Folding section
-------------------------------------------------------------------------------

-- Use <CR> to fold when in normal mode
-- To see help about folds use `:help fold`
keymap.set("n", "<CR>", function()
  -- Get the current line number
  local line = vim.fn.line(".")
  -- Get the fold level of the current line
  local foldlevel = vim.fn.foldlevel(line)
  if foldlevel == 0 then
    vim.notify("No fold found", vim.log.levels.INFO)
  else
    vim.cmd("normal! za")
  end
end, { desc = "Toggle fold" })

local function set_foldmethod_expr()
  -- These are lazyvim.org defaults but setting them just in case a file
  -- doesn't have them set
  if vim.fn.has("nvim-0.10") == 1 then
    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "v:lua.require'lazyvim.util'.ui.foldexpr()"
    vim.opt.foldtext = ""
  else
    vim.opt.foldmethod = "indent"
    vim.opt.foldtext = "v:lua.require'lazyvim.util'.ui.foldtext()"
  end
  vim.opt.foldlevel = 99
end

-- Function to fold all headings of a specific level
local function fold_headings_of_level(level)
  -- Move to the top of the file
  vim.cmd("normal! gg")
  -- Get the total number of lines
  local total_lines = vim.fn.line("$")
  for line = 1, total_lines do
    -- Get the content of the current line
    local line_content = vim.fn.getline(line)
    -- "^" -> Ensures the match is at the start of the line
    -- string.rep("#", level) -> Creates a string with 'level' number of "#" characters
    -- "%s" -> Matches any whitespace character after the "#" characters
    -- So this will match `## `, `### `, `#### ` for example, which are markdown headings
    if line_content:match("^" .. string.rep("#", level) .. "%s") then
      -- Move the cursor to the current line
      vim.fn.cursor(line, 1)
      -- Fold the heading if it matches the level
      if vim.fn.foldclosed(line) == -1 then
        vim.cmd("normal! za")
      end
    end
  end
end

local function fold_markdown_headings(levels)
  set_foldmethod_expr()
  -- I save the view to know where to jump back after folding
  local saved_view = vim.fn.winsaveview()
  for _, level in ipairs(levels) do
    fold_headings_of_level(level)
  end
  vim.cmd("nohlsearch")
  -- Restore the view to jump to where I was
  vim.fn.winrestview(saved_view)
end

-- Keymap for unfolding markdown headings of level 2 or above
keymap.set("n", "<leader>mfu", function()
  -- Reloads the file to reflect the changes
  vim.cmd("edit!")
  vim.cmd("normal! zR") -- Unfold all headings
end, { desc = "Unfold all headings level 2 or above" })

-- Keymap for folding markdown headings of level 1 or above
keymap.set("n", "<leader>mfj", function()
  -- Reloads the file to refresh folds, otherwise you have to re-open neovim
  vim.cmd("edit!")
  -- Unfold everything first or I had issues
  vim.cmd("normal! zR")
  fold_markdown_headings({ 6, 5, 4, 3, 2, 1 })
end, { desc = "Fold all headings level 1 or above" })

-- Keymap for folding markdown headings of level 2 or above
-- I know, it reads like "madafaka" but "k" for me means "2"
keymap.set("n", "<leader>mfk", function()
  -- Reloads the file to refresh folds, otherwise you have to re-open neovim
  vim.cmd("edit!")
  -- Unfold everything first or I had issues
  vim.cmd("normal! zR")
  fold_markdown_headings({ 6, 5, 4, 3, 2 })
end, { desc = "Fold all headings level 2 or above" })

-- Keymap for folding markdown headings of level 3 or above
keymap.set("n", "<leader>mfl", function()
  -- Reloads the file to refresh folds, otherwise you have to re-open neovim
  vim.cmd("edit!")
  -- Unfold everything first or I had issues
  vim.cmd("normal! zR")
  fold_markdown_headings({ 6, 5, 4, 3 })
end, { desc = "Fold all headings level 3 or above" })

-- Keymap for folding markdown headings of level 4 or above
keymap.set("n", "<leader>mf;", function()
  -- Reloads the file to refresh folds, otherwise you have to re-open neovim
  vim.cmd("edit!")
  -- Unfold everything first or I had issues
  vim.cmd("normal! zR")
  fold_markdown_headings({ 6, 5, 4 })
end, { desc = "Fold all headings level 4 or above" })

-------------------------------------------------------------------------------
--                         End Folding section
-------------------------------------------------------------------------------

-- Generate/update a Markdown TOC
-- To generate the TOC I use the markdown-toc plugin
-- https://github.com/jonschlinkert/markdown-toc
-- And the markdown-toc plugin installed as a LazyExtra
keymap.set("n", "<leader>mt", function()
  local path = vim.fn.expand("%") -- Expands the current file name to a full path
  local bufnr = 0 -- The current buffer number, 0 references the current active buffer
  -- Save the current view
  -- If I don't do this, my folds are lost when I run this keymap
  vim.cmd("mkview")
  -- Retrieves all lines from the current buffer
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local toc_exists = false -- Flag to check if TOC marker exists
  local frontmatter_end = 0 -- To store the end line number of frontmatter
  -- Check for frontmatter and TOC marker
  for i, line in ipairs(lines) do
    if i == 1 and line:match("^---$") then
      -- Frontmatter start detected, now find the end
      for j = i + 1, #lines do
        if lines[j]:match("^---$") then
          frontmatter_end = j -- Save the end line of the frontmatter
          break
        end
      end
    end
    -- Checks for the TOC marker
    if line:match("^%s*<!%-%-%s*toc%s*%-%->%s*$") then
      toc_exists = true -- Sets the flag if TOC marker is found
      break -- Stops the loop if TOC marker is found
    end
  end
  -- Inserts H1 heading and <!-- toc --> at the appropriate position
  if not toc_exists then
    if frontmatter_end > 0 then
      -- Insert after frontmatter
      vim.api.nvim_buf_set_lines(bufnr, frontmatter_end, frontmatter_end, false, { "", "# Contents", "<!-- toc -->" })
    else
      -- Insert at the top if no frontmatter
      vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, { "# Contents", "<!-- toc -->" })
    end
  end
  -- Silently save the file, in case TOC being created for first time (yes, you need the 2 saves)
  vim.cmd("silent write")
  -- Silently run markdown-toc to update the TOC without displaying command output
  vim.fn.system("markdown-toc -i " .. path)
  vim.cmd("edit!") -- Reloads the file to reflect the changes made by markdown-toc
  vim.cmd("silent write") -- Silently save the file
  vim.notify("TOC updated and file saved", vim.log.levels.INFO)
  -- -- In case a cleanup is needed, leaving this old code here as a reference
  -- -- I used this code before I implemented the frontmatter check
  -- -- Moves the cursor to the top of the file
  -- vim.api.nvim_win_set_cursor(bufnr, { 1, 0 })
  -- -- Deletes leading blank lines from the top of the file
  -- while true do
  --   -- Retrieves the first line of the buffer
  --   local line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
  --   -- Checks if the line is empty
  --   if line == "" then
  --     -- Deletes the line if it's empty
  --     vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, {})
  --   else
  --     -- Breaks the loop if the line is not empty, indicating content or TOC marker
  --     break
  --   end
  -- end
  -- Restore the saved view (including folds)
  vim.cmd("loadview")
end, { desc = "Insert/update Markdown TOC" })

-- Save the cursor position globally to access it across different mappings
_G.saved_positions = {}

-- Mapping to jump to the first line of the TOC
keymap.set("n", "<leader>mm", function()
  -- Save the current cursor position
  _G.saved_positions["toc_return"] = vim.api.nvim_win_get_cursor(0)
  -- Perform a silent search for the <!-- toc --> marker and move the cursor two lines below it
  vim.cmd("silent! /<!-- toc -->\\n\\n\\zs.*")
  -- Clear the search highlight without showing the "search hit BOTTOM, continuing at TOP" message
  vim.cmd("nohlsearch")
  -- Retrieve the current cursor position (after moving to the TOC)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local row = cursor_pos[1]
  -- local col = cursor_pos[2]
  -- Move the cursor to column 15 (starts counting at 0)
  -- I like just going down on the TOC and press gd to go to a section
  vim.api.nvim_win_set_cursor(0, { row, 14 })
end, { desc = "Jump to the first line of the TOC" })

-- Mapping to return to the previously saved cursor position
keymap.set("n", "<leader>mn", function()
  local pos = _G.saved_positions["toc_return"]
  if pos then
    vim.api.nvim_win_set_cursor(0, pos)
  end
end, { desc = "Return to position before jumping" })

-- Search UP for a markdown header
-- Make sure to follow proper markdown convention, and you have a single H1
-- heading at the very top of the file
-- This will only search for H2 headings and above
keymap.set({ "n", "v" }, "gk", function()
  -- `?` - Start a search backwards from the current cursor position.
  -- `^` - Match the beginning of a line.
  -- `##` - Match 2 ## symbols
  -- `\\+` - Match one or more occurrences of prev element (#)
  -- `\\s` - Match exactly one whitespace character following the hashes
  -- `.*` - Match any characters (except newline) following the space
  -- `$` - Match extends to end of line
  vim.cmd("silent! ?^##\\+\\s.*$")
  -- Clear the search highlight
  vim.cmd("nohlsearch")
end, { desc = "Go to previous markdown header" })

-- Search DOWN for a markdown header
-- Make sure to follow proper markdown convention, and you have a single H1
-- heading at the very top of the file
-- This will only search for H2 headings and above
keymap.set({ "n", "v" }, "gj", function()
  -- `/` - Start a search forwards from the current cursor position.
  -- `^` - Match the beginning of a line.
  -- `##` - Match 2 ## symbols
  -- `\\+` - Match one or more occurrences of prev element (#)
  -- `\\s` - Match exactly one whitespace character following the hashes
  -- `.*` - Match any characters (except newline) following the space
  -- `$` - Match extends to end of line
  vim.cmd("silent! /^##\\+\\s.*$")
  -- Clear the search highlight
  vim.cmd("nohlsearch")
end, { desc = "Go to next markdown header" })

-- Surround the http:// url that the cursor is currently in with ``
keymap.set("n", "gsu", function()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- Adjust for 0-index in Lua
  -- This makes the `s` optional so it matches both http and https
  local pattern = "https?://[^ ,;'\"<>%s)]*"
  -- Find the starting and ending positions of the URL
  local s, e = string.find(line, pattern)
  while s and e do
    if s <= col and e >= col then
      -- When the cursor is within the URL
      local url = string.sub(line, s, e)
      -- Update the line with backticks around the URL
      local new_line = string.sub(line, 1, s - 1) .. "`" .. url .. "`" .. string.sub(line, e + 1)
      vim.api.nvim_set_current_line(new_line)
      vim.cmd("silent write")
      return
    end
    -- Find the next URL in the line
    s, e = string.find(line, pattern, e + 1)
    -- Save the file to update trouble list
  end
  print("No URL found under cursor")
end, { desc = "Add surrounding to URL" })

-- ############################################################################
--                       End of markdown section
-- ############################################################################

-- ############################################################################
--                             Image section
-- ############################################################################

-- Open image under cursor in the Preview app (macOS)
keymap.set("n", "<leader>io", function()
  local function get_image_path()
    -- Get the current line
    local line = vim.api.nvim_get_current_line()
    -- Pattern to match image path in Markdown
    local image_pattern = "%[.-%]%((.-)%)"
    -- Extract relative image path
    local _, _, image_path = string.find(line, image_pattern)

    return image_path
  end

  -- Get the image path
  local image_path = get_image_path()

  if image_path then
    -- Check if the image path starts with "http" or "https"
    if string.sub(image_path, 1, 4) == "http" then
      print("URL image, use 'gx' to open it in the default browser.")
    else
      -- Construct absolute image path
      local current_file_path = vim.fn.expand("%:p:h")
      local absolute_image_path = current_file_path .. "/" .. image_path

      -- Construct command to open image in Preview
      local command = "open -a Preview " .. vim.fn.shellescape(absolute_image_path)
      -- Execute the command
      local success = os.execute(command)

      if success then
        print("Opened image in Preview: " .. absolute_image_path)
      else
        print("Failed to open image in Preview: " .. absolute_image_path)
      end
    end
  else
    print("No image found under the cursor")
  end
end, { desc = "[P](macOS) Open image under cursor in Preview" })

-- ############################################################################

-- Open image under cursor in Finder (macOS)
--
-- THIS ONLY WORKS IF YOU'RE NNNNNOOOOOOTTTTT USING ABSOLUTE PATHS,
-- BUT INSTEAD YOURE USING RELATIVE PATHS
--
-- If using absolute paths, use the default `gx` to open the image instead
keymap.set("n", "<leader>if", function()
  local function get_image_path()
    -- Get the current line
    local line = vim.api.nvim_get_current_line()
    -- Pattern to match image path in Markdown
    local image_pattern = "%[.-%]%((.-)%)"
    -- Extract relative image path
    local _, _, image_path = string.find(line, image_pattern)

    return image_path
  end

  -- Get the image path
  local image_path = get_image_path()

  if image_path then
    -- Check if the image path starts with "http" or "https"
    if string.sub(image_path, 1, 4) == "http" then
      print("URL image, use 'gx' to open it in the default browser.")
    else
      -- Construct absolute image path
      local current_file_path = vim.fn.expand("%:p:h")
      local absolute_image_path = current_file_path .. "/" .. image_path

      -- Open the containing folder in Finder and select the image file
      local command = "open -R " .. vim.fn.shellescape(absolute_image_path)
      local success = vim.fn.system(command)

      if success == 0 then
        print("Opened image in Finder: " .. absolute_image_path)
      else
        print("Failed to open image in Finder: " .. absolute_image_path)
      end
    end
  else
    print("No image found under the cursor")
  end
end, { desc = "[P](macOS) Open image under cursor in Finder" })

-- ############################################################################
