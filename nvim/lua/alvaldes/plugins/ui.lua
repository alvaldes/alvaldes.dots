local icons = Alvaldes.icons
local lualine_utils = require("alvaldes.utils.lualine")
local lazygit_utils = require("alvaldes.utils.lazygit")

-- Colorscheme
-- Active: everforest (same setup as the old LazyVim/gentle config).
-- Also available: `:colorscheme gentleman` (Ghostty palette, see colors/gentleman.lua).
require("everforest").setup({
	background = "hard",
	italics = true,
	transparent_background_level = 1,
	diagnostic_text_highlight = true,
	diagnostic_virtual_text = "coloured",
	colours_override = function(palette)
		palette.bg0 = "#1A1A22"
	end,
})
vim.o.background = "dark"
-- Give every floating window (oil, hover, diagnostics, LSP popups...) the
-- snacks picker look: transparent background with a line-only grey border.
-- everforest fills NormalFloat/FloatBorder with a solid background instead.
-- Re-applied on :colorscheme because it clears these groups.
local function float_like_picker()
	vim.api.nvim_set_hl(0, "NormalFloat", { link = "SnacksPicker" })
	vim.api.nvim_set_hl(0, "FloatBorder", { link = "SnacksPickerBorder" })
	vim.api.nvim_set_hl(0, "FloatTitle", { link = "SnacksPickerTitle" })
	-- Snacks notifier colors its border/title/footer with Diagnostic*, which
	-- everforest gives a background (diagnostic_text_highlight). Use the
	-- fg-only DiagnosticSign* groups so notifications stay transparent too.
	for _, level in ipairs({ "Error", "Warn", "Info", "Debug", "Trace" }) do
		local sign = ({ Error = "Error", Warn = "Warn", Info = "Info" })[level] or "Hint"
		for _, part in ipairs({ "Border", "Title", "Footer" }) do
			vim.api.nvim_set_hl(0, "SnacksNotifier" .. part .. level, { link = "DiagnosticSign" .. sign })
		end
	end
end
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("FloatPickerLook", { clear = true }),
	callback = float_like_picker,
})
vim.cmd.colorscheme("everforest")

-- Previous theme (craftzdog). To go back, uncomment this block and comment the
-- everforest one above. The plugin stays installed in plugins/init.lua.
-- require("solarized-osaka").setup({
-- 	style = "vivid",
-- 	transparent = true,
-- })
-- vim.cmd.colorscheme("solarized-osaka")

require("mini.icons").setup()
require("mini.icons").mock_nvim_web_devicons()

-- Custom tabline setup
require("alvaldes.utils.tabline").setup()
vim.o.showtabline = 1
vim.o.tabline = "%!v:lua.require('alvaldes.utils.tabline').render()"

local dashboard_header = [[
             🬞🬹🬹🬹🬏
            🬵█████🬱
           🬷███████🬺🬏
         🬞🬻███🬆 🬊████🬱
        🬵████🬆   🬁🬬███🬺🬏
      🬞🬻███🬝🬀      🬊████🬱
     🬦████🬆         🬁🬬███🬲
    🬵████🬲🬭🬭🬭🬭🬭🬭🬭🬭    🬊███🬺🬏   🬞🬭🬭🬭
   🬉██████████████▌    🬊████🬱 🬵████🬄
     🬂🬂🬂🬂🬂🬂🬂🬂🬂🬂🬂🬂       🬁🬬███████🬝🬀
🬞🬹███████████████🬺🬏       🬊█████🬆
 🬊🬎🬎🬎🬎🬎🬎🬎🬎🬎🬎🬎🬎🬎🬎🬎🬎🬀        🬁🬎🬎🬎🬀
]]

-- Snacks centers each header line on its own, so every line must share the
-- same width or the art gets skewed. Pad at runtime instead of relying on
-- trailing spaces that editors/formatters may strip.
local function pad_lines(text)
	local lines = vim.split(text, "\n", { trimempty = true })
	local width = 0
	for _, l in ipairs(lines) do
		width = math.max(width, vim.fn.strdisplaywidth(l))
	end
	for i, l in ipairs(lines) do
		lines[i] = l .. string.rep(" ", width - vim.fn.strdisplaywidth(l))
	end
	return table.concat(lines, "\n")
end

-- Dashboard logo: render the real PNG through the kitty graphics protocol when
-- the terminal supports it, otherwise fall back to the ASCII header above.
local logo_svg = vim.fn.stdpath("config") .. "/assets/logo.svg"
-- Hex color like "#7fb4ca"; nil follows the theme's SnacksDashboardHeader fg.
local logo_color = nil ---@type string?
local logo_rows = 12

