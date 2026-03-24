-- ============================================================================
-- TEST RUNNER (LANGUAGE ORCHESTRATOR)
-- ============================================================================

local neotest = require("neotest")
local language_registry = require("languages")
local task_runner = require("plugins.tasks")

local function project_root(path)
	return task_runner.project_root(path)
end

local function dispatch_language_test(method)
	local filetype = vim.bo.filetype
	local language = language_registry.find_for_filetype(filetype)
	if not language or not language.test then
		return false
	end

	local callback = language.test[method]
	if type(callback) ~= "function" then
		return false
	end

	local ok, handled = pcall(callback, {
		neotest = neotest,
		project_root = project_root,
		language = language,
	})

	return ok and handled == true
end

local adapters = {}
for _, contribution in ipairs(language_registry.collect("test")) do
	local test_contribution = contribution.value
	if type(test_contribution.adapters) == "function" then
		local ok, items = pcall(test_contribution.adapters, {
			project_root = project_root,
			language = contribution.language,
		})
		if ok and type(items) == "table" then
			vim.list_extend(adapters, items)
		end
	end
end

neotest.setup({
	adapters = adapters,
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
	if dispatch_language_test("run_nearest") then
		return
	end
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
	if dispatch_language_test("run_nearest") then
		return
	end
	neotest.run.run()
end, { desc = "IDE test nearest" })
