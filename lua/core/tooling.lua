-- ============================================================================
-- LANGUAGE TOOLING PROVISIONING
-- ============================================================================

local M = {}

local state = {
	in_progress = {},
	pending_callbacks = {},
}

local function join_paths(...)
	local separator = package.config:sub(1, 1)
	return table.concat({ ... }, separator)
end

local function contains(list, value)
	for _, item in ipairs(list or {}) do
		if item == value then
			return true
		end
	end
	return false
end

local function list_missing(required, status)
	local missing = {}
	for _, tool in ipairs(required or {}) do
		if not status[tool] then
			table.insert(missing, tool)
		end
	end
	return missing
end

local function uniq_tools(list)
	local seen = {}
	local out = {}
	for _, tool in ipairs(list or {}) do
		if not seen[tool] then
			seen[tool] = true
			table.insert(out, tool)
		end
	end
	return out
end

local function is_tool_installed(tool)
	local ok_registry, registry = pcall(require, "mason-registry")
	if ok_registry then
		local ok_package, package = pcall(registry.get_package, tool)
		if ok_package and package and type(package.is_installed) == "function" then
			local ok_installed, installed = pcall(package.is_installed, package)
			if ok_installed then
				return installed == true
			end
		end
	end

	local fallback_path = join_paths(vim.fn.stdpath("data"), "mason", "packages", tool)
	return vim.uv.fs_stat(fallback_path) ~= nil
end

local function normalize_language(language)
	if type(language) == "table" then
		return language
	end

	if type(language) == "string" then
		local language_registry = require("languages")
		for _, item in ipairs(language_registry.get_enabled()) do
			if item.id == language then
				return item
			end
		end
	end

	return nil
end

local function notify_install_result(language_id, success, details)
	if success then
		vim.notify("Tool installation completed for " .. language_id, vim.log.levels.INFO)
		return
	end

	local reason = details and details.reason or "unknown error"
	local level = vim.log.levels.ERROR
	if reason == "cancelled" or reason == "no tools selected" then
		level = vim.log.levels.WARN
	end
	vim.notify("Tool installation failed for " .. language_id .. ": " .. reason, level)
end

local function schedule_poll(poll, interval)
	vim.defer_fn(poll, interval)
end

local function install_selection(language, missing_tools, cb)
	local descriptions = language.tool_descriptions or {}
	local selected = {}

	for _, tool in ipairs(missing_tools) do
		local message = { "Install '" .. tool .. "'?" }
		if descriptions[tool] and descriptions[tool] ~= "" then
			table.insert(message, descriptions[tool])
		end

		local choice = vim.fn.confirm(table.concat(message, "\n"), "&Install\n&Skip\n&Cancel", 1)
		if choice == 1 then
			table.insert(selected, tool)
		elseif choice == 3 then
			cb(nil, "cancel")
			return
		end
	end

	cb(selected, nil)
end

local function finalize_callbacks(language_id, success, details)
	state.in_progress[language_id] = nil
	local callbacks = state.pending_callbacks[language_id] or {}
	state.pending_callbacks[language_id] = nil
	for _, cb in ipairs(callbacks) do
		pcall(cb, success, details)
	end
end

local function run_install(_language, tools, timeout_ms, cb)
	local ok_registry, registry = pcall(require, "mason-registry")
	if not ok_registry then
		cb(false, { reason = "mason-registry is not available" })
		return
	end

	local failed = {}
	for _, tool in ipairs(tools) do
		local ok_pkg, package = pcall(registry.get_package, tool)
		if not ok_pkg or not package then
			table.insert(failed, tool .. " (package not found)")
		else
			if type(package.on) == "function" then
				package:on("install:failed", function()
					if not contains(failed, tool) then
						table.insert(failed, tool)
					end
				end)
			end

			local ok_start, install_err = pcall(function()
				if not package:is_installed() then
					package:install()
				end
			end)
			if not ok_start then
				table.insert(failed, tool .. " (" .. tostring(install_err) .. ")")
			end
		end
	end

	if #failed == #tools then
		cb(false, { reason = table.concat(failed, ", ") })
		return
	end

	local started_at = vim.uv.now()
	local function poll()
		local status = {}
		for _, tool in ipairs(tools) do
			status[tool] = is_tool_installed(tool)
		end

		local missing = list_missing(tools, status)
		if #missing == 0 then
			cb(true, { installed = tools })
			return
		end

		if (vim.uv.now() - started_at) > timeout_ms then
			local reason = "timeout waiting for: " .. table.concat(missing, ", ")
			if #failed > 0 then
				reason = reason .. " (errors: " .. table.concat(failed, ", ") .. ")"
			end
			cb(false, { reason = reason, missing = missing })
			return
		end

		schedule_poll(poll, 600)
	end

	schedule_poll(poll, 300)
