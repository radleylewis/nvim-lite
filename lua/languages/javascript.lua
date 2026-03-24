-- ============================================================================
-- JAVASCRIPT/TYPESCRIPT LANGUAGE CONTRIBUTIONS
-- ============================================================================

local M = {
	id = "javascript",
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_markers = { "package.json" },
}

local function file_exists(path)
	return vim.uv.fs_stat(path) ~= nil
end

local function read_scripts(root)
	local package_path = root .. "/package.json"
	if not file_exists(package_path) then
		return {}
	end

	local lines = vim.fn.readfile(package_path)
	if not lines or #lines == 0 then
		return {}
	end

	local ok, package_json = pcall(vim.json.decode, table.concat(lines, "\n"))
	if not ok or type(package_json) ~= "table" or type(package_json.scripts) ~= "table" then
		return {}
	end

	return package_json.scripts
end

local function detect_package_manager(root)
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

local function pick_args()
	local input = vim.fn.input("Arguments: ")
	if input == "" then
		return {}
	end
	return vim.split(input, " ", { trimempty = true })
end

M.lsp = {
	servers = {
		ts_ls = {},
	},
}

M.dap = {
	setup = function(ctx)
		require("dap-vscode-js").setup({
			debugger_cmd = { "js-debug-adapter" },
			adapters = { "pwa-node", "node-terminal", "pwa-chrome", "pwa-msedge", "pwa-extensionHost" },
		})

		local dap = ctx.dap
		local task_runner = ctx.task_runner
		local js_configurations = {
			{
				type = "pwa-node",
				request = "launch",
				name = "Debug current file",
				cwd = function()
					return task_runner.project_root()
				end,
				program = "${file}",
				runtimeExecutable = "node",
				sourceMaps = true,
				skipFiles = { "<node_internals>/**", "${workspaceFolder}/node_modules/**" },
				console = "integratedTerminal",
			},
			{
				type = "pwa-node",
				request = "launch",
				name = "Debug current file (with args)",
				cwd = function()
					return task_runner.project_root()
				end,
				program = "${file}",
				args = pick_args,
				runtimeExecutable = "node",
				sourceMaps = true,
				skipFiles = { "<node_internals>/**", "${workspaceFolder}/node_modules/**" },
				console = "integratedTerminal",
			},
			{
				type = "pwa-node",
				request = "attach",
				name = "Attach to process",
				cwd = function()
					return task_runner.project_root()
				end,
				processId = require("dap.utils").pick_process,
				skipFiles = { "<node_internals>/**", "${workspaceFolder}/node_modules/**" },
			},
		}

		for _, filetype in ipairs(M.filetypes) do
			dap.configurations[filetype] = js_configurations
		end
	end,
}

M.test = {
	adapters = function(ctx)
		return {
			require("neotest-jest")({
				jestCommand = "npm test --",
				cwd = ctx.project_root,
			}),
			require("neotest-vitest")({
				cwd = ctx.project_root,
				filter_dir = function(name)
					return name ~= "node_modules" and name ~= ".git"
				end,
			}),
		}
	end,
}

M.tasks = {
	detect = function(root)
		return file_exists(root .. "/package.json")
	end,
	run_named = function(root, task_name)
		local scripts = read_scripts(root)
		local candidates = {
			dev = { "dev", "start" },
			build = { "build" },
			test = { "test" },
			lint = { "lint" },
		}

		for _, script in ipairs(candidates[task_name] or {}) do
			if scripts[script] then
				return {
					cmd = detect_package_manager(root),
					args = { "run", script },
					cwd = root,
					name = "Run " .. script,
				}
			end
		end

		return nil, "No matching script for task '" .. task_name .. "'"
	end,
	list = function(root)
		local scripts = read_scripts(root)
		local names = {}
		for name in pairs(scripts) do
			table.insert(names, name)
		end
		table.sort(names)

		local entries = {}
		for _, name in ipairs(names) do
			table.insert(entries, {
				id = name,
				label = name,
			})
		end

		return entries
	end,
	build_task = function(root, task_id)
		local scripts = read_scripts(root)
		if not scripts[task_id] then
			return nil, "No script named '" .. task_id .. "' in " .. root .. "/package.json"
		end

		return {
			cmd = detect_package_manager(root),
			args = { "run", task_id },
			cwd = root,
			name = "Run " .. task_id,
		}
	end,
	picker_prompt = "Run package script",
}

return M
