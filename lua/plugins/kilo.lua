-- ============================================================================
-- KILO CLI INTEGRATION
-- ============================================================================

local terminal = require("plugins.terminal")
local terminal_state = terminal.terminal_state

local function ensure_terminal_buffer()
	if not terminal_state.buf or not vim.api.nvim_buf_is_valid(terminal_state.buf) then
		terminal_state.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[terminal_state.buf].bufhidden = "hide"
	end

	return terminal_state.buf
end

local function open_terminal_window()
	local buf = ensure_terminal_buffer()
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	terminal_state.win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	vim.wo[terminal_state.win].winblend = 0
	vim.wo[terminal_state.win].winhighlight = "Normal:FloatingTermNormal,FloatBorder:FloatingTermBorder"
	vim.api.nvim_set_hl(0, "FloatingTermNormal", { bg = "none" })
	vim.api.nvim_set_hl(0, "FloatingTermBorder", { bg = "none" })

	terminal_state.is_open = true

	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = terminal_state.buf,
		callback = function()
			if terminal_state.is_open and terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
				vim.api.nvim_win_close(terminal_state.win, false)
				terminal_state.is_open = false
			end
		end,
		once = true,
	})
end

local function clear_terminal_buffer()
	local lines = vim.api.nvim_buf_get_lines(terminal_state.buf, 0, -1, false)
	for _, line in ipairs(lines) do
		if line ~= "" then
			vim.api.nvim_buf_set_lines(terminal_state.buf, 0, -1, false, {})
			break
		end
	end
end

local function run_kilo_command(argv)
	if vim.fn.executable("kilo") ~= 1 then
		vim.notify("kilo executable not found in PATH", vim.log.levels.ERROR)
		return
	end

	if not terminal_state.win or not vim.api.nvim_win_is_valid(terminal_state.win) then
		vim.notify("Terminal window not valid", vim.log.levels.ERROR)
		return
	end

	if not terminal_state.buf or not vim.api.nvim_buf_is_valid(terminal_state.buf) then
		vim.notify("Terminal buffer not valid", vim.log.levels.ERROR)
		return
	end

	vim.api.nvim_win_call(terminal_state.win, function()
		clear_terminal_buffer()

		vim.fn.termopen(argv, {
			detached = false,
			on_exit = function(_, exit_code, _)
				if exit_code ~= 0 then
					vim.notify("Kilo command failed with exit code " .. exit_code, vim.log.levels.ERROR)
				end
			end,
		})

		vim.cmd("startinsert")
	end)
end

local function kilo_terminal()
	open_terminal_window()
	run_kilo_command({ "kilo" })
end

local function kilo_with_file()
	local file_path = vim.fn.expand("%:p")
	if file_path == "" or file_path:match("^term://") then
		vim.notify("No valid file to send to Kilo", vim.log.levels.WARN)
		return
	end

	open_terminal_window()
	run_kilo_command({ "kilo", "run", "--file", file_path, "Review this file and provide actionable recommendations." })
end

local function kilo_with_selection()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")

	local start_line = start_pos[2]
	local start_col = start_pos[3]
	local end_line = end_pos[2]
	local end_col = end_pos[3]

	if start_line == 0 or end_line == 0 then
		vim.notify("No visual selection found", vim.log.levels.WARN)
		return
	end

	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
	if #lines == 0 then
		vim.notify("No selection to send to Kilo", vim.log.levels.WARN)
		return
	end

	if #lines == 1 then
		lines[1] = string.sub(lines[1], start_col, end_col)
	else
		lines[1] = string.sub(lines[1], start_col)
		lines[#lines] = string.sub(lines[#lines], 1, end_col)
	end

	local selected_text = table.concat(lines, "\n")
	if selected_text:match("^%s*$") then
		vim.notify("No valid selection to send to Kilo", vim.log.levels.WARN)
		return
	end

	open_terminal_window()
	run_kilo_command({ "kilo", "run", "Work on this code selection:\n\n" .. selected_text })
end

vim.keymap.set("n", "<leader>cc", kilo_terminal, { noremap = true, silent = true, desc = "Open Kilo terminal" })
vim.keymap.set("n", "<leader>cf", kilo_with_file, { noremap = true, silent = true, desc = "Run Kilo with current file" })
vim.keymap.set("v", "<leader>cs", kilo_with_selection, { noremap = true, silent = true, desc = "Run Kilo with selection" })