end

function M.check_language_tools(language)
	local spec = normalize_language(language)
	if not spec then
		return nil, "Unknown language"
	end

	local required_tools = uniq_tools(spec.required_tools or {})
	local optional_tools = uniq_tools(spec.optional_tools or {})
	local status = {}

	for _, tool in ipairs(required_tools) do
		status[tool] = is_tool_installed(tool)
	end
	for _, tool in ipairs(optional_tools) do
		status[tool] = is_tool_installed(tool)
	end

	local missing_required = list_missing(required_tools, status)
	local missing_optional = list_missing(optional_tools, status)

	return {
		language = spec,
		status = status,
		required_tools = required_tools,
		optional_tools = optional_tools,
		missing_required = missing_required,
		missing_optional = missing_optional,
		ready = #missing_required == 0,
	}
end

function M.prompt_install_mode(language)
	local check, err = M.check_language_tools(language)
	if not check then
		vim.notify("Unable to check tools: " .. err, vim.log.levels.ERROR)
		return "cancel"
	end

	if check.ready then
		return "defaults"
	end

	local missing = table.concat(check.missing_required, ", ")
	local prompt = "Missing required tools for "
		.. check.language.id
		.. ": "
		.. missing
		.. "\nChoose install mode"
	local choice = vim.fn.confirm(prompt, "&Interactive\n&Defaults\n&Cancel", 1)

	if choice == 1 then
		return "interactive"
	end
	if choice == 2 then
		return "defaults"
	end
	return "cancel"
end

function M.install_tools(language, mode, cb)
	local callback = cb or function() end
	local check, err = M.check_language_tools(language)
	if not check then
		callback(false, { reason = err })
		return
	end

	if check.ready then
		callback(true, { reason = "already installed" })
		return
	end

	local missing_all = vim.list_extend(vim.deepcopy(check.missing_required), check.missing_optional)
	local requested = {}

	if mode == "defaults" then
		requested = missing_all
	elseif mode == "interactive" then
		install_selection(check.language, missing_all, function(selected, select_err)
			if select_err == "cancel" then
				callback(false, { reason = "cancelled" })
				return
			end
			requested = selected or {}
			if #requested == 0 then
				callback(false, { reason = "no tools selected" })
				return
			end

			run_install(check.language, requested, 120000, callback)
		end)
		return
	else
		callback(false, { reason = "unknown mode: " .. tostring(mode) })
		return
	end

	run_install(check.language, requested, 120000, callback)
end

function M.ensure_language_ready(language, cb)
	local callback = cb or function() end
	local check, err = M.check_language_tools(language)
	if not check then
		vim.notify("Tooling check failed: " .. err, vim.log.levels.ERROR)
		callback(false)
		return
	end

	if check.ready then
		callback(true)
		return
	end

	local language_id = check.language.id
	state.pending_callbacks[language_id] = state.pending_callbacks[language_id] or {}
	table.insert(state.pending_callbacks[language_id], callback)

	if state.in_progress[language_id] then
		return
	end

	local mode = M.prompt_install_mode(check.language)
	if mode == "cancel" then
		local message = "Tooling setup cancelled for " .. language_id
		vim.notify(message, vim.log.levels.WARN)
		finalize_callbacks(language_id, false, { reason = "cancelled" })
		return
	end

	state.in_progress[language_id] = true
	M.install_tools(check.language, mode, function(success, details)
		notify_install_result(language_id, success, details)
		finalize_callbacks(language_id, success, details)
	end)
