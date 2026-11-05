-- Gentleman colorscheme: maps the Ghostty palette onto Neovim highlight groups.
-- Load with `:colorscheme gentleman`. Set `vim.g.gentleman_transparent = true`
-- before loading to drop the editor background (like the other themes here).
local M = {}

function M.load()
	local p = require("alvaldes.themes.gentleman.palette")
	local c, u = p.ansi, p.ui
	local transparent = vim.g.gentleman_transparent == true
	local bg = transparent and "NONE" or u.bg
	local bg_float = transparent and "NONE" or u.bg_dark

	vim.cmd("highlight clear")
	if vim.fn.exists("syntax_on") == 1 then
		vim.cmd("syntax reset")
	end
	vim.o.background = "dark"
	vim.o.termguicolors = true
	vim.g.colors_name = "gentleman"

	local groups = {
		-- Editor
		Normal = { fg = c.foreground, bg = bg },
		NormalNC = { fg = c.foreground, bg = bg },
		NormalFloat = { fg = c.foreground, bg = bg_float },
		FloatBorder = { fg = u.border, bg = bg_float },
		FloatTitle = { fg = u.gold, bg = bg_float, bold = true },
		Cursor = { fg = c.background, bg = c.cursor },
		CursorLine = { bg = u.bg_line },
		CursorColumn = { bg = u.bg_line },
		ColorColumn = { bg = u.bg_line },
		CursorLineNr = { fg = u.gold, bold = true },
		LineNr = { fg = u.fg_gutter },
		SignColumn = { bg = bg },
		FoldColumn = { fg = u.fg_gutter, bg = bg },
		Folded = { fg = c.bright_black, bg = u.bg_line },
		VertSplit = { fg = u.border },
		WinSeparator = { fg = u.border },
		EndOfBuffer = { fg = u.bg_line },
		NonText = { fg = u.fg_gutter },
		Whitespace = { fg = u.bg_line },
		SpecialKey = { fg = u.fg_gutter },
		Visual = { bg = u.bg_visual },
		VisualNOS = { bg = u.bg_visual },
		Search = { fg = c.background, bg = c.blue },
		IncSearch = { fg = c.background, bg = u.gold },
		CurSearch = { fg = c.background, bg = u.gold, bold = true },
		Substitute = { fg = c.background, bg = c.red },
		MatchParen = { fg = u.gold, bold = true, underline = true },
		Pmenu = { fg = u.fg_dim, bg = u.bg_alt },
		PmenuSel = { fg = c.foreground, bg = u.bg_visual, bold = true },
		PmenuSbar = { bg = u.bg_alt },
		PmenuThumb = { bg = u.border },
		StatusLine = { fg = u.fg_dim, bg = transparent and "NONE" or u.bg_alt },
		StatusLineNC = { fg = u.comment, bg = transparent and "NONE" or u.bg_alt },
		TabLine = { fg = u.comment, bg = u.bg_line },
		TabLineSel = { fg = c.background, bg = u.gold, bold = true },
		TabLineFill = { bg = "NONE" },
		WinBar = { fg = u.fg_dim },
		WinBarNC = { fg = u.comment },
		Title = { fg = c.blue, bold = true },
		Directory = { fg = c.blue },
		Question = { fg = c.green },
		MoreMsg = { fg = c.green },
		ModeMsg = { fg = c.foreground, bold = true },
		ErrorMsg = { fg = c.red },
		WarningMsg = { fg = u.gold },
		WildMenu = { fg = c.background, bg = c.blue },
		Conceal = { fg = u.comment },
		SpellBad = { sp = c.red, undercurl = true },
		SpellCap = { sp = c.yellow, undercurl = true },
		SpellLocal = { sp = c.blue, undercurl = true },
		SpellRare = { sp = c.magenta, undercurl = true },
		QuickFixLine = { bg = u.bg_line, bold = true },

		-- Syntax
		Comment = { fg = u.comment, italic = true },
		Constant = { fg = u.gold },
		String = { fg = c.green },
		Character = { fg = c.bright_green },
		Number = { fg = u.gold },
		Boolean = { fg = c.magenta },
		Float = { fg = u.gold },
		Identifier = { fg = c.foreground },
		Function = { fg = c.blue },
		Statement = { fg = c.red },
		Conditional = { fg = c.red },
		Repeat = { fg = c.red },
		Label = { fg = c.red },
		Operator = { fg = c.bright_blue },
		Keyword = { fg = c.red, italic = true },
		Exception = { fg = c.red },
		PreProc = { fg = c.magenta },
		Include = { fg = c.red },
		Define = { fg = c.magenta },
		Macro = { fg = c.magenta },
		PreCondit = { fg = c.magenta },
		Type = { fg = c.cyan },
		StorageClass = { fg = c.red },
		Structure = { fg = c.cyan },
		Typedef = { fg = c.cyan },
		Special = { fg = c.bright_blue },
		SpecialChar = { fg = c.yellow },
		Tag = { fg = c.red },
		Delimiter = { fg = u.fg_dim },
		SpecialComment = { fg = c.bright_black, italic = true },
		Debug = { fg = c.red },
		Underlined = { underline = true },
		Error = { fg = c.red },
		Todo = { fg = c.background, bg = c.yellow, bold = true },

		-- Treesitter
		["@variable"] = { fg = c.foreground },
		["@variable.builtin"] = { fg = c.bright_red, italic = true },
		["@variable.parameter"] = { fg = c.bright_red },
		["@variable.member"] = { fg = u.fg_dim },
		["@property"] = { fg = u.fg_dim },
		["@constant"] = { fg = u.gold },
		["@constant.builtin"] = { fg = c.magenta },
		["@module"] = { fg = c.bright_blue },
		["@label"] = { fg = c.red },
		["@string"] = { link = "String" },
		["@string.escape"] = { fg = c.yellow },
		["@string.regexp"] = { fg = c.yellow },
		["@string.special.url"] = { fg = c.blue, underline = true },
		["@character"] = { link = "Character" },
		["@number"] = { link = "Number" },
		["@boolean"] = { link = "Boolean" },
		["@type"] = { link = "Type" },
		["@type.builtin"] = { fg = c.cyan, italic = true },
		["@attribute"] = { fg = c.magenta },
		["@function"] = { link = "Function" },
		["@function.builtin"] = { fg = c.bright_blue },
		["@function.call"] = { fg = c.blue },
		["@function.method"] = { fg = c.blue },
		["@constructor"] = { fg = c.cyan },
		["@operator"] = { link = "Operator" },
		["@keyword"] = { link = "Keyword" },
		["@keyword.function"] = { fg = c.red, italic = true },
		["@keyword.return"] = { fg = c.red, italic = true },
		["@keyword.import"] = { fg = c.red },
		["@keyword.operator"] = { fg = c.red },
		["@punctuation.delimiter"] = { fg = u.fg_dim },
		["@punctuation.bracket"] = { fg = u.fg_dim },
		["@punctuation.special"] = { fg = c.bright_blue },
		["@comment"] = { link = "Comment" },
		["@comment.todo"] = { link = "Todo" },
		["@comment.note"] = { fg = c.background, bg = c.blue, bold = true },
		["@comment.warning"] = { fg = c.background, bg = u.gold, bold = true },
		["@comment.error"] = { fg = c.background, bg = c.red, bold = true },
		["@tag"] = { fg = c.red },
		["@tag.attribute"] = { fg = c.cyan, italic = true },
		["@tag.delimiter"] = { fg = u.comment },
		["@markup.heading"] = { fg = c.blue, bold = true },
		["@markup.strong"] = { bold = true },
		["@markup.italic"] = { italic = true },
		["@markup.strikethrough"] = { strikethrough = true },
		["@markup.link"] = { fg = c.cyan },
		["@markup.link.url"] = { fg = c.blue, underline = true },
		["@markup.raw"] = { fg = c.green },
		["@markup.list"] = { fg = c.red },
		["@markup.quote"] = { fg = u.comment, italic = true },
		["@diff.plus"] = { fg = c.green },
		["@diff.minus"] = { fg = c.red },
		["@diff.delta"] = { fg = c.blue },

		-- LSP
		["@lsp.type.parameter"] = { link = "@variable.parameter" },
		["@lsp.type.property"] = { link = "@property" },
		["@lsp.type.namespace"] = { link = "@module" },
		["@lsp.type.interface"] = { fg = c.cyan, italic = true },
		["@lsp.type.enumMember"] = { fg = u.gold },
		["@lsp.typemod.variable.readonly"] = { fg = c.foreground },
		LspReferenceText = { bg = u.bg_line },
		LspReferenceRead = { bg = u.bg_line },
		LspReferenceWrite = { bg = u.bg_line, underline = true },
		LspInlayHint = { fg = u.comment, bg = u.bg_alt, italic = true },
		LspSignatureActiveParameter = { fg = u.gold, bold = true },

		-- Diagnostics
		DiagnosticError = { fg = c.red },
		DiagnosticWarn = { fg = u.gold },
		DiagnosticInfo = { fg = c.blue },
		DiagnosticHint = { fg = c.cyan },
		DiagnosticOk = { fg = c.green },
		DiagnosticUnderlineError = { sp = c.red, undercurl = true },
		DiagnosticUnderlineWarn = { sp = u.gold, undercurl = true },
		DiagnosticUnderlineInfo = { sp = c.blue, undercurl = true },
		DiagnosticUnderlineHint = { sp = c.cyan, undercurl = true },
		DiagnosticVirtualTextError = { fg = c.red, bg = u.diff_delete },
		DiagnosticVirtualTextWarn = { fg = u.gold, bg = u.bg_alt },
		DiagnosticVirtualTextInfo = { fg = c.blue, bg = u.diff_change },
		DiagnosticVirtualTextHint = { fg = c.cyan, bg = u.bg_alt },
		DiagnosticUnnecessary = { fg = u.comment },

		-- Diff / git
		DiffAdd = { bg = u.diff_add },
		DiffChange = { bg = u.diff_change },
		DiffDelete = { fg = c.red, bg = u.diff_delete },
		DiffText = { bg = u.diff_text },
		Added = { fg = c.green },
		Changed = { fg = c.blue },
		Removed = { fg = c.red },
		GitSignsAdd = { fg = c.green },
		GitSignsChange = { fg = c.blue },
		GitSignsDelete = { fg = c.red },
		MiniDiffSignAdd = { fg = c.green },
		MiniDiffSignChange = { fg = c.blue },
		MiniDiffSignDelete = { fg = c.red },

		-- Snacks (dashboard, picker, notifier, indent)
		SnacksDashboardHeader = { fg = c.blue },
		SnacksDashboardIcon = { fg = c.cyan },
		SnacksDashboardDesc = { fg = c.foreground },
		SnacksDashboardKey = { fg = u.gold },
		SnacksDashboardTitle = { fg = c.red, bold = true },
		SnacksDashboardFile = { fg = c.bright_blue },
		SnacksDashboardDir = { fg = u.comment },
		SnacksDashboardFooter = { fg = u.comment },
		SnacksPickerMatch = { fg = u.gold, bold = true },
		SnacksPickerDir = { fg = u.comment },
		SnacksPickerBorder = { link = "FloatBorder" },
		SnacksPickerTitle = { link = "FloatTitle" },
		SnacksIndent = { fg = u.bg_line },
		SnacksIndentScope = { fg = u.border },

		-- Completion (blink.cmp)
		BlinkCmpMenu = { link = "Pmenu" },
		BlinkCmpMenuBorder = { link = "FloatBorder" },
		BlinkCmpMenuSelection = { link = "PmenuSel" },
		BlinkCmpLabelMatch = { fg = u.gold, bold = true },
		BlinkCmpKind = { fg = c.cyan },
		BlinkCmpGhostText = { fg = u.comment, italic = true },

		-- Editing plugins
		FlashLabel = { fg = c.background, bg = c.magenta, bold = true },
		FlashMatch = { fg = c.bright_blue, bg = u.bg_line },
		FlashCurrent = { fg = c.background, bg = u.gold },
		FlashBackdrop = { fg = u.comment },
		MiniSurround = { link = "IncSearch" },
		WhichKey = { fg = c.blue },
		WhichKeyGroup = { fg = c.magenta },
		WhichKeyDesc = { fg = c.foreground },
		WhichKeySeparator = { fg = u.comment },
		WhichKeyNormal = { link = "NormalFloat" },
		WhichKeyBorder = { link = "FloatBorder" },
		TodoBgTODO = { fg = c.background, bg = c.blue, bold = true },
		TodoFgTODO = { fg = c.blue },
		TodoBgFIX = { fg = c.background, bg = c.red, bold = true },
		TodoFgFIX = { fg = c.red },
		TodoBgWARN = { fg = c.background, bg = u.gold, bold = true },
		TodoFgWARN = { fg = u.gold },
		TodoBgNOTE = { fg = c.background, bg = c.cyan, bold = true },
		TodoFgNOTE = { fg = c.cyan },

		-- Oil / trouble / incline
		OilDir = { fg = c.blue, bold = true },
		OilFile = { fg = c.foreground },
		TroubleNormal = { fg = c.foreground, bg = bg_float },
		InclineNormal = { fg = c.foreground, bg = u.bg_alt },
		InclineNormalNC = { fg = u.comment, bg = u.bg_alt },
	}

	for name, spec in pairs(groups) do
		vim.api.nvim_set_hl(0, name, spec)
	end

	-- Terminal colors match Ghostty exactly
	local term = {
		c.black, c.red, c.green, c.yellow, c.blue, c.magenta, c.cyan, c.white,
		c.bright_black, c.bright_red, c.bright_green, c.bright_yellow,
		c.bright_blue, c.bright_magenta, c.bright_cyan, c.bright_white,
	}
	for i, color in ipairs(term) do
		vim.g["terminal_color_" .. (i - 1)] = color
	end
end

return M
