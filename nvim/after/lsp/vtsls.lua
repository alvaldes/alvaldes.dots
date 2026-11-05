local mason_pkg = function(pkg, path)
	return vim.fn.stdpath("data") .. "/mason/packages/" .. pkg .. "/" .. path
end

---@type vim.lsp.Config
return {
	on_attach = function(client)
		if client and client.server_capabilities.semanticTokensProvider then
			client.server_capabilities.semanticTokensProvider.range = false
		end
	end,
	settings = {
		complete_function_calls = true,
		vtsls = {
			enableMoveToFileCodeAction = true,
			autoUseWorkspaceTsdk = true,
			tsserver = {
				-- Let tsserver understand Angular and Astro (e.g. importing .astro files from TS)
				globalPlugins = {
					{
						name = "@angular/language-server",
						location = mason_pkg("angular-language-server", "node_modules/@angular/language-server"),
						enableForWorkspaceTypeScriptVersions = false,
					},
					{
						name = "@astrojs/ts-plugin",
						location = mason_pkg("astro-language-server", "node_modules/@astrojs/ts-plugin"),
						enableForWorkspaceTypeScriptVersions = true,
					},
				},
			},
			experimental = {
				maxInlayHintLength = 30,
				completion = {
					enableServerSideFuzzyMatch = true,
				},
			},
		},
		typescript = {
			updateImportsOnFileMove = { enabled = "always" },
			suggest = {
				completeFunctionCalls = true,
			},
			preferences = {
				useAliasesForRenames = false,
			},
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
