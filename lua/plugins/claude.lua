-- ============================================================================
-- CLAUDE CODE INTEGRATION
-- ============================================================================

local terminal = require("plugins.terminal")
local terminal_state = terminal.terminal_state

local function run_claude_command(command)
	if not terminal_state.win or not vim.api.nvim_win_is_valid(terminal_state.win) then
		vim.notify("Terminal window not valid", vim.log.levels.ERROR)
		return
	end

	if not terminal_state.buf or not vim.api.nvim_buf_is_valid(terminal_state.buf) then
		vim.notify("Terminal buffer not valid", vim.log.levels.ERROR)
		return
	end

	-- Run the command in the terminal window context
	vim.api.nvim_win_call(terminal_state.win, function()
		-- Check if buffer has content and clear if needed
		local lines = vim.api.nvim_buf_get_lines(terminal_state.buf, 0, -1, false)
		local has_content = false
		for _, line in ipairs(lines) do
			if line ~= "" then
				has_content = true
				break
			end
		end

		if has_content then
			-- Clear the buffer by deleting all lines
			vim.api.nvim_buf_set_lines(terminal_state.buf, 0, -1, false, {})
		end

		-- Run the terminal command
		vim.fn.termopen("claude " .. command, {
			detached = false,
			on_exit = function(job_id, exit_code, event_type)
				if exit_code ~= 0 then
					vim.notify("Claude Code command failed with exit code " .. exit_code, vim.log.levels.ERROR)
				end
			end,
		})
		vim.cmd("startinsert")
	end)
end

local function open_claude_terminal()
	if not terminal_state.buf or not vim.api.nvim_buf_is_valid(terminal_state.buf) then
		terminal_state.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[terminal_state.buf].bufhidden = "hide"
	end

	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	terminal_state.win = vim.api.nvim_open_win(terminal_state.buf, true, {
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

	run_claude_command("")

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

-- Run Claude Code with current file as context
local function claude_with_file()
	local file_path = vim.fn.expand("%:p")
	if file_path == "" or file_path:match("^term://") then
		vim.notify("No valid file to send to Claude", vim.log.levels.WARN)
		return
	end

	if not terminal_state.buf or not vim.api.nvim_buf_is_valid(terminal_state.buf) then
		terminal_state.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[terminal_state.buf].bufhidden = "hide"
	end

	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	terminal_state.win = vim.api.nvim_open_win(terminal_state.buf, true, {
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

	run_claude_command("--file " .. file_path)

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

-- Run Claude Code with visual selection
local function claude_with_selection()
	-- Get visual selection marks
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")

	local start_line = start_pos[2]
	local start_col = start_pos[3]
	local end_line = end_pos[2]
	local end_col = end_pos[3]

	-- Validate marks are set
	if start_line == 0 or end_line == 0 then
		vim.notify("No visual selection found", vim.log.levels.WARN)
		return
	end

	-- Get the lines from the buffer
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

	if #lines == 0 then
		vim.notify("No selection to send to Claude", vim.log.levels.WARN)
		return
	end

	-- Handle partial line selection
	if #lines == 1 then
		-- Single line selection
		lines[1] = string.sub(lines[1], start_col, end_col)
	else
		-- Multi-line selection
		lines[1] = string.sub(lines[1], start_col)
		lines[#lines] = string.sub(lines[#lines], 1, end_col)
	end

	local selected_text = table.concat(lines, "\n")

	-- Check if selected_text is valid
	if not selected_text or selected_text:match("^%s*$") then
		vim.notify("No valid selection to send to Claude", vim.log.levels.WARN)
		return
	end

	if not terminal_state.buf or not vim.api.nvim_buf_is_valid(terminal_state.buf) then
		terminal_state.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[terminal_state.buf].bufhidden = "hide"
	end

	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	terminal_state.win = vim.api.nvim_open_win(terminal_state.buf, true, {
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

	-- Escape single quotes in the selected text for shell safety
	local escaped_text = selected_text:gsub("'", "'\\''")
	run_claude_command("--message '" .. escaped_text .. "'")

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

-- Keybindings for Claude Code integration
vim.keymap.set("n", "<leader>cc", open_claude_terminal, { noremap = true, silent = true, desc = "Open Claude Code terminal" })
vim.keymap.set("n", "<leader>cf", claude_with_file, { noremap = true, silent = true, desc = "Claude Code with current file" })
vim.keymap.set("v", "<leader>cs", "<cmd>lua vim.lua_claude_with_selection()<CR>", { noremap = true, silent = true, desc = "Claude Code with selection" })

-- Make function globally accessible for visual mode mapping
_G.lua_claude_with_selection = claude_with_selection
