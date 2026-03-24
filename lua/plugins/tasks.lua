-- ============================================================================
-- TASK RUNNER (NODE/JS-TS FOCUSED)
-- ============================================================================

local overseer = require("overseer")

local M = {}

local function file_exists(path)
	return vim.uv.fs_stat(path) ~= nil
end

function M.project_root(path)
	local start_path = path
	if not start_path or start_path == "" then
		start_path = vim.api.nvim_buf_get_name(0)
	end
	if start_path == "" then
		start_path = vim.uv.cwd()
	end

	local package_json = vim.fs.find("package.json", { path = start_path, upward = true })[1]
	if package_json then
		return vim.fs.dirname(package_json)
	end

	local git_dir = vim.fs.find(".git", { path = start_path, upward = true, type = "directory" })[1]
	if git_dir then
		return vim.fs.dirname(git_dir)
	end

	return vim.uv.cwd()
end

function M.detect_package_manager(root)
	if file_exists(root .. "/pnpm-lock.yaml") then
		return "pnpm"
	end
	if file_exists(root .. "/yarn.lock") then
		return "yarn"
	end
	if file_exists(root .. "/bun.lock") or file_exists(root .. "/bun.lockb") then
		return "bun"
	end
	return "npm"
end

function M.read_scripts(root)
	local package_path = root .. "/package.json"
	if not file_exists(package_path) then
		return {}
	end

	local lines = vim.fn.readfile(package_path)
	if not lines or #lines == 0 then
		return {}
	end

	local ok, package_json = pcall(vim.json.decode, table.concat(lines, "\n"))
	if not ok or type(package_json) ~= "table" then
		return {}
	end

	if type(package_json.scripts) ~= "table" then
		return {}
	end

	return package_json.scripts
end

function M.run_script(script_name, opts)
	local options = opts or {}
	local root = options.root or M.project_root(options.path)
	local scripts = M.read_scripts(root)

	if not scripts[script_name] then
		vim.notify("No script named '" .. script_name .. "' in " .. root .. "/package.json", vim.log.levels.WARN)
		return
	end

	local manager = M.detect_package_manager(root)
	local args = { "run", script_name }

	local task = overseer.new_task({
		cmd = manager,
		args = args,
		cwd = root,
		name = "Run " .. script_name,
		components = { "default" },
	})
	task:start()
end

function M.run_named(task_name)
	local root = M.project_root()
	local scripts = M.read_scripts(root)
	local candidates = {
		dev = { "dev", "start" },
		build = { "build" },
		test = { "test" },
		lint = { "lint" },
	}

	for _, script in ipairs(candidates[task_name] or {}) do
		if scripts[script] then
			M.run_script(script, { root = root })
			return
		end
	end

	vim.notify("No matching script for task '" .. task_name .. "'", vim.log.levels.WARN)
end

function M.pick_and_run_script()
	local root = M.project_root()
	local scripts = M.read_scripts(root)
	local names = {}

	for name in pairs(scripts) do
		table.insert(names, name)
	end

	table.sort(names)

	if #names == 0 then
		vim.notify("No scripts found in " .. root .. "/package.json", vim.log.levels.WARN)
		return
	end

	vim.ui.select(names, { prompt = "Run package script" }, function(choice)
		if choice then
			M.run_script(choice, { root = root })
		end
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

vim.keymap.set("n", "<leader>rr", M.pick_and_run_script, { desc = "Run script picker" })
vim.keymap.set("n", "<leader>rd", function()
	M.run_named("dev")
end, { desc = "Run dev script" })
vim.keymap.set("n", "<leader>rb", function()
	M.run_named("build")
end, { desc = "Run build script" })
vim.keymap.set("n", "<leader>rt", function()
	M.run_named("test")
end, { desc = "Run test script" })
vim.keymap.set("n", "<leader>rl", function()
	M.run_named("lint")
end, { desc = "Run lint script" })
vim.keymap.set("n", "<leader>rp", function()
	overseer.toggle({ direction = "right" })
end, { desc = "Toggle task list" })

return M
