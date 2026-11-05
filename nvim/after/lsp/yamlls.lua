---@type vim.lsp.Config
return {
	before_init = function(_, config)
		config.settings.yaml.schemas = require("schemastore").yaml.schemas()
	end,
	settings = {
		redhat = { telemetry = { enabled = false } },
		yaml = {
			keyOrdering = false,
			format = { enable = false }, -- conform owns formatting
			validate = true,
			-- Disable the built-in store; SchemaStore.nvim provides the schemas
			schemaStore = { enable = false, url = "" },
		},
	},
}
