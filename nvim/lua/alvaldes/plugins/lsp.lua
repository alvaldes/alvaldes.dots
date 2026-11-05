require("mason").setup()
require("mason-tool-installer").setup({
	ensure_installed = {
		"lua-language-server",
		"prettier",
		"prettierd",
		"selene",
		"shellcheck",
		"shfmt",
		"stylua",
		"eslint-lsp",
		"biome",
		"tailwindcss-language-server",
		"vtsls",
		"copilot-language-server",
		"angular-language-server",
		"astro-language-server",
		"css-lsp",
		"html-lsp",
		"marksman",
		"json-lsp",
		"yaml-language-server",
	},
	auto_update = false,
	run_on_start = true,
})

local capabilities = {
	workspace = {
		fileOperations = {
			didRename = true,
			willRename = true,
		},
	},
}
vim.lsp.config("*", {
	capabilities = require("blink.cmp").get_lsp_capabilities(capabilities),
})

vim.lsp.enable({
	"eslint",
	"biome",
	"lua_ls",
	"cssls",
	"vtsls",
	"tailwindcss",
	"angularls",
	"astro",
	"jsonls",
	"yamlls",
	"html",
	"marksman",
})
