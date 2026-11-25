-- CI check: install a few Mason tools, then confirm LSP attach + format-on-save work.
-- Run with: nvim --headless -c "luafile .github/ci/lsp-check.lua"
-- Exits non-zero (via :cquit) on any failure.

local tools = { "lua-language-server", "efm", "stylua" }
local failures = {}

local function finish()
	if #failures > 0 then
		io.stdout:write("FAIL:\n  " .. table.concat(failures, "\n  ") .. "\n")
		vim.cmd("cquit 1")
	else
		io.stdout:write("LSP check OK\n")
		vim.cmd("qa!")
	end
end

local function check_lua_file()
	local dir = vim.fn.tempname()
	vim.fn.mkdir(dir, "p")
	local file = dir .. "/check.lua"
	vim.fn.writefile({ "local   x   =   1", "return x" }, file)
	vim.cmd("edit " .. vim.fn.fnameescape(file))

	-- wait for both servers to attach
	local ok = vim.wait(30000, function()
		local names = {}
		for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
			names[c.name] = true
		end
		return names.lua_ls and names.efm
	end, 200)
	if not ok then
		local names = vim.tbl_map(function(c)
			return c.name
		end, vim.lsp.get_clients({ bufnr = 0 }))
		table.insert(failures, "lua_ls + efm did not both attach (got: " .. table.concat(names, ", ") .. ")")
		return finish()
	end

	-- format-on-save via efm/stylua
	vim.cmd("write")
	local first = vim.fn.readfile(file)[1]
	if first ~= "local x = 1" then
		table.insert(failures, "format-on-save did not run stylua (first line: " .. vim.inspect(first) .. ")")
	end
	finish()
end

local registry = require("mason-registry")
registry.refresh(function()
	local pending = #tools
	for _, name in ipairs(tools) do
		registry.get_package(name):install({}, function(success, err)
			if not success then
				table.insert(failures, "mason install " .. name .. ": " .. tostring(err))
			end
			pending = pending - 1
			if pending == 0 then
				vim.schedule(function()
					if #failures > 0 then
						return finish()
					end
					check_lua_file()
				end)
			end
		end)
	end
end)
