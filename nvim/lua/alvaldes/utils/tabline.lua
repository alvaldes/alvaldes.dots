local M = {}

-- Constants
local SOLID_LEFT_ARROW = "" -- nf-ple-lower_right_triangle (U+e0ba)
local SOLID_RIGHT_ARROW = "" -- nf-ple-lower_left_triangle (U+e0b8)
local MAX_NAME_LENGTH = 20
local TRUNCATE_TO = 17

---Read a color from an existing highlight group (theme-agnostic)
---@param group string
---@param attr "fg"|"bg"
---@param fallback string
---@return string|integer
local function hl_color(group, attr, fallback)
	local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
	return hl[attr] or fallback
end

---Apply tabline highlights derived from the active colorscheme
local function apply_highlights()
	local accent = hl_color("WarningMsg", "fg", "#e0c15a")
	local dark = hl_color("Normal", "bg", "#06080f")
	local muted_bg = hl_color("CursorLine", "bg", hl_color("Visual", "bg", "#263356"))
	local muted_fg = hl_color("Comment", "fg", "#8a8fa3")

	-- Active tab: accent background, dark text
	vim.api.nvim_set_hl(0, "TabLineActive", { fg = dark, bg = accent, bold = true })
	-- Inactive tab: subtle background, muted text
	vim.api.nvim_set_hl(0, "TabLineInactive", { fg = muted_fg, bg = muted_bg })
	-- Separators blend into a transparent fill
	vim.api.nvim_set_hl(0, "TabLineSepActive", { fg = accent, bg = "NONE" })
	vim.api.nvim_set_hl(0, "TabLineSepInactive", { fg = muted_bg, bg = "NONE" })
	vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE" })
end

---Setup highlight groups for the tabline and keep them in sync with the theme
function M.setup()
	apply_highlights()
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("AlvaldesTabline", { clear = true }),
		callback = apply_highlights,
	})
end

---Get file icon using MiniIcons with fallback
---@param filename string
---@return string icon, string hl
local function get_icon(filename)
	if MiniIcons and MiniIcons.get then
		return MiniIcons.get("file", filename)
	end
	return "", "Normal"
end

---Get display name for a buffer
---@param bufnr number
---@return string name, string icon
local function get_buf_info(bufnr)
	local bufname = vim.api.nvim_buf_get_name(bufnr)
	local buftype = vim.bo[bufnr].buftype
	local filetype = vim.bo[bufnr].filetype

	-- Handle special buffer types
	if buftype == "terminal" then
		return "[Terminal]", ""
	end

	if filetype == "oil" then
		local dir = bufname:gsub("^oil://", "")
		dir = vim.fn.fnamemodify(dir, ":~")
		if #dir > MAX_NAME_LENGTH then
			dir = "…" .. dir:sub(-TRUNCATE_TO)
		end
		return dir, ""
	end

	if bufname == "" then
		return "[No Name]", ""
	end

	local filename = vim.fn.fnamemodify(bufname, ":t")
	local icon = get_icon(filename)

	-- Truncate long filenames
	if #filename > MAX_NAME_LENGTH then
		filename = filename:sub(1, TRUNCATE_TO) .. "…"
	end

	return filename, icon
end

---Render a single tab
---@param tabnr number
---@param is_active boolean
---@return string
local function render_tab(tabnr, is_active)
	local buflist = vim.fn.tabpagebuflist(tabnr)
	local winnr = vim.fn.tabpagewinnr(tabnr)
	local bufnr = buflist[winnr]

	if not bufnr then
		return ""
	end

	local filename, icon = get_buf_info(bufnr)
	local modified = vim.bo[bufnr].modified

	-- Build the tab content
	local title = "   " .. icon .. " " .. filename
	if modified then
		title = "   [+] " .. icon .. " " .. filename
	end
	title = title .. "   "

	-- Select highlight groups based on active state
	local tab_hl = is_active and "%#TabLineActive#" or "%#TabLineInactive#"
	local sep_hl = is_active and "%#TabLineSepActive#" or "%#TabLineSepInactive#"

	-- Build clickable tab with separators
	return string.format(
		"%%%dT%s%s%s%s%s%s%%T",
		tabnr,
		sep_hl,
		SOLID_LEFT_ARROW,
		tab_hl,
		title,
		sep_hl,
		SOLID_RIGHT_ARROW
	)
end

---Render the complete tabline
---@return string
function M.render()
	local ok, result = pcall(function()
		local parts = {}
		local current_tab = vim.fn.tabpagenr()
		local tab_count = vim.fn.tabpagenr("$")

		for tabnr = 1, tab_count do
			local is_active = tabnr == current_tab
			parts[#parts + 1] = render_tab(tabnr, is_active)
		end

		return table.concat(parts) .. "%#TabLineFill#"
	end)

	if not ok then
		return "%#TabLineFill#"
	end
	return result
end

return M
