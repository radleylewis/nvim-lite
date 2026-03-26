-- ============================================================================
-- JAVA LANGUAGE CONTRIBUTIONS
-- ============================================================================

local autocmds = require("core.autocommands")

local M = {
	id = "java",
	filetypes = { "java" },
	root_markers = { "mvnw", "pom.xml", "gradlew", "settings.gradle", "build.gradle", ".git" },
	required_tools = { "jdtls", "java-debug-adapter", "java-test" },
	optional_tools = {},
	tool_descriptions = {
		jdtls = "Java language server (LSP attach and navigation)",
		["java-debug-adapter"] = "Java debug adapter for nvim-dap/jdtls integration",
		["java-test"] = "Java test bundles used by jdtls test commands",
	},
}

local function file_exists(path)
	return vim.uv.fs_stat(path) ~= nil
end

local function join_paths(...)
	local separator = package.config:sub(1, 1)
	return table.concat({ ... }, separator)
end

local function sanitize_name(name)
	local value = name:gsub("[^%w%-_.]", "_")
	if value == "" then
		return "workspace"
	end
	return value
end

local function detect_java_tool(root)
	if file_exists(root .. "/gradlew") then
		return { cmd = "./gradlew", kind = "gradle" }
	end
	if file_exists(root .. "/mvnw") then
		return { cmd = "./mvnw", kind = "maven" }
	end
	if file_exists(root .. "/settings.gradle") or file_exists(root .. "/build.gradle") then
		return { cmd = "gradle", kind = "gradle" }
	end
	if file_exists(root .. "/pom.xml") then
		return { cmd = "mvn", kind = "maven" }
	end

	return nil
end

local function discover_bundles(mason_packages)
	local bundles = {}

	local debug_bundles = vim.fn.glob(
		join_paths(mason_packages, "java-debug-adapter", "extension", "server", "com.microsoft.java.debug.plugin-*.jar"),
		true,
		true
	)
	if type(debug_bundles) == "table" then
		vim.list_extend(bundles, debug_bundles)
	end

	local test_bundles = vim.fn.glob(join_paths(mason_packages, "java-test", "extension", "server", "*.jar"), true, true)
	if type(test_bundles) == "table" then
		for _, jar in ipairs(test_bundles) do
			if not jar:match("jacoco") then
				table.insert(bundles, jar)
			end
		end
	end

	table.sort(bundles)
	return bundles
end

local function jdtls_cmd(workspace_dir, mason_packages)
	local launcher = vim.fn.glob(
		join_paths(mason_packages, "jdtls", "plugins", "org.eclipse.equinox.launcher_*.jar"),
		true,
		true
	)
	local launcher_jar = type(launcher) == "table" and launcher[1] or nil

	local os_config = "config_linux"
	if vim.fn.has("mac") == 1 then
		os_config = "config_mac"
	elseif vim.fn.has("win32") == 1 then
		os_config = "config_win"
	end

	local config_dir = join_paths(mason_packages, "jdtls", os_config)
	local lombok_jar = join_paths(mason_packages, "jdtls", "lombok.jar")

	if launcher_jar and file_exists(config_dir) then
		local cmd = {
			"java",
			"-Declipse.application=org.eclipse.jdt.ls.core.id1",
			"-Dosgi.bundles.defaultStartLevel=4",
			"-Declipse.product=org.eclipse.jdt.ls.core.product",
			"-Dlog.protocol=true",
			"-Dlog.level=WARN",
			"-Xms1g",
			"--add-modules=ALL-SYSTEM",
			"--add-opens",
			"java.base/java.util=ALL-UNNAMED",
			"--add-opens",
			"java.base/java.lang=ALL-UNNAMED",
		}

		if file_exists(lombok_jar) then
			table.insert(cmd, "-javaagent:" .. lombok_jar)
		end

		vim.list_extend(cmd, {
			"-jar",
			launcher_jar,
			"-configuration",
			config_dir,
			"-data",
			workspace_dir,
		})

		return cmd
	end

	local executable = vim.fn.exepath("jdtls")
	if executable == "" then
		executable = join_paths(vim.fn.stdpath("data"), "mason", "bin", "jdtls")
	end

	return { executable, "-data", workspace_dir }
end

local function start_or_attach_jdtls(bufnr)
	local ok, jdtls = pcall(require, "jdtls")
	if not ok then
		return false, "nvim-jdtls is not available"
	end

	local setup_ok, jdtls_setup = pcall(require, "jdtls.setup")
	if not setup_ok then
		return false, "jdtls.setup module is not available"
	end

	local file_path = vim.api.nvim_buf_get_name(bufnr)
	local root_dir = jdtls_setup.find_root(M.root_markers)
	if not root_dir then
		root_dir = vim.fs.dirname(file_path)
	end
	if not root_dir then
		return false, "Could not determine Java project root"
	end

	local project_name = sanitize_name(vim.fn.fnamemodify(root_dir, ":t"))
	local workspace_dir = join_paths(vim.fn.stdpath("cache"), "jdtls-workspaces", project_name)

	local mason_packages = join_paths(vim.fn.stdpath("data"), "mason", "packages")
	local bundles = discover_bundles(mason_packages)

	local config = {
		cmd = jdtls_cmd(workspace_dir, mason_packages),
		root_dir = root_dir,
		init_options = {
			bundles = bundles,
		},
		settings = {
			java = {
				configuration = {
					runtimes = {},
				},
			},
		},
		on_attach = function()
			pcall(jdtls.setup_dap, { hotcodereplace = "auto" })
			pcall(jdtls.setup_dap_main_class_configs)
			pcall(function()
				require("jdtls.setup").add_commands()
			end)
		end,
	}

	local ok_attach, attach_err = pcall(jdtls.start_or_attach, config)
	if not ok_attach then
		return false, tostring(attach_err)
	end

	return true
