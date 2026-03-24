-- ============================================================================
-- FZF-LUA CONFIG
-- ============================================================================

require("fzf-lua").setup({
	"default",
	fzf_opts = {
		["--info"] = "inline-right",
	},
	winopts = {
		height = 0.9,
		width = 0.9,
		preview = {
			layout = "flex",
			vertical = "right:55%",
			horizontal = "down:40%",
		},
	},
	files = {
		prompt = "Files> ",
	},
	grep = {
		prompt = "Search> ",
	},
})

vim.keymap.set("n", "<leader>ff", function()
	require("fzf-lua").files()
end, { desc = "FZF Files" })
vim.keymap.set("n", "<leader>fg", function()
	require("fzf-lua").live_grep()
end, { desc = "FZF Live Grep" })
vim.keymap.set("n", "<leader>fb", function()
	require("fzf-lua").buffers()
end, { desc = "FZF Buffers" })
vim.keymap.set("n", "<leader>fh", function()
	require("fzf-lua").help_tags()
end, { desc = "FZF Help Tags" })
vim.keymap.set("n", "<leader>fx", function()
	require("fzf-lua").diagnostics_document()
end, { desc = "FZF Diagnostics Document" })
vim.keymap.set("n", "<leader>fX", function()
	require("fzf-lua").diagnostics_workspace()
end, { desc = "FZF Diagnostics Workspace" })
vim.keymap.set("n", "<leader>fe", function()
	require("fzf-lua").builtin({ winopts = { title = " Search Everywhere " } })
end, { desc = "FZF Search Everywhere" })
