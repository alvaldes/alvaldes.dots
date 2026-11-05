gh = function(x)
	return "https://github.com/" .. x
end

vim.pack.add({
	-- UI
	{ src = gh("neanias/everforest-nvim") },
	{ src = gh("craftzdog/solarized-osaka.nvim") }, -- previous theme, kept for switching back
	{ src = gh("nvim-mini/mini.icons") },
	{ src = gh("folke/snacks.nvim") },
	{ src = gh("folke/trouble.nvim") },
	{ src = gh("nvim-lualine/lualine.nvim") },
	{ src = gh("b0o/incline.nvim") },
	{ src = gh("esmuellert/codediff.nvim") },
	{ src = gh("rachartier/tiny-cmdline.nvim") },
	-- Editor
	{ src = gh("stevearc/conform.nvim") },
	{ src = gh("nvim-treesitter/nvim-treesitter") },
	{ src = gh("nvim-treesitter/nvim-treesitter-textobjects"), version = "main" },
	{ src = gh("windwp/nvim-ts-autotag") },
	{ src = gh("nvim-mini/mini.pairs") },
	{ src = gh("nvim-mini/mini.ai") },
	{ src = gh("nvim-mini/mini.surround") },
	{ src = gh("folke/flash.nvim") },
	{ src = gh("folke/which-key.nvim") },
	{ src = gh("craftzdog/mini.diff"), version = "feat/grouping" },
	{ src = gh("saghen/blink.cmp"), version = vim.version.range("^1") },
	{ src = gh("folke/todo-comments.nvim") },
	{ src = gh("lewis6991/gitsigns.nvim") },
	{ src = gh("linrongbin16/gitlinker.nvim") },
	{ src = gh("brenoprata10/nvim-highlight-colors") },
	-- LSP
	{ src = gh("neovim/nvim-lspconfig") },
	{ src = gh("mason-org/mason.nvim") },
	{ src = gh("WhoIsSethDaniel/mason-tool-installer.nvim") },
	{ src = gh("b0o/SchemaStore.nvim") },
	-- Util
	{ src = gh("stevearc/oil.nvim") },
	{ src = gh("zbirenbaum/copilot.lua") },
})

if #vim.api.nvim_get_runtime_file("lua/alvaldes/plugins/local.lua", false) > 0 then
	require("alvaldes.plugins.local")
end

require("alvaldes.plugins.ui")
require("alvaldes.plugins.treesitter")
require("alvaldes.plugins.editor")
require("alvaldes.plugins.lsp")
require("alvaldes.plugins.util")
require("alvaldes.plugins.keymaps")