-- Recolor the SVG and rasterize it to a transparent PNG in the cache. We
-- convert it ourselves because snacks' default SVG conversion has no
-- `-background none`, so ImageMagick fills the background with white. The
-- color is part of the filename so each color is converted only once.
local function logo_file()
	local color = logo_color
	if not color then
		local fg = vim.api.nvim_get_hl(0, { name = "SnacksDashboardHeader", link = false }).fg
		color = fg and string.format("#%06x", fg) or "#ededee"
	end
	-- Bump the version suffix whenever the conversion changes, to skip stale PNGs.
	local out = ("%s/dashboard-logo-v2-%s.png"):format(vim.fn.stdpath("cache"), (color:gsub("#", "")))
	if vim.uv.fs_stat(out) then
		return out
	end
	local f = io.open(logo_svg, "r")
	if not f then
		return nil
	end
	local svg = f:read("*a"):gsub("fill:#ededee", "fill:" .. color)
	f:close()
	-- The viewBox hugs the shapes, so the rounded ends touch the canvas edge and
	-- get clipped flat; a transparent border keeps them whole.
	local res = vim.system({
		"magick",
		"-background",
		"none",
		"-density",
		"192",
		"svg:-",
		"-bordercolor",
		"none",
		"-border",
		"3%",
		"png:" .. out,
	}, { stdin = svg })
		:wait()
	return res.code == 0 and vim.uv.fs_stat(out) and out or nil
end
local logo_win ---@type integer?

-- Columns that keep the logo's 822.57x691.32 aspect at `logo_rows` tall, using
-- the terminal's real cell size (Ghostty cells are ~2.5x taller than wide).
local function logo_cols()
	local size = Snacks.image.terminal.size()
	local ratio = size.cell_height / size.cell_width
	return math.floor(logo_rows * ratio * 822.57 / 691.32 + 0.5)
end

local function close_logo()
	if logo_win and vim.api.nvim_win_is_valid(logo_win) then
		vim.api.nvim_win_close(logo_win, true)
	end
	logo_win = nil
end

local function logo_section()
	local file = Snacks.image.supports_terminal() and logo_file()
	if not file then
		return { section = "header" }
	end
	return {
		-- Reserve the rows; the image is drawn in a float on top of them.
		text = ("\n"):rep(logo_rows - 1),
		-- Same gap below the logo as the ASCII header section.
		padding = 2,
		render = function(dash, pos)
			close_logo()
			local cols = logo_cols()
			-- Snacks draws the image as `logo_rows` virt_lines *below* buffer line 1,
			-- so the float needs one extra row, shifted up so that empty line sits
			-- on the gap above the logo instead of pushing the last row out.
			local buf = vim.api.nvim_create_buf(false, true)
			logo_win = vim.api.nvim_open_win(buf, false, {
				relative = "win",
				win = dash.win,
				bufpos = { pos[1] - 1, pos[2] + 1 },
				row = -1,
				col = math.max(math.floor((dash.opts.width - cols) / 2), 0),
				width = cols,
				height = logo_rows + 1,
				focusable = false,
				noautocmd = true,
				style = "minimal",
				border = "none",
				zindex = Snacks.config.styles.dashboard.zindex + 1,
			})
			vim.wo[logo_win].winhighlight = "Normal:SnacksDashboardNormal"
			vim.bo[buf].bufhidden = "wipe"
			Snacks.image.placement.new(buf, file, {
				pos = { 1, 0 },
				inline = true,
				width = cols,
				height = logo_rows,
			})
			vim.api.nvim_create_autocmd({ "BufWipeout", "BufHidden" }, {
				buffer = dash.buf,
				once = true,
				callback = close_logo,
			})
		end,
	}
end

