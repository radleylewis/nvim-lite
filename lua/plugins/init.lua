-- ============================================================================
-- PLUGIN MANAGEMENT (vim.pack)
-- ============================================================================
vim.pack.add({
	"https://www.github.com/lewis6991/gitsigns.nvim",
	"https://www.github.com/echasnovski/mini.nvim",
	"https://www.github.com/ibhagwan/fzf-lua",
	"https://www.github.com/nvim-tree/nvim-tree.lua",
	"https://github.com/folke/which-key.nvim",
	{ src = "https://github.com/neanias/everforest-nvim", lazy = false, priority = 1000 },
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
	},
	-- Language Server Protocols
	"https://www.github.com/neovim/nvim-lspconfig",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/mfussenegger/nvim-jdtls",
	"https://github.com/creativenull/efmls-configs-nvim",
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("1.*"),
	},
	"https://github.com/L3MON4D3/LuaSnip",
	-- Debugging
	"https://github.com/mfussenegger/nvim-dap",
	"https://github.com/rcarriga/nvim-dap-ui",
	"https://github.com/theHamsta/nvim-dap-virtual-text",
	"https://github.com/nvim-neotest/nvim-nio",
	"https://github.com/mxsdev/nvim-dap-vscode-js",
	-- Testing and tasks
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-neotest/neotest",
	"https://github.com/nvim-neotest/neotest-jest",
	"https://github.com/marilari88/neotest-vitest",
	"https://github.com/rcasia/neotest-java",
	"https://github.com/stevearc/overseer.nvim",
	-- Navigation and IDE ergonomics
	"https://github.com/stevearc/aerial.nvim",
	"https://github.com/smjonas/inc-rename.nvim",
	"https://github.com/ThePrimeagen/refactoring.nvim",
	"https://github.com/folke/trouble.nvim",
})

local function packadd(name)
	vim.cmd("packadd " .. name)
end
packadd("nvim-treesitter")
packadd("gitsigns.nvim")
packadd("mini.nvim")
packadd("fzf-lua")
packadd("nvim-tree.lua")
packadd("which-key.nvim")
packadd("everforest-nvim")
-- LSP
packadd("nvim-lspconfig")
packadd("mason.nvim")
packadd("nvim-jdtls")
packadd("efmls-configs-nvim")
packadd("blink.cmp")
packadd("LuaSnip")
-- Debugging
packadd("nvim-dap")
packadd("nvim-dap-ui")
packadd("nvim-dap-virtual-text")
packadd("nvim-nio")
packadd("nvim-dap-vscode-js")
-- Testing and tasks
packadd("plenary.nvim")
packadd("neotest")
packadd("neotest-jest")
packadd("neotest-vitest")
packadd("neotest-java")
packadd("overseer.nvim")
-- Navigation and IDE ergonomics
packadd("aerial.nvim")
packadd("inc-rename.nvim")
packadd("refactoring.nvim")
packadd("trouble.nvim")

-- ============================================================================
-- PLUGIN CONFIGS
-- ============================================================================

-- Load plugin configurations in order
require("plugins.colorscheme")
require("plugins.treesitter")
require("plugins.completion")
require("plugins.lsp")
require("plugins.nvim-tree")
require("plugins.fzf-lua")
require("plugins.mini-plugins")
require("plugins.gitsigns")
require("plugins.terminal")
require("plugins.kilo")
require("plugins.tasks")
require("plugins.dap")
require("plugins.test")
require("plugins.navigation")
require("plugins.which-key")
