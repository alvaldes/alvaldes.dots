---@type vim.lsp.Config
return {
	before_init = function(_, config)
		config.settings.json.schemas = require("schemastore").json.schemas()
	end,
	settings = {
		json = {
			format = { enable = false }, -- conform owns formatting
			validate = { enable = true },
		},
	},
}
