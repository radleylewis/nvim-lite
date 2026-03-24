-- ============================================================================
-- LANGUAGE REGISTRY
-- ============================================================================

local M = {}

local available_languages = {
	javascript = "languages.javascript",
	java = "languages.java",
}

local default_enabled = { "javascript", "java" }
local loaded_languages

local function get_enabled_language_ids()
	if type(vim.g.enabled_languages) == "table" and #vim.g.enabled_languages > 0 then
		return vim.g.enabled_languages
	end

	return default_enabled
end

local function load_languages()
	if loaded_languages then
		return loaded_languages
	end

	loaded_languages = {}

	for _, language_id in ipairs(get_enabled_language_ids()) do
		local module_name = available_languages[language_id]
		if module_name then
			local ok, language = pcall(require, module_name)
			if ok and type(language) == "table" then
				language.id = language.id or language_id
				table.insert(loaded_languages, language)
			else
				vim.notify(
					"Failed to load language module '" .. language_id .. "'",
					vim.log.levels.WARN
				)
			end
		end
	end

	return loaded_languages
end

local function start_path_or_cwd(path)
	local candidate = path
	if not candidate or candidate == "" then
		candidate = vim.api.nvim_buf_get_name(0)
	end
	if candidate == "" then
		candidate = vim.uv.cwd()
	end
	return candidate
end

local function includes(list, value)
	for _, entry in ipairs(list or {}) do
		if entry == value then
			return true
		end
	end
	return false
end

function M.get_enabled()
	return load_languages()
end

function M.root_markers()
	local markers = { ".git" }
	local seen = { [".git"] = true }

	for _, language in ipairs(load_languages()) do
		for _, marker in ipairs(language.root_markers or {}) do
			if not seen[marker] then
				seen[marker] = true
				table.insert(markers, marker)
			end
		end
	end

	return markers
end

function M.project_root(path)
	local start_path = start_path_or_cwd(path)
	local marker = vim.fs.find(M.root_markers(), { path = start_path, upward = true })[1]
	if marker then
		return vim.fs.dirname(marker)
	end

	return vim.uv.cwd()
end

function M.find_for_filetype(filetype)
	for _, language in ipairs(load_languages()) do
		if includes(language.filetypes, filetype) then
			return language
		end
	end

	return nil
end

function M.collect(section)
	local contributions = {}

	for _, language in ipairs(load_languages()) do
		local contribution = language[section]
		if contribution ~= nil then
			table.insert(contributions, { language = language, value = contribution })
		end
	end

	return contributions
end

function M.on_lsp_attach(ev, client, bufnr)
	local filetype = vim.bo[bufnr].filetype
	local language = M.find_for_filetype(filetype)
	if not language or not language.keymaps or type(language.keymaps.on_lsp_attach) ~= "function" then
		return
	end

	pcall(language.keymaps.on_lsp_attach, {
		event = ev,
		client = client,
		bufnr = bufnr,
	})
end

return M
