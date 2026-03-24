-- ============================================================================
-- DAP (JS/TS NODE BASELINE)
-- ============================================================================

local dap = require("dap")
local dapui = require("dapui")
local task_runner = require("plugins.tasks")

dapui.setup({
	controls = {
		enabled = true,
		element = "repl",
	},
	layouts = {
		{
			elements = {
				{ id = "scopes", size = 0.5 },
				{ id = "breakpoints", size = 0.15 },
				{ id = "stacks", size = 0.2 },
				{ id = "watches", size = 0.15 },
			},
			size = 44,
			position = "left",
		},
		{
			elements = {
				{ id = "repl", size = 0.45 },
				{ id = "console", size = 0.55 },
			},
			size = 12,
			position = "bottom",
		},
	},
})

require("nvim-dap-virtual-text").setup({
	commented = true,
	highlight_changed_variables = true,
	highlight_new_as_changed = true,
})

require("dap-vscode-js").setup({
	debugger_cmd = { "js-debug-adapter" },
	adapters = { "pwa-node", "node-terminal", "pwa-chrome", "pwa-msedge", "pwa-extensionHost" },
})

local function pick_args()
	local input = vim.fn.input("Arguments: ")
	if input == "" then
		return {}
	end
	return vim.split(input, " ", { trimempty = true })
end

local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }
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

for _, filetype in ipairs(js_filetypes) do
	dap.configurations[filetype] = js_configurations
end

dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open({ reset = true })
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close({})
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close({})
end

vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug toggle breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debug conditional breakpoint" })
vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug continue/start" })
vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Debug step into" })
vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Debug step over" })
vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Debug step out" })
vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "Debug REPL toggle" })
vim.keymap.set("n", "<leader>du", function()
	dapui.toggle({ reset = true })
end, { desc = "Debug UI toggle" })
vim.keymap.set("n", "<leader>dx", dap.terminate, { desc = "Debug terminate" })

vim.keymap.set("n", "<leader>jd", dap.continue, { desc = "IDE debug" })
