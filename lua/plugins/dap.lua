-- ============================================================================
-- DAP (LANGUAGE ORCHESTRATOR)
-- ============================================================================

local dap = require("dap")
local dapui = require("dapui")
local language_registry = require("languages")
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

for _, contribution in ipairs(language_registry.collect("dap")) do
	local dap_contribution = contribution.value
	if type(dap_contribution.setup) == "function" then
		pcall(dap_contribution.setup, {
			dap = dap,
			dapui = dapui,
			task_runner = task_runner,
			language = contribution.language,
		})
	end
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
