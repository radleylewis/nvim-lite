-- ============================================================================
-- TEST RUNNER (NEOTEST, JS/TS)
-- ============================================================================

local neotest = require("neotest")
local task_runner = require("plugins.tasks")

local function project_root(path)
	return task_runner.project_root(path)
end

neotest.setup({
	adapters = {
		require("neotest-jest")({
			jestCommand = "npm test --",
			cwd = project_root,
		}),
		require("neotest-vitest")({
			cwd = project_root,
			filter_dir = function(name)
				return name ~= "node_modules" and name ~= ".git"
			end,
		}),
	},
	quickfix = {
		enabled = true,
		open = false,
	},
	output_panel = {
		enabled = true,
		open = "botright split | resize 14",
	},
	summary = {
		enabled = true,
		follow = true,
		open = "botright vsplit | vertical resize 48",
	},
	status = {
		virtual_text = true,
	},
})

vim.keymap.set("n", "<leader>tn", function()
	neotest.run.run()
end, { desc = "Test nearest" })
vim.keymap.set("n", "<leader>tf", function()
	neotest.run.run(vim.fn.expand("%"))
end, { desc = "Test file" })
vim.keymap.set("n", "<leader>ta", function()
	neotest.run.run(project_root())
end, { desc = "Test project" })
vim.keymap.set("n", "<leader>tv", function()
	neotest.run.run({ strategy = "dap" })
end, { desc = "Test nearest (debug)" })
vim.keymap.set("n", "<leader>tl", function()
	neotest.run.run_last()
end, { desc = "Test run last" })
vim.keymap.set("n", "<leader>ts", function()
	neotest.summary.toggle()
end, { desc = "Test summary toggle" })
vim.keymap.set("n", "<leader>to", function()
	neotest.output.open({ enter = true })
end, { desc = "Test output open" })
vim.keymap.set("n", "<leader>tO", function()
	neotest.output_panel.toggle()
end, { desc = "Test output panel toggle" })

vim.keymap.set("n", "<leader>jt", function()
	neotest.run.run()
end, { desc = "IDE test nearest" })
