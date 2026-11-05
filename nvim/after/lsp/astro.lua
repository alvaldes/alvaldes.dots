---@type vim.lsp.Config
return {
	-- astro-ls runs its own TypeScript service, so it needs the same inlay hint settings as vtsls
	settings = {
		typescript = {
			inlayHints = {
				enumMemberValues = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
				parameterNames = { enabled = "literals" },
				parameterTypes = { enabled = true },
				propertyDeclarationTypes = { enabled = true },
				variableTypes = { enabled = false },
			},
		},
	},
}
