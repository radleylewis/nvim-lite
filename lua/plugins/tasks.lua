-- ============================================================================
-- TASK RUNNER (LANGUAGE ORCHESTRATOR)
-- ============================================================================

local overseer = require("overseer")
local language_registry = require("languages")

local M = {}

function M.project_root(path)
	return language_registry.project_root(path)
end

local function contains(list, value)
	for _, item in ipairs(list or {}) do
		if item == value then
			return true
		end
	end
	return false
end

local function active_task_provider(root)
	local filetype = vim.bo.filetype
	local contributions = language_registry.collect("tasks")

	for _, entry in ipairs(contributions) do
		if contains(entry.language.filetypes, filetype) then
			local detect = entry.value.detect
			if type(detect) == "function" and detect(root) then
				return entry
			end
		end
	end

	for _, entry in ipairs(contributions) do
		local detect = entry.value.detect
		if type(detect) == "function" and detect(root) then
			return entry
		end
	end

	return nil
end

local function start_task(spec)
	local task = overseer.new_task({
		cmd = spec.cmd,
		args = spec.args,
		cwd = spec.cwd,
		name = spec.name,
		components = { "default" },
	})
	task:start()
end

function M.run_named(task_name)
	local root = M.project_root()
	local provider = active_task_provider(root)
	if not provider then
		vim.notify("No language task provider found for " .. root, vim.log.levels.WARN)
		return
	end

	local run_named = provider.value.run_named
	if type(run_named) ~= "function" then
		vim.notify("Language task provider cannot run named tasks", vim.log.levels.WARN)
		return
	end

	local spec, err = run_named(root, task_name)
	if not spec then
		vim.notify(err or "Task is not available", vim.log.levels.WARN)
		return
	end

	start_task(spec)
end

function M.pick_and_run_script()
	local root = M.project_root()
	local provider = active_task_provider(root)
	if not provider then
		vim.notify("No language task provider found for " .. root, vim.log.levels.WARN)
		return
	end

	local list = provider.value.list
	local build_task = provider.value.build_task
	if type(list) ~= "function" or type(build_task) ~= "function" then
		vim.notify("Language task provider is incomplete", vim.log.levels.WARN)
		return
	end

	local entries = list(root)
	if type(entries) ~= "table" or #entries == 0 then
		vim.notify("No runnable tasks found for " .. root, vim.log.levels.WARN)
		return
	end

	vim.ui.select(entries, {
		prompt = provider.value.picker_prompt or "Run task",
		format_item = function(item)
			return item.label
		end,
	}, function(choice)
		if not choice then
			return
		end

		local spec, err = build_task(root, choice.id)
		if not spec then
			vim.notify(err or "Task is not available", vim.log.levels.WARN)
			return
		end

		start_task(spec)
	end)
end

overseer.setup({
	strategy = "jobstart",
	task_list = {
		direction = "right",
		min_width = 48,
		max_width = 72,
	},
	templates = { "builtin", "user" },
})

vim.keymap.set("n", "<leader>rr", M.pick_and_run_script, { desc = "Run task picker" })
vim.keymap.set("n", "<leader>rd", function()
	M.run_named("dev")
end, { desc = "Run dev task" })
vim.keymap.set("n", "<leader>rb", function()
	M.run_named("build")
end, { desc = "Run build task" })
vim.keymap.set("n", "<leader>rt", function()
	M.run_named("test")
end, { desc = "Run test task" })
vim.keymap.set("n", "<leader>rl", function()
	M.run_named("lint")
end, { desc = "Run lint task" })
vim.keymap.set("n", "<leader>rp", function()
	overseer.toggle({ direction = "right" })
end, { desc = "Toggle task list" })

return M