end

M.lsp = {
	setup = function()
		vim.api.nvim_create_autocmd("FileType", {
			group = autocmds.augroup,
			pattern = "java",
			callback = function(args)
				local tooling = require("core.tooling")
				tooling.ensure_language_ready(M, function(ready)
					if not ready then
						vim.notify(
							"Java tooling is not ready; LSP-dependent actions stay unavailable until installed",
							vim.log.levels.WARN
						)
						return
					end

					tooling.retry_lsp_attach(args.buf, "jdtls", function()
						local ok_attach, attach_err = start_or_attach_jdtls(args.buf)
						if not ok_attach then
							error(attach_err)
						end
					end, {
						attempts = 6,
						delay_ms = 650,
					})
				end)
			end,
		})
	end,
}

M.test = {
	adapters = function()
		return {
			require("neotest-java")({}),
		}
	end,
	run_class = function(ctx)
		if vim.bo.filetype ~= "java" then
			return false
		end

		local ok = pcall(ctx.neotest.run.run, vim.fn.expand("%"))
		if ok then
			return true
		end

		local has_jdtls, jdtls = pcall(require, "jdtls")
		if has_jdtls and type(jdtls.test_class) == "function" then
			pcall(jdtls.test_class)
			return true
		end

		return false
	end,
	run_nearest = function(ctx)
		if vim.bo.filetype ~= "java" then
			return false
		end

		local ok = pcall(ctx.neotest.run.run)
		if ok then
			return true
		end

		local has_jdtls, jdtls = pcall(require, "jdtls")
		if has_jdtls and type(jdtls.test_nearest_method) == "function" then
			pcall(jdtls.test_nearest_method)
			return true
		end

		return false
	end,
}

M.tasks = {
	detect = function(root)
		return detect_java_tool(root) ~= nil
	end,
	run_named = function(root, task_name)
		local alias = {
			dev = "run",
			build = "build",
			test = "test",
			lint = nil,
		}

		local mapped = alias[task_name]
		if not mapped then
			return nil, "No matching Java task for '" .. task_name .. "'"
		end

		return M.tasks.build_task(root, mapped)
	end,
	list = function(root)
		if not detect_java_tool(root) then
			return {}
		end

		return {
			{ id = "build", label = "build" },
			{ id = "test", label = "test" },
			{ id = "clean", label = "clean" },
			{ id = "run", label = "run" },
		}
	end,
	build_task = function(root, task_id)
		local tool = detect_java_tool(root)
		if not tool then
			return nil, "Could not detect Java build tool in " .. root
		end

		local args_by_tool = {
			gradle = {
				build = { "build" },
				test = { "test" },
				clean = { "clean" },
				run = { "run" },
			},
			maven = {
				build = { "package" },
				test = { "test" },
				clean = { "clean" },
				run = { "exec:java" },
			},
		}

		local args = args_by_tool[tool.kind] and args_by_tool[tool.kind][task_id]
		if not args then
			return nil, "Unsupported Java task '" .. task_id .. "'"
		end

		return {
			cmd = tool.cmd,
			args = args,
			cwd = root,
			name = "Java " .. task_id,
		}
	end,
	picker_prompt = "Run Java task",
}

M.keymaps = {
	on_lsp_attach = function(ctx)
		if vim.bo[ctx.bufnr].filetype ~= "java" then
			return
		end

		local ok, jdtls = pcall(require, "jdtls")
		if not ok then
			return
		end

		local opts = { noremap = true, silent = true, buffer = ctx.bufnr }

		vim.keymap.set("n", "<leader>jO", function()
			if type(jdtls.organize_imports) == "function" then
				jdtls.organize_imports()
				return
			end
			vim.lsp.buf.code_action({
				context = { only = { "source.organizeImports" }, diagnostics = {} },
				apply = true,
				bufnr = ctx.bufnr,
			})
		end, vim.tbl_extend("force", opts, { desc = "Java organize imports" }))

		vim.keymap.set("n", "<leader>tC", function()
			local has_jdtls, jdtls_client = pcall(require, "jdtls")
			if has_jdtls and type(jdtls_client.test_class) == "function" then
				jdtls_client.test_class()
				return
			end
			require("neotest").run.run(vim.fn.expand("%"))
		end, vim.tbl_extend("force", opts, { desc = "Test Java class" }))
	end,
}

return M
