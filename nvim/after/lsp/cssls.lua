---@type vim.lsp.Config
return {
	settings = {
		-- Tailwind v4 at-rules (@theme, @apply, @custom-variant...) are handled by tailwindcss/biome
		css = { lint = { emptyRules = "ignore", unknownAtRules = "ignore" } },
		scss = { lint = { emptyRules = "ignore", unknownAtRules = "ignore" } },
		less = { lint = { emptyRules = "ignore", unknownAtRules = "ignore" } },
	},
}
