-- Completion
---@module 'blink.cmp'
---@type blink.cmp.Config
require("blink.cmp").setup({
	snippets = {
		preset = "default",
	},
	completion = {
		accept = {
			-- experimental auto-brackets support
			auto_brackets = {
				enabled = true,
			},
		},
		menu = {
			border = "none",
			draw = {
				treesitter = { "lsp" },
			},
		},
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 200,
		},
		ghost_text = {
			-- TODO: Specify AI completion
			enabled = vim.g.ai_cmp,
		},
	},

	-- sources = {
	--   -- adding any nvim-cmp sources here will enable them
	--   -- with blink.compat
	--   compat = {},
	--   default = { "lsp", "path", "snippets", "buffer" },
	-- },

	cmdline = {
		enabled = true,
		keymap = {
			preset = "cmdline",
			["<Right>"] = false,
			["<Left>"] = false,
		},
		completion = {
			list = { selection = { preselect = false } },
			menu = {
				auto_show = function(ctx)
					return vim.fn.getcmdtype() == ":"
				end,
			},
			ghost_text = { enabled = true },
		},
	},

	keymap = {
		preset = "enter",
		["<C-y>"] = { "select_and_accept", "fallback" },
	},

	appearance = {
		kind_icons = Alvaldes.icons.kinds,
	},
})

require("mini.pairs").setup({
	modes = { insert = true, command = true, terminal = false },
})

require("mini.diff").setup({
	view = {
		-- show whole reference part above whole buffer part, as in `git diff`
		overlay_style = "hunk",
	},
	mappings = {
		-- same keymaps as codediff.nvim
		goto_next = "]c",
		goto_prev = "[c",
	},
})
-- Text objects: af/if (function), ac/ic (class), ao/io (block) via treesitter
local ai = require("mini.ai")
ai.setup({
	n_lines = 500,
	custom_textobjects = {
		o = ai.gen_spec.treesitter({
			a = { "@block.outer", "@conditional.outer", "@loop.outer" },
			i = { "@block.inner", "@conditional.inner", "@loop.inner" },
		}),
		f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
		c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
		t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
	},
})

-- Surround: `s` is the window prefix in this config, so use `gs*`
require("mini.surround").setup({
	mappings = {
		add = "gsa",
		delete = "gsd",
		find = "gsf",
		find_left = "gsF",
		highlight = "gsh",
		replace = "gsr",
		update_n_lines = "gsn",
	},
})

-- Jump anywhere (`S`); also enhances f/F/t/T
require("flash").setup()

-- Auto close/rename HTML, JSX and Angular/Astro tags
require("nvim-ts-autotag").setup()

-- Keymap hints
require("which-key").setup({
	preset = "helix",
	spec = {
		{ "<leader>b", group = "buffers" },
		{ "<leader>c", group = "code / LSP" },
		{ "<leader>d", group = "diff & file history" },
		{ "<leader>g", group = "git (blame, stage, overlay)" },
		{ "<leader>y", group = "copy file path" },
		{ "<leader>m", group = "misc" },
		{ "<leader>ms", group = "spell check" },
		{ "<leader>msl", group = "spell language" },
		{ "gs", group = "surround" },
		{ "s", group = "windows & splits" },
		{ ";", group = "pickers (files, grep, git)" },
	},
})

-- Comments
require("todo-comments").setup()

-- Git integration
require("gitsigns").setup()
require("gitlinker").setup()

-- Formatting
-- Respect the project's formatter so local saves match CI:
--   biome config  -> biome
--   prettier config -> prettierd/prettier (prettierd uses the project's prettier)
--   neither        -> no formatting (no prettier defaults, no tsserver fallback)
-- Set `vim.g.prettier_needs_config = false` to format with prettier defaults anyway.
if vim.g.prettier_needs_config == nil then
	vim.g.prettier_needs_config = true
end

local prettier_configs = {
	".prettierrc",
	".prettierrc.json",
	".prettierrc.json5",
	".prettierrc.yml",
	".prettierrc.yaml",
	".prettierrc.toml",
	".prettierrc.js",
	".prettierrc.cjs",
	".prettierrc.mjs",
	".prettierrc.ts",
	".prettierrc.cts",
	".prettierrc.mts",
	"prettier.config.js",
	"prettier.config.cjs",
	"prettier.config.mjs",
	"prettier.config.ts",
	"prettier.config.cts",
	"prettier.config.mts",
}

local function has_prettier_config(ctx)
	if not vim.g.prettier_needs_config then
		return true
	end
	if vim.fs.find(prettier_configs, { path = ctx.dirname, upward = true })[1] then
		return true
	end
	-- `"prettier"` key in the nearest package.json
	local pkg = vim.fs.find("package.json", { path = ctx.dirname, upward = true })[1]
	if pkg then
		local ok, json = pcall(vim.json.decode, table.concat(vim.fn.readfile(pkg), "\n"))
		return ok and type(json) == "table" and json.prettier ~= nil
	end
	return false
end

local web_formatter = { "biome", "prettierd", "prettier", stop_after_first = true }
local web_filetypes = {
	"javascript",
	"typescript",
	"javascriptreact",
	"typescriptreact",
	"json",
	"jsonc",
	"css",
	"scss",
	"less",
	"html",
	"htmlangular",
	"astro",
	"markdown",
	"markdown.mdx",
	"yaml",
	"graphql",
}

local formatters_by_ft = {
	lua = { "stylua" },
	sh = { "shfmt" },
	fish = { "fish_indent" },
}
for _, ft in ipairs(web_filetypes) do
	formatters_by_ft[ft] = web_formatter
end

require("conform").setup({
	default_format_opts = {
		timeout_ms = 3000,
		async = false,
		quiet = false,
		lsp_format = "fallback",
	},
	formatters_by_ft = formatters_by_ft,
	formatters = {
		-- Only when the project has biome.json / biome.jsonc
		biome = { require_cwd = true },
		prettierd = { condition = function(_, ctx)
			return has_prettier_config(ctx)
		end },
		prettier = { condition = function(_, ctx)
			return has_prettier_config(ctx)
		end },
	},
	format_on_save = function(bufnr)
		if vim.b[bufnr].disable_autoformat then
			return
		end
		-- Never let tsserver/jsonls/yamlls reformat web files with their own style
		local web = vim.tbl_contains(web_filetypes, vim.bo[bufnr].filetype)
		return {
			timeout_ms = 500,
			lsp_format = web and "never" or "fallback",
		}
	end,
})

-- Colors
vim.lsp.document_color.enable(false)
require("nvim-highlight-colors").setup({
	render = "background",
	enable_hex = true,
	enable_short_hex = true,
	enable_rgb = true,
	enable_hsl = true,
	enable_hsl_without_function = true,
	enable_ansi = true,
	enable_var_usage = true,
	enable_tailwind = false,
})
