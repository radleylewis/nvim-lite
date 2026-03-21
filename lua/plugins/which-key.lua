-- ============================================================================
-- WHICH-KEY CONFIG
-- ============================================================================

local which_key = require("which-key")

which_key.setup({
	preset = "helix",
	defaults = {},
	spec = {
		{ "<leader><tab>", group = "tabs", mode = { "n", "x" } },
		{ "<leader>c", group = "code", mode = { "n", "x" } },
		{ "<leader>d", group = "debug", mode = { "n", "x" } },
		{ "<leader>dp", group = "profiler", mode = { "n", "x" } },
		{ "<leader>f", group = "file/find", mode = { "n", "x" } },
		{ "<leader>g", group = "git", mode = { "n", "x" } },
		{ "<leader>gh", group = "hunks", mode = { "n", "x" } },
		{ "<leader>q", group = "quit/session", mode = { "n", "x" } },
		{ "<leader>s", group = "search", mode = { "n", "x" } },
		{ "<leader>u", group = "ui", mode = { "n", "x" } },
		{ "<leader>x", group = "diagnostics/quickfix", mode = { "n", "x" } },
		{ "[", group = "prev", mode = { "n", "x" } },
		{ "]", group = "next", mode = { "n", "x" } },
		{ "g", group = "goto", mode = { "n", "x" } },
		{ "gs", group = "surround", mode = { "n", "x" } },
		{ "z", group = "fold", mode = { "n", "x" } },
		{
			"<leader>b",
			group = "buffer",
			mode = { "n", "x" },
			expand = function()
				return require("which-key.extras").expand.buf()
			end,
		},
		{
			"<leader>w",
			group = "windows",
			mode = { "n", "x" },
			proxy = "<c-w>",
			expand = function()
				return require("which-key.extras").expand.win()
			end,
		},
		{ "gx", desc = "Open with system app", mode = { "n", "x" } },
	},
})

vim.keymap.set("n", "<leader>?", function()
	which_key.show({ global = false })
end, { desc = "Buffer Keymaps (which-key)" })

vim.keymap.set("n", "<c-w><space>", function()
	which_key.show({ keys = "<c-w>", loop = true })
end, { desc = "Window Hydra Mode (which-key)" })