end

function M.retry_lsp_attach(bufnr, client_name, start_fn, opts)
	local options = opts or {}
	local attempts = options.attempts or 5
	local delay_ms = options.delay_ms or 450

	local function has_client()
		for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
			if client.name == client_name then
				return true
			end
		end
		return false
	end

	local function attempt(remaining)
		local ok, err = pcall(start_fn)
		if not ok then
			vim.notify(
				"Failed to attach " .. client_name .. ": " .. tostring(err),
				vim.log.levels.ERROR
			)
		end

		schedule_poll(function()
			if has_client() then
				return
			end

			if remaining <= 1 then
				vim.notify(
					"LSP attach timeout for " .. client_name .. " (buffer " .. bufnr .. ")",
					vim.log.levels.ERROR
				)
				return
			end

			attempt(remaining - 1)
		end, delay_ms)
	end

	attempt(attempts)
end

function M.notify_lsp_unavailable(opts)
	local params = opts or {}
	local bufnr = params.bufnr or vim.api.nvim_get_current_buf()
	local action = params.action or "LSP action"
	local filetype = vim.bo[bufnr].filetype

	local language = params.language
	if not language then
		local language_registry = require("languages")
		language = language_registry.find_for_filetype(filetype)
	end

	if language and type(language) == "table" then
		local check = M.check_language_tools(language)
		if check and #check.missing_required > 0 then
			vim.notify(
				action
					.. " unavailable: missing required tools for "
					.. language.id
					.. " ("
					.. table.concat(check.missing_required, ", ")
					.. "). Use :ToolingHealth or reopen file to bootstrap.",
				vim.log.levels.WARN
			)
			return
		end
	end

	vim.notify(
		action .. " unavailable: no LSP client attached for '" .. filetype .. "'",
		vim.log.levels.WARN
	)
end

local function install_for_languages(languages, mode)
	local idx = 1
	local function next_install()
		local language = languages[idx]
		if not language then
			return
		end

		idx = idx + 1
		M.install_tools(language, mode, function(success, details)
			notify_install_result(language.id, success, details)
			next_install()
		end)
	end

	next_install()
end

function M.setup()
	vim.api.nvim_create_user_command("ToolingHealth", function(command)
		local args = vim.split(vim.trim(command.args or ""), "%s+", { trimempty = true })
		local forced_mode = args[1]
		if forced_mode ~= "interactive" and forced_mode ~= "defaults" then
			forced_mode = nil
		end

		local language_filter = args[2]
		local language_registry = require("languages")
		local enabled = language_registry.get_enabled()
		local missing_languages = {}
		local lines = { "Tooling health:" }

		for _, language in ipairs(enabled) do
			if not language_filter or language.id == language_filter then
				local check = M.check_language_tools(language)
				if check then
					local status = check.ready and "ok" or "missing"
					local missing = #check.missing_required > 0 and table.concat(check.missing_required, ", ")
						or "-"
					table.insert(lines, "- " .. language.id .. ": " .. status .. " (required missing: " .. missing .. ")")
					if not check.ready then
						table.insert(missing_languages, language)
					end
				end
			end
		end

		vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)

		if #missing_languages == 0 then
			return
		end

		local mode = forced_mode
		if not mode then
			local choice = vim.fn.confirm(
				"Install missing tools now?",
				"&Interactive\n&Defaults\n&Skip",
				2
			)
			if choice == 1 then
				mode = "interactive"
			elseif choice == 2 then
				mode = "defaults"
			else
				mode = nil
			end
		end

		if mode then
			install_for_languages(missing_languages, mode)
		end
	end, {
		nargs = "*",
		desc = "Show tooling status and install missing tools",
		complete = function()
			return { "interactive", "defaults" }
		end,
	})
end

return M
