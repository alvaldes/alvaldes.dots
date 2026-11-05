---@type vim.lsp.Config
return {
	-- Only start inside Angular workspaces (angular.json / nx.json), never as a cwd fallback
	workspace_required = true,
}
