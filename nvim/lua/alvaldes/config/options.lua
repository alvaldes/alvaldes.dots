-- Basic settings
vim.opt.number = true -- Line numbers
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.title = true -- Use titlestring for window
vim.opt.cursorline = true -- Highlight current line
vim.opt.wrap = false -- Don't wrap lines
vim.opt.confirm = true -- Ask to save changes instead of failing on :q with unsaved buffers

-- Spell checking (English + Spanish). Words added with `zg` go to the
-- versioned spell/en.utf-8.add in this config.
local spell_add = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"

-- Spell only reads the compiled .add.spl, which is git-ignored. Rebuild it when
-- missing or older than the word list (fresh clone, edits synced from git).
-- Runs before enabling spell so this session already loads the fresh file.
do
	local add_stat = vim.uv.fs_stat(spell_add)
	local spl_stat = vim.uv.fs_stat(spell_add .. ".spl")
	if add_stat and (not spl_stat or spl_stat.mtime.sec < add_stat.mtime.sec) then
		vim.cmd("silent mkspell! " .. vim.fn.fnameescape(spell_add))
	end
end

vim.opt.spellfile = spell_add
vim.opt.spelllang = { "en", "es" }
vim.opt.spell = true
vim.opt.scrolloff = 10 -- Keep 10 lines above/below cursor
vim.opt.sidescrolloff = 8 -- Keep 8 columns left/right of cursor

-- Indentation
vim.opt.tabstop = 2 -- Tab width
vim.opt.shiftwidth = 2 -- Indent width
vim.opt.softtabstop = 2 -- Soft tab stop
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.smartindent = true -- Smart auto-indenting

-- Search settings
vim.opt.ignorecase = true -- Case insensitive search
vim.opt.smartcase = true -- Case sensitive if uppercase in search

-- Visual settings
vim.opt.termguicolors = true -- Enable 24-bit colors
vim.opt.signcolumn = "yes" -- Always show sign column
vim.opt.showmatch = true -- Highlight matching brackets
vim.opt.matchtime = 2 -- How long to show matching bracket
vim.opt.cmdheight = 0 -- Command line height
vim.opt.completeopt = "menuone,noinsert,noselect" -- Completion options
vim.opt.pumheight = 10 -- Popup menu height
vim.opt.pumblend = 10 -- Popup menu transparency
vim.opt.winborder = "rounded" -- The default border style of floating windows
-- vim.opt.lazyredraw = true                          -- Don't redraw during macros
vim.opt.laststatus = 3

-- File handling
vim.opt.writebackup = false -- Don't create backup before writing
vim.opt.swapfile = false -- Don't create swap files
vim.opt.undofile = true -- Persistent undo
vim.opt.undodir = vim.fn.expand("~/.cache/nvim/undodir") -- Undo directory
vim.opt.updatetime = 300 -- Faster completion
vim.opt.timeoutlen = 500 -- Key timeout duration
vim.opt.ttimeoutlen = 0 -- Key code timeout

-- Behavior settings
vim.opt.iskeyword:append("-") -- Treat dash as part of word
vim.opt.path:append("**") -- Include subdirectories in search
vim.opt.wildignore:append({ "*/node_modules/*" }) -- Ignore node_modules
vim.opt.mouse = "" -- Disable mouse support
vim.opt.clipboard:append("unnamedplus") -- Use system clipboard

-- Cursor settings
vim.opt.guicursor =
	"n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"

-- Folding settings
vim.opt.foldmethod = "expr" -- Use expression for folding
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- Use treesitter for folding
vim.opt.foldlevel = 99 -- Start with all folds open

-- Split behavior
vim.opt.splitbelow = true -- Horizontal splits go below
vim.opt.splitright = true -- Vertical splits go right

-- Key mappings
vim.g.mapleader = " " -- Set leader key to space
vim.g.maplocalleader = " " -- Set local leader key (NEW)

-- Built-in netrw
vim.g.netrw_keepdir = 0 -- Keep the current directory and the browsing directory synced
vim.g.netrw_localcopydircmd = "cp -r" -- Enable recursive copy of directories

-- Command-line completion
vim.opt.wildmode = "longest:full,full"
vim.opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.class", "*.jar" })

-- Diff view
vim.opt.fillchars:append("diff:╱")

-- Prompt/dialog styling for ui2 (supported knobs only: ui2 rewrites the dialog
-- position and border on every message, so we style it instead of moving it).
--   * msgsep draws the line ui2 puts above the dialog/pager
--   * FileType <target> is ui2's documented hook to set window-local options
--   * colors derive from the active theme and refresh on :colorscheme
vim.opt.fillchars:append("msgsep:─")

local function apply_ui2_highlights()
	local function color(group, attr)
		return vim.api.nvim_get_hl(0, { name = group, link = false })[attr]
	end
	local accent = color("WarningMsg", "fg")
	local panel = color("NormalFloat", "bg") or color("CursorLine", "bg") or color("Pmenu", "bg")
	vim.api.nvim_set_hl(0, "Ui2Dialog", { fg = color("Normal", "fg"), bg = panel })
	vim.api.nvim_set_hl(0, "MsgSeparator", { fg = accent, bg = panel })
	vim.api.nvim_set_hl(0, "Question", { fg = accent, bold = true })
	vim.api.nvim_set_hl(0, "MoreMsg", { fg = color("Function", "fg"), bold = true })
end

local ui2_style = vim.api.nvim_create_augroup("Ui2Style", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", { group = ui2_style, callback = apply_ui2_highlights })
-- Must be registered before ui2.enable(), which creates the windows and fires FileType
vim.api.nvim_create_autocmd("FileType", {
	group = ui2_style,
	pattern = "dialog",
	callback = function()
		vim.wo.winhighlight = "Normal:Ui2Dialog,Search:,CurSearch:,IncSearch:"
	end,
})

-- For floating cmdline and messages
require("vim._core.ui2").enable({
	enable = true,
	msg = {
		targets = {
			[""] = "msg",
			empty = "cmd",
			bufwrite = "msg",
			confirm = "cmd",
			emsg = "pager",
			echo = "msg",
			echomsg = "msg",
			echoerr = "pager",
			completion = "cmd",
			list_cmd = "pager",
			lua_error = "pager",
			lua_print = "msg",
			progress = "pager",
			rpc_error = "pager",
			quickfix = "msg",
			search_cmd = "cmd",
			search_count = "cmd",
			shell_cmd = "pager",
			shell_err = "pager",
			shell_out = "pager",
			shell_ret = "msg",
			undo = "msg",
			verbose = "pager",
			wildlist = "cmd",
			wmsg = "msg",
			typed_cmd = "cmd",
		},
		cmd = { height = 0.5 },
		dialog = { height = 0.5 },
		msg = { height = 0.3, timeout = 5000 },
		pager = { height = 0.5 },
	},
})
