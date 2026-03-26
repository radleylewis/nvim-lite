-- ============================================================================
-- NAVIGATION + IDE ERGONOMICS
-- ============================================================================

local autocmds = require("core.autocommands")
local augroup = autocmds.augroup
local fzf = require("fzf-lua")
local language_registry = require("languages")
local tooling = require("core.tooling")

require("inc_rename").setup({ preview_empty_name = false })

require("refactoring").setup({})

require("trouble").setup({
	auto_close = true,
	auto_refresh = true,
	focus = true,
	warn_no_results = false,
})

local aerial = require("aerial")
aerial.setup({
	backends = { "lsp", "treesitter", "markdown", "man" },
	show_guides = true,
	layout = {
		default_direction = "right",
		max_width = { 40, 0.25 },
		min_width = 28,
	},
	filter_kind = false,
})

vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
	group = augroup,
	callback = function(args)
		if vim.bo[args.buf].buftype ~= "" then
			return
		end

		local ok, breadcrumb = pcall(aerial.get_location)
		if not ok or not breadcrumb or breadcrumb == "" then
			return
		end

		if type(breadcrumb) == "table" then
			local parts = {}
			for _, symbol in ipairs(breadcrumb) do
				if symbol.name and symbol.name ~= "" then
					table.insert(parts, symbol.name)
				end
			end
			breadcrumb = table.concat(parts, " > ")
		end

		if type(breadcrumb) ~= "string" or breadcrumb == "" then
			return
		end

		vim.wo[0].winbar = "%=" .. breadcrumb
	end,
})

local function rename_symbol()
	local current = vim.fn.expand("<cword>")
	if current == "" then
		vim.notify("No symbol under cursor", vim.log.levels.WARN)
		return
	end

	vim.cmd("IncRename " .. current)
end

local function go_to_class()
	local query = vim.fn.input("Go to class: ")
	fzf.lsp_workspace_symbols({ query = query })
end

local function run_refactor_menu()
	require("refactoring").select_refactor()
end

local function with_lsp(action, fn, fallback)
	local bufnr = vim.api.nvim_get_current_buf()
	local has_clients = #vim.lsp.get_clients({ bufnr = bufnr }) > 0
	if has_clients then
		fn()
		return
	end

	if type(fallback) == "function" then
		fallback()
	end

	tooling.notify_lsp_unavailable({
		action = action,
		bufnr = bufnr,
		language = language_registry.find_for_filetype(vim.bo[bufnr].filetype),
	})
end

vim.keymap.set("n", "<leader>se", function()
	fzf.builtin({ winopts = { title = " Search Everywhere " } })
end, { desc = "Search everywhere" })
vim.keymap.set("n", "<leader>fo", function()
	fzf.oldfiles()
end, { desc = "FZF old files" })
vim.keymap.set("n", "<leader>fj", function()
	fzf.jumps()
end, { desc = "FZF recent locations" })

vim.keymap.set("n", "<leader>so", function()
	aerial.toggle()
end, { desc = "Symbols outline toggle" })
vim.keymap.set("n", "<leader>sb", function()
	aerial.nav_open()
end, { desc = "Symbols breadcrumb nav" })

vim.keymap.set("n", "<leader>xx", function()
	require("trouble").toggle({ mode = "diagnostics" })
end, { desc = "Diagnostics panel toggle" })
vim.keymap.set("n", "<leader>xw", function()
	require("trouble").toggle({ mode = "diagnostics", filter = { buf = 0 } })
end, { desc = "Diagnostics panel (document)" })
vim.keymap.set("n", "<leader>xq", function()
	require("trouble").toggle({ mode = "quickfix" })
end, { desc = "Quickfix panel" })
vim.keymap.set("n", "<leader>xl", function()
	require("trouble").toggle({ mode = "loclist" })
end, { desc = "Location list panel" })

vim.keymap.set("n", "<leader>jf", function()
	fzf.files()
end, { desc = "IDE go to file" })
vim.keymap.set("n", "<leader>jc", function()
	with_lsp("IDE go to class", go_to_class)
end, { desc = "IDE go to class" })
vim.keymap.set("n", "<leader>js", function()
	with_lsp("IDE go to symbol", function()
		fzf.lsp_document_symbols()
	end, function()
		aerial.nav_open()
	end)
end, { desc = "IDE go to symbol" })
vim.keymap.set("n", "<leader>ju", function()
	with_lsp("IDE find usages", function()
		fzf.lsp_references()
	end)
end, { desc = "IDE find usages" })
vim.keymap.set("n", "<leader>jr", function()
	with_lsp("IDE rename", rename_symbol)
end, { desc = "IDE rename" })
vim.keymap.set("n", "<leader>jm", run_refactor_menu, { desc = "IDE refactor menu" })

vim.keymap.set({ "n", "x" }, "<leader>re", function()
	require("refactoring").refactor("Extract Function")
end, { desc = "Refactor extract function" })
vim.keymap.set({ "n", "x" }, "<leader>rv", function()
	require("refactoring").refactor("Extract Variable")
end, { desc = "Refactor extract variable" })
vim.keymap.set({ "n", "x" }, "<leader>rm", run_refactor_menu, { desc = "Refactor menu" })

return {
	rename_symbol = rename_symbol,
}
