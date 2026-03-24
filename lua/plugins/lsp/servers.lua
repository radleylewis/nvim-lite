-- ============================================================================
-- LSP SERVER CONFIGURATIONS
-- ============================================================================

local language_registry = require("languages")

local function register_servers(servers)
	for server_name, config in pairs(servers) do
		vim.lsp.config(server_name, config)
	end
end

local function merge_enable_list(target, seen, servers)
	for _, server_name in ipairs(servers) do
		if not seen[server_name] then
			seen[server_name] = true
			table.insert(target, server_name)
		end
	end
end

register_servers({
	lua_ls = {
		settings = {
			Lua = {
				diagnostics = { globals = { "vim" } },
				telemetry = { enable = false },
			},
		},
	},
	pyright = {},
	bashls = {},
	gopls = {},
	clangd = {},
})

local servers_to_enable = { "lua_ls", "pyright", "bashls", "gopls", "clangd", "efm" }
local seen_servers = {
	lua_ls = true,
	pyright = true,
	bashls = true,
	gopls = true,
	clangd = true,
	efm = true,
}

for _, contribution in ipairs(language_registry.collect("lsp")) do
	local lsp = contribution.value
	if type(lsp.servers) == "table" then
		register_servers(lsp.servers)
		local names = {}
		for server_name in pairs(lsp.servers) do
			table.insert(names, server_name)
		end
		merge_enable_list(servers_to_enable, seen_servers, names)
	end

	if type(lsp.setup) == "function" then
		pcall(lsp.setup, {
			language = contribution.language,
		})
	end
end

vim.lsp.enable(servers_to_enable)
