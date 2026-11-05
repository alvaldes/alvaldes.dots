local keymap = vim.keymap

local map = function(keymaps)
	for _, keymap_entry in ipairs(keymaps) do
		local lhs = keymap_entry[1]
		local rhs = keymap_entry[2]
		local mode = keymap_entry.mode or "n"
		local opts = {
			desc = keymap_entry.desc,
			silent = keymap_entry.silent ~= false,
			noremap = keymap_entry.noremap ~= false,
			expr = keymap_entry.expr,
			nowait = keymap_entry.nowait,
			buffer = keymap_entry.buffer,
		}
		keymap.set(mode, lhs, rhs, opts)
	end
end

-- Oil - File explorer
map({
	{
		"-",
		function()
			require("oil").open_float(nil, { preview = {} })
		end,
		desc = "Open file explorer (Oil float)",
	},
})

-- LSP
local Snacks = require("snacks")
map({
	-- { "gd", vim.lsp.buf.definition, desc = "Goto Definition" },
	-- {
	-- 	"gr",
	-- 	vim.lsp.buf.references,
	-- 	desc = "References",
	-- 	nowait = true,
	-- },
	{
		"gI",
		function()
			local clients = vim.lsp.get_clients({ bufnr = 0, name = "vtsls" })
			if #clients > 0 then
				local params = vim.lsp.util.make_position_params(0, "utf-16")
				clients[1]:request("workspace/executeCommand", {
					command = "typescript.goToSourceDefinition",
					arguments = { params.textDocument.uri, params.position },
				}, function(err, result)
					if err then
						vim.notify("goToSourceDefinition: " .. err.message, vim.log.levels.ERROR)
						return
					end
					if result and #result > 0 then
						vim.lsp.util.show_document(result[1], "utf-16", { focus = true })
					else
						vim.notify("No source definition found", vim.log.levels.INFO)
					end
				end, 0)
			else
				vim.lsp.buf.implementation()
			end
		end,
		desc = "Go to source definition (TS) or implementation",
	},
	-- { "gy", vim.lsp.buf.type_definition, desc = "Goto T[y]pe Definition" },
	-- { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
	{
		"gd",
		function()
			Snacks.picker.lsp_definitions({ jump = { reuse_win = false } })
		end,
		desc = "Go to definition",
	},
	{ "gD", Snacks.picker.lsp_declarations, desc = "Go to declaration" },
	{ "gy", Snacks.picker.lsp_type_definitions, desc = "Go to type definition" },
	{ "gr", Snacks.picker.lsp_references, desc = "Find references" },
	{ "K", vim.lsp.buf.hover, desc = "Show hover documentation" },
	{ "gK", vim.lsp.buf.signature_help, desc = "Show signature help" },
	{
		"<c-k>",
		vim.lsp.buf.signature_help,
		desc = "Show signature help",
		mode = "i",
	},
	{
		"<c-j>",
		function()
			vim.diagnostic.jump({ count = 1, float = true })
		end,
		desc = "Next diagnostic (show details)",
		mode = "n",
	},
	{
		"<leader>ca",
		vim.lsp.buf.code_action,
		desc = "Code actions (fixes, refactors)",
		mode = { "n", "x" },
	},
	{ "<leader>cr", vim.lsp.buf.rename, desc = "Rename symbol (LSP)" },
	{
		"<leader>f",
		function()
			require("conform").format()
		end,
		desc = "Format buffer or selection",
		mode = { "n", "x" },
	},
})

-- Snacks
map({
	{ "<leader>cl", Snacks.picker.lsp_config, desc = "Show attached LSP clients" },
	{ "<leader>cR", Snacks.rename.rename_file, desc = "Rename file (updates imports)" },
	{ ";f", Snacks.picker.files, desc = "Find files in project" },
	{ ";r", Snacks.picker.grep, desc = "Search text in project (grep)" },
	{ ";;", Snacks.picker.resume, desc = "Resume last picker" },
	{
		"\\\\",
		function()
			Snacks.picker.buffers({
				confirm = function(picker, item)
					picker:close()
					if not item then
						return
					end
					-- If the buffer is already shown in a window (any tab),
					-- jump to that window instead of opening it here.
					vim.schedule(function()
						for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
							for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
								if vim.api.nvim_win_get_buf(win) == item.buf then
									vim.api.nvim_set_current_tabpage(tab)
									vim.api.nvim_set_current_win(win)
									return
								end
							end
						end
						vim.api.nvim_set_current_buf(item.buf)
					end)
				end,
			})
		end,
		desc = "Switch buffer (reuses open window)",
	},
	{ ";e", Snacks.picker.diagnostics, desc = "List diagnostics" },
	{ ";c", Snacks.picker.lsp_incoming_calls, desc = "Show incoming calls (who calls this)" },
	{ ";n", Snacks.picker.notifications, desc = "Notification history" },
	{
		";g",
		function()
			require("alvaldes.utils.lazygit").open()
		end,
		desc = "Open Lazygit",
	},
	{
		";h",
		Snacks.picker.git_diff,
		desc = "Browse changed hunks (git diff)",
	},
	{
		"]]",
		function()
			Snacks.words.jump(vim.v.count1)
		end,
		desc = "Next reference to word under cursor",
		mode = { "n", "t" },
	},
	{
		"[[",
		function()
			Snacks.words.jump(-vim.v.count1)
		end,
		desc = "Previous reference to word under cursor",
		mode = { "n", "t" },
	},
})

-- Gitsigns
map({
	{
		"<leader>gb",
		function()
			require("gitsigns").blame_line()
		end,
		desc = "Show blame for current line",
	},
	{
		"<leader>gB",
		function()
			require("gitsigns").blame()
		end,
		desc = "Show blame for whole file",
	},
	{
		"<leader>go",
		function()
			local async = require("gitsigns.async")
			local cache = require("gitsigns.cache").cache

			async.run(function()
				local bufnr = vim.api.nvim_get_current_buf()
				local lnum = vim.api.nvim_win_get_cursor(0)[1]
				local bcache = cache[bufnr]
				if not bcache then
					return
				end

				bcache:get_blame(lnum)
				local blame = bcache.blame
				if not blame or not blame.entries or not blame.entries[lnum] then
					return
				end

				local info = blame.entries[lnum]
				local sha = info.commit.sha

				-- Check if uncommitted (sha is all zeros)
				if tonumber("0x" .. sha:sub(1, 8)) == 0 then
					vim.notify("Line not committed yet", vim.log.levels.WARN)
					return
				end

				vim.cmd.tabnew()
				require("gitsigns.actions.diffthis").show(bufnr, sha, info.filename)
				async.schedule()
				pcall(vim.api.nvim_win_set_cursor, 0, { info.orig_lnum or lnum, 0 })
			end)
		end,
		desc = "Diff against commit of this line (new tab)",
	},
	{
		"<leader>gs",
		function()
			local gs = require("gitsigns")
			if #(gs.get_hunks() or {}) > 0 then
				gs.stage_buffer()
			else
				gs.reset_buffer_index()
			end
		end,
		desc = "Stage or unstage whole file",
	},
	{
		"<leader>gh",
		function()
			require("gitsigns").stage_hunk()
		end,
		desc = "Stage or unstage hunk under cursor",
	},
})

-- MiniDiff
map({
	{
		"<leader>gd",
		function()
			local MiniDiff = require("mini.diff")
			MiniDiff.toggle_overlay()
		end,
		desc = "Toggle inline diff overlay",
	},
})

-- Flash (`s` is the window prefix here, so jump lives on `S`)
map({
	{ "S", function() require("flash").jump() end, mode = { "n", "x", "o" }, desc = "Jump to any visible location (Flash)" },
	{ "r", function() require("flash").remote() end, mode = "o", desc = "Operate on a remote location (Flash)" },
	{ "R", function() require("flash").treesitter_search() end, mode = { "o", "x" }, desc = "Select treesitter node (Flash)" },
	{ "<C-s>", function() require("flash").toggle() end, mode = "c", desc = "Toggle Flash labels in search" },
	{ "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Show buffer-local keymaps" },
})

-- CodeDiff
map({
	{ "<leader>dv", "<cmd>CodeDiff<cr>", desc = "Toggle side-by-side diff (CodeDiff)" },
	-- File history
	{ "<leader>dh", "<cmd>CodeDiff history %<cr>", desc = "Commit history of this file" },
	{ "<leader>dH", "<cmd>CodeDiff history<cr>", desc = "Commit history of the repo" },
})
