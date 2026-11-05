-- Gentleman palette, taken verbatim from ghostty/themes/gentleman.
-- Keep the `ansi` block in sync with Ghostty; the `ui` block holds shades
-- derived from it for editor chrome (no Ghostty equivalent).
local M = {}

M.ansi = {
	background = "#06080f",
	foreground = "#f3f6f9",
	cursor = "#e0c15a",
	selection = "#263356",

	black = "#06080f",
	red = "#cb7c94",
	green = "#b7cc85",
	yellow = "#ffe066",
	blue = "#7fb4ca",
	magenta = "#ff8dd7",
	cyan = "#7aa89f",
	white = "#f3f6f9",

	bright_black = "#8a8fa3",
	bright_red = "#de8fa8",
	bright_green = "#d1e8a9",
	bright_yellow = "#fff7b1",
	bright_blue = "#a3d4d5",
	bright_magenta = "#ffaeea",
	bright_cyan = "#7fb4ca",
	bright_white = "#f3f6f9",
}

-- Derived shades, darkest to lightest, between background and selection
M.ui = {
	bg_dark = "#04060b", -- floats/sidebars sunk below the editor
	bg = M.ansi.background,
	bg_alt = "#0c111c", -- statusline, popup menus
	bg_line = "#121a2a", -- cursorline, inactive tabs
	bg_visual = M.ansi.selection,
	border = "#2a3550",
	fg_gutter = "#3b4560", -- line numbers
	comment = "#6b7089",
	fg_dim = "#b9c0cc",
	gold = M.ansi.cursor, -- numbers/constants and accents
	diff_add = "#1b2a1f",
	diff_change = "#1a2236",
	diff_delete = "#2d1720",
	diff_text = "#2b3a5c",
}

return M