require("snacks").setup({
	dashboard = {
		enabled = true,
		sections = {
			logo_section,
			{ icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
			{ icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
			{ icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
		},
		preset = {
			header = pad_lines(dashboard_header),
			-- stylua: ignore
			---@type snacks.dashboard.Item[]
			keys = {
				{ icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
				{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
				{ icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
				{ icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
				{ icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
				{ icon = "󰒲 ", key = "u", desc = "Update Plugins", action = ":lua vim.pack.update()" },
				{ icon = " ", key = "m", desc = "Mason", action = ":Mason" },
				{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
			},
		},
	},
	indent = { enabled = true },
	scroll = { enabled = false },
	picker = {
		enabled = true,
		sources = {
			files = { hidden = true },
			grep = { hidden = true },
		},
	},
	notifier = { enabled = true },
	statuscolumn = { enabled = true },
	words = { enabled = true },
	lazygit = {
		enabled = true,
		configure = true, -- auto-sets nvim-remote preset & syncs theme
		config = {
			-- Open files selected in lazygit in the pane it was launched from,
			-- instead of the nvim-remote preset's new tab. See utils/lazygit.lua.
			os = {
				edit = lazygit_utils.edit_command(),
				editAtLine = lazygit_utils.edit_command({ at_line = true }),
			},
		},
		theme = {
			activeBorderColor = { fg = "WarningMsg", bold = true },
		},
		-- Fullscreen: floats are transparent, so a smaller lazygit window
		-- blends into the code behind it. 0 = full width/height in snacks.win.
		win = { width = 0, height = 0, border = "none" },
	},
})

require("tiny-cmdline").setup({
	position = {
		y = "20%",
	},
})

-- Match the cmdline popup to the snacks picker: line-only border on a
-- transparent background (tiny-cmdline defaults to FloatBorder, which most
-- themes fill with a solid background). Re-applied because :colorscheme clears links.
local function link_cmdline_to_picker()
	vim.api.nvim_set_hl(0, "TinyCmdlineNormal", { link = "SnacksPicker" })
	vim.api.nvim_set_hl(0, "TinyCmdlineBorder", { link = "SnacksPickerBorder" })
	vim.api.nvim_set_hl(0, "TinyCmdlineTitle", { link = "SnacksPickerTitle" })
end
link_cmdline_to_picker()
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("CmdlinePickerLook", { clear = true }),
	callback = link_cmdline_to_picker,
})

-- Confirm prompts (cmdline type "-", e.g. :q with unsaved changes) are split by
-- ui2: the question goes to the bottom "dialog" window while the choices go to
-- tiny-cmdline's centered popup. Merge them: use the question as the popup
-- title and hide the bottom dialog. ui2 closes the dialog when the prompt ends.
-- (tiny-cmdline's `on_reposition` only fires on VimResized/TabEnter, so hook
-- CmdlineEnter instead and run after ui2/tiny-cmdline have drawn the prompt.)
vim.api.nvim_create_autocmd("CmdlineEnter", {
	group = vim.api.nvim_create_augroup("ConfirmPopup", { clear = true }),
	pattern = "-",
	callback = function()
		vim.schedule(function()
			if vim.fn.getcmdtype() ~= "-" then
				return
			end
			local ok, ui2 = pcall(require, "vim._core.ui2")
			if not ok or not ui2.wins then
				return
			end
			local dialog, cmd = ui2.wins.dialog, ui2.wins.cmd
			if not (dialog and vim.api.nvim_win_is_valid(dialog) and cmd and vim.api.nvim_win_is_valid(cmd)) then
				return
			end
			local lines = vim.api.nvim_buf_get_lines(ui2.bufs.dialog, 0, -1, false)
			local question = vim.trim(table.concat(lines, " "))
			if question == "" then
				return
			end
			pcall(vim.api.nvim_win_set_config, cmd, { title = " " .. question .. " ", title_pos = "center" })
			pcall(vim.api.nvim_win_set_config, dialog, { hide = true })
			-- `:redraw` is a no-op while the prompt waits for a key; flush like ui2 does
			vim.api.nvim__redraw({ flush = true })
		end)
	end,
})

require("lualine").setup({
	options = {
		theme = "auto",
		globalstatus = true,
		disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
		refresh = {
			events = {
				"WinEnter",
				"BufEnter",
				"BufWritePost",
				"SessionLoadPost",
				"FileChangedShellPost",
				"VimResized",
				"Filetype",
				"CursorMoved",
				"CursorMovedI",
				"ModeChanged",
				-- Macro
				"RecordingEnter",
				"RecordingLeave",
			},
		},
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch" },

		lualine_c = {
			lualine_utils.root_dir(),
			{ "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
			{
				lualine_utils.pretty_path({
					length = 0,
					relative = "cwd",
					modified_hl = "MatchParen",
					directory_hl = "",
					filename_hl = "Bold",
					modified_sign = "",
					readonly_icon = " 󰌾 ",
				}),
			},
		},
		lualine_x = {
			lualine_utils.macro_recording(),
			{
				"diagnostics",
				symbols = {
					error = icons.diagnostics.Error,
					warn = icons.diagnostics.Warn,
					info = icons.diagnostics.Info,
					hint = icons.diagnostics.Hint,
				},
			},
			{
				"diff",
				symbols = {
					added = icons.git.added,
					modified = icons.git.modified,
					removed = icons.git.removed,
				},
				source = function()
					local gitsigns = vim.b.gitsigns_status_dict
					if gitsigns then
						return {
							added = gitsigns.added,
							modified = gitsigns.changed,
							removed = gitsigns.removed,
						}
					end
				end,
			},
		},
		lualine_y = {
			{ "progress", separator = " ", padding = { left = 1, right = 1 } },
		},
		lualine_z = {
			{ "location", padding = { left = 1, right = 1 } },
		},
	},
})

require("incline").setup({
	window = {
		margin = { vertical = 0, horizontal = 1 },
		zindex = 10,
	},
	hide = {
		cursorline = "smart",
	},
	render = function(props)
		local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
		if vim.bo[props.buf].modified then
			filename = "[+] " .. filename
		end

		local icon, hl = MiniIcons.get("file", filename)
		return { { icon, group = hl }, { " " }, { filename } }
	end,
})

require("codediff").setup({
	explorer = {
		width = 50,
		auto_open_on_cursor = true,
		view_mode = "tree", -- "list" or "tree"
		line_stats = {
			enabled = true,
		},
	},
	diff = {
		compact = true,
		compact_context_lines = 8,
		compact_sync_folds = true, -- open/close folds in both panes together
	},
	keymaps = {
		view = {},
	},
})

vim.diagnostic.config({
	underline = true,
	update_in_insert = false,
	virtual_text = {
		spacing = 4,
		source = "if_many",
		prefix = "●",
		format = function(diagnostic)
			return string.format("%s (%s: %s)", diagnostic.message, diagnostic.source, diagnostic.code)
		end,
	},
	severity_sort = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
			[vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
			[vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
			[vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
		},
	},
})
