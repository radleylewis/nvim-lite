vim.opt.termguicolors = true

-- installed early so it's available before colorscheme() runs below
-- (the rest of the plugin list is installed further down, near PLUGINS)
vim.pack.add({ "https://github.com/savq/melange-nvim" })

vim.opt.background = "dark" -- set to "light" for the light variant
vim.cmd.colorscheme("melange")

local function set_transparent() -- set UI component to transparent
	local groups = {
		"Normal",
		"NormalNC",
		"EndOfBuffer",
		"NormalFloat",
		"FloatBorder",
		"SignColumn",
		"StatusLine",
		"StatusLineNC",
		"TabLine",
		"TabLineFill",
		"TabLineSel",
		"ColorColumn",
	}
	for _, g in ipairs(groups) do
		vim.api.nvim_set_hl(0, g, { bg = "none" })
	end
	vim.api.nvim_set_hl(0, "TabLineFill", { bg = "none", fg = "#767676" })

	-- nvim-tree
	vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "none" })
	vim.api.nvim_set_hl(0, "NvimTreeSignColumn", { bg = "none" })
	vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "none" })
	vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { fg = "#2a2a2a", bg = "none" })
end

set_transparent()
-- re-apply after any colorscheme change (:colorscheme resets highlight groups)
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_transparent })

-- ============================================================================
-- OPTIONS
-- ============================================================================
vim.opt.number = true -- line number
vim.opt.relativenumber = true -- relative line numbers
vim.opt.cursorline = true -- highlight current line
vim.opt.wrap = false -- do not wrap lines by default
vim.opt.scrolloff = 10 -- keep 10 lines above/below cursor
vim.opt.sidescrolloff = 10 -- keep 10 lines to left/right of cursor

vim.opt.tabstop = 2 -- tabwidth
vim.opt.shiftwidth = 2 -- indent width
vim.opt.softtabstop = 2 -- soft tab stop not tabs on tab/backspace
vim.opt.expandtab = true -- use spaces instead of tabs
vim.opt.smartindent = true -- smart auto-indent

vim.opt.ignorecase = true -- case insensitive search
vim.opt.smartcase = true -- case sensitive if uppercase in string

vim.opt.signcolumn = "yes" -- always show a sign column
vim.opt.colorcolumn = "100" -- show a column at 100 position chars
vim.opt.showmatch = true -- highlights matching brackets
vim.opt.completeopt = "menuone,noinsert,noselect" -- completion options
vim.opt.showmode = false -- do not show the mode, instead have it in statusline
vim.opt.pumheight = 10 -- popup menu height
vim.opt.pumblend = 10 -- popup menu transparency
vim.opt.conceallevel = 2 -- obsidian requirement
vim.opt.concealcursor = "" -- do not hide cursorline in markup
vim.opt.synmaxcol = 300 -- syntax highlighting limit
vim.opt.fillchars = { eob = " " } -- hide "~" on empty lines

vim.opt.backup = false -- do not create a backup file
vim.opt.writebackup = false -- do not write to a backup file
vim.opt.swapfile = false -- do not create a swapfile
vim.opt.undofile = true -- persistent undo, stored in Neovim's default ~/.local/state/nvim/undo/
vim.opt.updatetime = 300 -- faster completion
vim.opt.timeoutlen = 500 -- timeout duration
vim.opt.ttimeoutlen = 50 -- key code timeout
-- (hidden buffers, autoread, hlsearch/incsearch, autoindent, backspace, etc. are already Neovim defaults)

-- (no global iskeyword+=-: it made `w`/`ciw` treat `a-b` as one word in code;
-- CSS/SCSS/Lisp ftplugins already add `-` where it is part of identifiers)
vim.opt.path:append("**") -- include subdirs in search
vim.opt.mouse = "a" -- enable mouse support
vim.opt.clipboard:append("unnamedplus") -- use system clipboard

vim.opt.guicursor =
	"n-v-c:block,i-ci-ve:block,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175" -- cursor blinking and settings

-- Folding: requires treesitter available at runtime; safe fallback if not
vim.opt.foldmethod = "expr" -- use expression for folding
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- use treesitter for folding
vim.opt.foldlevel = 99 -- start with all folds open

vim.opt.splitbelow = true -- horizontal splits go below
vim.opt.splitright = true -- vertical splits go right

vim.opt.wildmenu = true -- tab completion
vim.opt.wildmode = "longest:full,full" -- complete longest common match, full completion list, cycle through with Tab
vim.opt.diffopt:append("linematch:60") -- improve diff display
vim.opt.redrawtime = 10000 -- increase neovim redraw tolerance
vim.opt.maxmempattern = 20000 -- increase max memory

-- ============================================================================
-- KEYMAPS
-- ============================================================================
vim.g.mapleader = " " -- space for leader
vim.g.maplocalleader = " " -- space for localleader

-- better movement in wrapped text
vim.keymap.set("n", "j", function()
	return vim.v.count == 0 and "gj" or "j"
end, { expr = true, silent = true, desc = "Down (wrap-aware)" })
vim.keymap.set("n", "k", function()
	return vim.v.count == 0 and "gk" or "k"
end, { expr = true, silent = true, desc = "Up (wrap-aware)" })

-- on <Esc> rather than <leader>c, which made <leader>ca (code action) wait for a second key
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", { desc = "Clear search highlights" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })
vim.keymap.set({ "n", "v" }, "<leader>x", '"_d', { desc = "Delete without yanking" })

vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })

vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { desc = "Move to left window/pane" })
vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", { desc = "Move to bottom window/pane" })
vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", { desc = "Move to top window/pane" })
vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "Move to right window/pane" })

vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

vim.keymap.set("n", "<leader>pa", function() -- show file path
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("file:", path)
end, { desc = "Copy full file path" })

-- toggle diagnostics
vim.keymap.set("n", "<leader>ud", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })

-- ============================================================================
-- AUTOCMDS
-- ============================================================================

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Format on save (ONLY real file buffers, ONLY when efm is attached)
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	-- no filename pattern: runs for every buffer, and formats whenever efm is attached,
	-- so the efm `languages` table below is the single source of truth
	callback = function(args)
		-- avoid formatting non-file buffers (helps prevent weird write prompts)
		if vim.bo[args.buf].buftype ~= "" then
			return
		end
		-- markdown is formatted manually only (prettier would rewrite notes on every save)
		if vim.bo[args.buf].filetype == "markdown" then
			return
		end
		if not vim.bo[args.buf].modifiable then
			return
		end
		if vim.api.nvim_buf_get_name(args.buf) == "" then
			return
		end

		local has_efm = false
		for _, c in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
			if c.name == "efm" then
				has_efm = true
				break
			end
		end
		if not has_efm then
			return
		end

		pcall(vim.lsp.buf.format, {
			bufnr = args.buf,
			timeout_ms = 2000,
			filter = function(c)
				return c.name == "efm"
			end,
		})
	end,
})

-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	callback = function()
		vim.hl.on_yank()
	end,
})

-- return to last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	desc = "Restore last cursor position",
	callback = function()
		if vim.o.diff then -- except in diff mode
			return
		end

		local last_pos = vim.api.nvim_buf_get_mark(0, '"') -- {line, col}
		local last_line = vim.api.nvim_buf_line_count(0)

		local row = last_pos[1]
		if row < 1 or row > last_line then
			return
		end

		pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
	end,
})

-- wrap, linebreak and spellcheck on markdown and text files
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.spell = true
	end,
})

-- ============================================================================
-- PLUGINS (vim.pack)
-- ============================================================================

-- vim.pack has no `build` field (specs only keep src/name/version/data), so post-update
-- steps go in a PackChanged hook. Must be defined before vim.pack.add() to see installs.
vim.api.nvim_create_autocmd("PackChanged", {
	group = augroup,
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		-- recompile parsers after nvim-treesitter updates (parser versions are tied to it)
		if name == "nvim-treesitter" and kind == "update" then
			if not ev.data.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			vim.cmd("TSUpdate")
		end
	end,
})

vim.pack.add({
	"https://www.github.com/echasnovski/mini.nvim",
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://www.github.com/ibhagwan/fzf-lua",
	"https://www.github.com/nvim-tree/nvim-tree.lua",
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		version = "main",
	},
	"https://github.com/JoosepAlviste/nvim-ts-context-commentstring",
	-- Language Server Protocols
	"https://www.github.com/neovim/nvim-lspconfig",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/creativenull/efmls-configs-nvim",
	{
		-- Pinned to v1 until v2 released
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("1.*"),
	},
	"https://github.com/obsidian-nvim/obsidian.nvim",
	"https://github.com/mrcjkb/rustaceanvim",
	"https://github.com/christoomey/vim-tmux-navigator",
})

-- ============================================================================
-- PLUGIN CONFIGS
-- ============================================================================

local setup_treesitter = function()
	local treesitter = require("nvim-treesitter")
	treesitter.setup({})
	local ensure_installed = {
		"vim",
		"vimdoc",
		"rust",
		"c",
		"cpp",
		"c_sharp",
		"go",
		"html",
		"css",
		"javascript",
		"json",
		"lua",
		"markdown",
		"python",
		"typescript",
		"vue",
		"svelte",
		"bash",
		"tsx",
		"yaml",
		"dockerfile",
	}

	local config = require("nvim-treesitter.config")

	local already_installed = config.get_installed()
	local parsers_to_install = {}

	for _, parser in ipairs(ensure_installed) do
		if not vim.tbl_contains(already_installed, parser) then
			table.insert(parsers_to_install, parser)
		end
	end

	if #parsers_to_install > 0 then
		treesitter.install(parsers_to_install)
	end

	local group = vim.api.nvim_create_augroup("TreeSitterConfig", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		callback = function(args)
			if vim.list_contains(config.get_installed(), vim.treesitter.language.get_lang(args.match)) then
				vim.treesitter.start(args.buf)
			end
		end,
	})
end

setup_treesitter()

-- treesitter-aware comment strings (correct comment syntax inside embedded
-- regions, e.g. JS inside JSX/Vue/Svelte) — mini.comment picks this up below
require("ts_context_commentstring").setup({
	enable_autocmd = false,
})

-- returns nil on unknown systems so obsidian is skipped instead of erroring out of the whole config
local function get_notes_path()
	local f = io.open("/etc/os-release", "r")
	local os_release = f and f:read("*a") or ""
	if f then
		f:close()
	end
	if os_release:match("Artix") then
		return vim.fn.expand("~/Documents/Notes")
	elseif os_release:match("Ubuntu") then
		-- WSL: find the Notes folder under whichever Windows user has one (no hard-coded username)
		return vim.fn.glob("/mnt/c/Users/*/Documents/Notes", false, true)[1]
	end
	return nil
end

-- obsidian.nvim is lazy-loaded (it was ~20ms of every startup): it is set up the first
-- time a markdown buffer opens or a <leader>n* key is pressed. Returns false if unavailable.
local obsidian_loaded = false
local function load_obsidian()
	if obsidian_loaded then
		return true
	end
	local notes_path = get_notes_path()
	if not notes_path then
		vim.notify("obsidian.nvim: no Notes folder found for this system, skipping", vim.log.levels.WARN)
		return false
	end

	require("obsidian").setup({
		legacy_commands = false,
		workspaces = { { name = "Notes", path = notes_path } },
		picker = { name = "fzf-lua" },
	})
	obsidian_loaded = true

	-- obsidian attaches to markdown buffers via its own FileType/BufEnter autocmds, which were
	-- created just now and so missed buffers that are already open: replay them for those.
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "markdown" then
			vim.api.nvim_exec_autocmds("FileType", { group = "obsidian_setup", buffer = buf, modeline = false })
			vim.api.nvim_buf_call(buf, function()
				vim.api.nvim_exec_autocmds("BufEnter", { group = "obsidian_setup", buffer = buf, modeline = false })
			end)
		end
	end
	return true
end

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = "markdown",
	once = true,
	callback = function()
		vim.schedule(load_obsidian) -- after the buffer has finished loading
	end,
})

-- each <leader>n* key loads obsidian first, then runs the command
local function obsidian_cmd(...)
	local cmds = { ... }
	return function()
		if load_obsidian() then
			for _, c in ipairs(cmds) do
				vim.cmd(c)
			end
		end
	end
end

-- "workspace Notes" switches by name (synchronous), so no fixed delay is needed before "new"
vim.keymap.set("n", "<leader>nn", obsidian_cmd("Obsidian workspace Notes", "Obsidian new"), { desc = "New note" })
vim.keymap.set("n", "<leader>nf", obsidian_cmd("Obsidian quick_switch"), { desc = "Find note" })
vim.keymap.set("n", "<leader>ns", obsidian_cmd("Obsidian search"), { desc = "Search notes" })
vim.keymap.set("n", "<leader>nt", obsidian_cmd("Obsidian today"), { desc = "Today's daily note" })
vim.keymap.set("n", "<leader>nw", obsidian_cmd("Obsidian workspace"), { desc = "Switch workspace" })

require("nvim-tree").setup({
	view = {
		width = 35,
	},
	filters = {
		dotfiles = false,
	},
	renderer = {
		group_empty = true,
	},
})
vim.keymap.set("n", "<leader>e", function()
	require("nvim-tree.api").tree.toggle()
end, { desc = "Toggle NvimTree" })

-- no require("fzf-lua").setup({}): it is optional with default options, and skipping it
-- means fzf-lua only loads (~13ms) the first time one of the keys below is used

vim.keymap.set("n", "<leader>ff", function()
	require("fzf-lua").files()
end, { desc = "FZF Files" })
vim.keymap.set("n", "<leader>fg", function()
	require("fzf-lua").live_grep()
end, { desc = "FZF Live Grep" })
vim.keymap.set("n", "<leader>fb", function()
	require("fzf-lua").buffers()
end, { desc = "FZF Buffers" })
vim.keymap.set("n", "<leader>fh", function()
	require("fzf-lua").help_tags()
end, { desc = "FZF Help Tags" })
vim.keymap.set("n", "<leader>fx", function()
	require("fzf-lua").diagnostics_document()
end, { desc = "FZF Diagnostics Document" })
vim.keymap.set("n", "<leader>fX", function()
	require("fzf-lua").diagnostics_workspace()
end, { desc = "FZF Diagnostics Workspace" })

require("mini.ai").setup({})
require("mini.comment").setup({
	options = {
		custom_commentstring = function()
			return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
		end,
	},
})
require("mini.move").setup({})
require("mini.surround").setup({})
require("mini.cursorword").setup({})
require("mini.indentscope").setup({})
require("mini.pairs").setup({})
require("mini.trailspace").setup({})
require("mini.bufremove").setup({})
require("mini.notify").setup({})
require("mini.icons").setup({})

-- statusline: theme "auto" pulls colors straight from melange's highlight
-- groups (no dedicated melange lualine theme exists, so this generates one)
require("lualine").setup({
	options = {
		theme = "melange", -- melange-nvim ships a dedicated lualine theme
		icons_enabled = true,
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		globalstatus = false, -- keep per-window active/inactive styling
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { { "branch", icon = "\u{e725}" } }, -- nf-dev-git_branch
		lualine_c = { { "filename", path = 0 } },
		lualine_x = {
			function()
				local size = vim.fn.getfsize(vim.fn.expand("%"))
				if size < 0 then
					return ""
				elseif size < 1024 then
					return size .. "B"
				elseif size < 1024 * 1024 then
					return string.format("%.1fK", size / 1024)
				else
					return string.format("%.1fM", size / 1024 / 1024)
				end
			end,
			{ "filetype", icon_only = false },
		},
		lualine_y = { "location" }, -- %l:%c equivalent
		lualine_z = { "progress" }, -- %P equivalent
	},
	inactive_sections = {
		lualine_c = { { "filename", path = 0 } },
		lualine_x = { "filetype" },
	},
})

-- shows available keymaps as you type a prefix (e.g. <leader>) — useful
-- given how many custom <leader> mappings this config defines
require("mini.clue").setup({
	triggers = {
		{ mode = "n", keys = "<Leader>" },
		{ mode = "x", keys = "<Leader>" },
		{ mode = "n", keys = "g" },
		{ mode = "n", keys = "[" },
		{ mode = "n", keys = "]" },
	},
	clues = {
		require("mini.clue").gen_clues.builtin_completion(),
	},
})

-- restore buffers/window layout per-project on relaunch:
-- `nvim` with no file arguments restores the last session for the current directory,
-- and the session is saved on exit. Sessions live in stdpath("data")/session, not in projects.
local MiniSessions = require("mini.sessions")
-- autowrite off: the VimLeavePre autocmd below does the saving (mini's own autowrite
-- would write the same session a second time and print a message on every exit)
MiniSessions.setup({ autowrite = false })
-- don't save terminals, empty buffers or option values (stale options/maps would override init.lua)
vim.opt.sessionoptions = { "buffers", "curdir", "folds", "tabpages", "winsize" }

local function project_session_name()
	return (vim.fn.getcwd():gsub("/", "%%"))
end

-- RESTORE: runs once Neovim has finished starting up.
-- If you launched plain `nvim` (no files) and this directory has a saved session, reopen it.
vim.api.nvim_create_autocmd("VimEnter", {
	group = augroup,
	nested = true, -- so filetype/LSP autocmds fire for restored buffers
	callback = function()
		if vim.fn.argc() == 0 and MiniSessions.detected[project_session_name()] then
			MiniSessions.read(project_session_name(), { verbose = false })
		end
	end,
})

-- SAVE: VimLeavePre runs just before Neovim exits (:q, :qa, ZZ, ...), while every
-- window and buffer still exists, which is the last moment the layout can be recorded.
-- It saves the open buffers and splits as this directory's session so the VimEnter
-- autocmd above can restore them next time.
-- Skipped when:
--   * nvim was opened with files (`nvim foo.lua`), a one-off edit that shouldn't
--     overwrite the project's session
--   * no real file is open (e.g. you opened nvim and quit straight away), which would
--     otherwise replace a good session with an empty one
vim.api.nvim_create_autocmd("VimLeavePre", {
	group = augroup,
	callback = function()
		if vim.fn.argc() ~= 0 then
			return
		end
		local has_file = false
		for _, b in ipairs(vim.api.nvim_list_bufs()) do
			if vim.bo[b].buflisted and vim.bo[b].buftype == "" and vim.api.nvim_buf_get_name(b) ~= "" then
				has_file = true
				break
			end
		end
		if not has_file then
			return
		end
		pcall(function()
			require("nvim-tree.api").tree.close() -- tree windows don't restore cleanly
		end)
		MiniSessions.write(project_session_name(), { verbose = false })
	end,
})

require("mini.diff").setup({
	view = {
		style = "sign",
		signs = { add = "▎", change = "▎", delete = "▎" },
	},
})

require("mini.git").setup({})

local MiniDiff = require("mini.diff")
vim.keymap.set("n", "]h", function()
	MiniDiff.goto_hunk("next")
end, { desc = "Next git hunk" })
vim.keymap.set("n", "[h", function()
	MiniDiff.goto_hunk("prev")
end, { desc = "Prev git hunk" })
-- gh = mini.diff "apply" operator (stages with the git source), second gh = hunk textobject
vim.keymap.set("n", "<leader>hs", "ghgh", { remap = true, desc = "Stage hunk under cursor" })
vim.keymap.set("n", "<leader>hp", function()
	MiniDiff.toggle_overlay()
end, { desc = "Preview diff overlay" })
vim.keymap.set("n", "<leader>hb", function()
	require("mini.git").show_at_cursor()
end, { desc = "Git blame/show" })

require("mason").setup({})

-- ============================================================================
-- LSP, Linting, Formatting & Completion
-- ============================================================================
local diagnostic_signs = {
	Error = "\u{f057} ",
	Warn = "\u{f071} ",
	Hint = "\u{ea61}",
	Info = "\u{f05a}",
}

vim.diagnostic.config({
	virtual_text = { prefix = "●", spacing = 4 },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
			[vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
			[vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
			[vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
		},
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = true,
		header = "",
		prefix = "",
		focusable = false,
		style = "minimal",
	},
})

-- default border for all floating windows (LSP hover/signature, completion menu, etc.)
vim.o.winborder = "rounded"

local function lsp_on_attach(ev)
	local client = vim.lsp.get_client_by_id(ev.data.client_id)
	if not client then
		return
	end

	local bufnr = ev.buf
	local opts = { noremap = true, silent = true, buffer = bufnr }

	vim.keymap.set("n", "<leader>gd", function()
		require("fzf-lua").lsp_definitions({ jump_to_single_result = true })
	end, opts)

	vim.keymap.set("n", "<leader>gD", vim.lsp.buf.definition, opts)

	vim.keymap.set("n", "<leader>gS", function()
		vim.cmd("vsplit")
		vim.lsp.buf.definition()
	end, opts)

	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

	vim.keymap.set("n", "<leader>D", function()
		vim.diagnostic.open_float({ scope = "line" })
	end, opts) -- (a global <leader>dl did the same thing and made <leader>d wait; removed)
	vim.keymap.set("n", "<leader>d", function()
		vim.diagnostic.open_float({ scope = "cursor" })
	end, opts)
	vim.keymap.set("n", "<leader>nd", function()
		vim.diagnostic.jump({ count = 1 })
	end, opts)

	vim.keymap.set("n", "<leader>pd", function()
		vim.diagnostic.jump({ count = -1 })
	end, opts)

	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

	vim.keymap.set("n", "<leader>fr", function()
		require("fzf-lua").lsp_references()
	end, opts)
	vim.keymap.set("n", "<leader>ft", function()
		require("fzf-lua").lsp_typedefs()
	end, opts)
	vim.keymap.set("n", "<leader>fs", function()
		require("fzf-lua").lsp_document_symbols()
	end, opts)
	vim.keymap.set("n", "<leader>fw", function()
		require("fzf-lua").lsp_workspace_symbols()
	end, opts)
	vim.keymap.set("n", "<leader>fi", function()
		require("fzf-lua").lsp_implementations()
	end, opts)

	if client:supports_method("textDocument/codeAction", bufnr) then
		vim.keymap.set("n", "<leader>oi", function()
			vim.lsp.buf.code_action({
				context = { only = { "source.organizeImports" }, diagnostics = {} },
				apply = true,
				bufnr = bufnr,
			})
			vim.defer_fn(function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end, 50)
		end, opts)
	end
end

vim.api.nvim_create_autocmd("LspAttach", { group = augroup, callback = lsp_on_attach })

vim.keymap.set("n", "<leader>q", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "Open diagnostic list" })

local blink = require("blink.cmp")
blink.setup({
	keymap = {
		preset = "none",
		["<C-Space>"] = { "show", "hide" },
		["<CR>"] = { "accept", "fallback" },
		["<C-j>"] = { "select_next", "fallback" },
		["<C-k>"] = { "select_prev", "fallback" },
		["<Tab>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },
	},
	appearance = { nerd_font_variant = "mono" },
	completion = {
		menu = {
			auto_show = function()
				return vim.bo.filetype ~= "markdown"
			end,
		},
	},
	-- signature help while typing function calls (was previously unset)
	signature = { enabled = true },
	sources = { default = { "lsp", "path", "buffer", "snippets" } },
	-- snippets now use blink's native engine — LuaSnip dependency removed
	fuzzy = {
		implementation = "prefer_rust",
		prebuilt_binaries = { download = true },
	},
})

vim.lsp.config["*"] = {
	capabilities = blink.get_lsp_capabilities(),
}

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			telemetry = { enable = false },
		},
	},
})
vim.lsp.config("pyright", {})
vim.lsp.config("bashls", {})
vim.lsp.config("ts_ls", {})
vim.lsp.config("gopls", {})
vim.lsp.config("clangd", {})
vim.lsp.config("jsonls", {})
vim.lsp.config("yamlls", {})
vim.lsp.config("docker_language_server", {})
vim.lsp.config("emmet_language_server", {})
vim.lsp.config("tailwindcss", {
	-- only attach in projects that actually use Tailwind: a tailwind.config.* file, or
	-- tailwindcss in package.json (covers v4). The default also matches any .git root,
	-- so it attached to every HTML/JS/TS file in every repo.
	root_dir = function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		local markers = require("lspconfig.util").insert_package_json(
			{ "tailwind.config.js", "tailwind.config.cjs", "tailwind.config.mjs", "tailwind.config.ts" },
			"tailwindcss",
			fname
		)
		local found = vim.fs.find(markers, { path = fname, upward = true })[1]
		if found then
			on_dir(vim.fs.dirname(found))
		end
	end,
})

vim.g.rustaceanvim = {
	server = {
		capabilities = blink.get_lsp_capabilities(),
	},
}

do
	local stylua = require("efmls-configs.formatters.stylua")

	local ruff_lint = require("efmls-configs.linters.ruff")
	local ruff_format = require("efmls-configs.formatters.ruff")

	local prettier_d = require("efmls-configs.formatters.prettier_d")
	local eslint_d = require("efmls-configs.linters.eslint_d")

	local fixjson = require("efmls-configs.formatters.fixjson")

	local shellcheck = require("efmls-configs.linters.shellcheck")
	local shfmt = require("efmls-configs.formatters.shfmt")

	local cpplint = require("efmls-configs.linters.cpplint")
	local clangfmt = require("efmls-configs.formatters.clang_format")

	local go_revive = require("efmls-configs.linters.go_revive")
	local gofumpt = require("efmls-configs.formatters.gofumpt")

	local hadolint = require("efmls-configs.linters.hadolint")

	vim.lsp.config("efm", {
		filetypes = {
			"c",
			"cpp",
			"css",
			"dockerfile",
			"go",
			"html",
			"javascript",
			"javascriptreact",
			"json",
			"jsonc",
			"lua",
			"markdown",
			"python",
			"sh",
			"typescript",
			"typescriptreact",
			"vue",
			"svelte",
		},
		init_options = { documentFormatting = true },
		settings = {
			languages = {
				c = { clangfmt, cpplint },
				go = { gofumpt, go_revive },
				cpp = { clangfmt, cpplint },
				css = { prettier_d },
				dockerfile = { hadolint },
				html = { prettier_d },
				javascript = { eslint_d, prettier_d },
				javascriptreact = { eslint_d, prettier_d },
				json = { fixjson }, -- diagnostics come from jsonls
				jsonc = { prettier_d }, -- not fixjson: it strips comments
				lua = { stylua }, -- linting comes from lua_ls
				markdown = { prettier_d },
				python = { ruff_lint, ruff_format },
				sh = { shellcheck, shfmt },
				typescript = { eslint_d, prettier_d },
				typescriptreact = { eslint_d, prettier_d },
				vue = { eslint_d, prettier_d },
				svelte = { eslint_d, prettier_d },
			},
		},
	})
end

vim.lsp.enable({
	"lua_ls",
	"pyright",
	"bashls",
	"ts_ls",
	"gopls",
	"clangd",
	"jsonls",
	"yamlls",
	"docker_language_server",
	"emmet_language_server",
	"tailwindcss",
	"efm",
})

-- ============================================================================
-- FLOATING TERMINAL
-- ============================================================================
vim.api.nvim_create_autocmd("TermClose", {
	group = augroup,
	callback = function(args)
		if vim.v.event.status == 0 and vim.api.nvim_buf_is_valid(args.buf) then
			vim.api.nvim_buf_delete(args.buf, { force = true })
		end
	end,
})

vim.api.nvim_create_autocmd("TermOpen", {
	group = augroup,
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
	end,
})

local terminal_state = { buf = nil, win = nil, is_open = false }

local function FloatingTerminal()
	if terminal_state.is_open and terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
		vim.api.nvim_win_close(terminal_state.win, false)
		terminal_state.is_open = false
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

	local has_terminal = vim.bo[terminal_state.buf].buftype == "terminal"
	if not has_terminal then
		vim.fn.jobstart(vim.o.shell, { term = true })
	end

	terminal_state.is_open = true
	vim.cmd("startinsert")

	local term_augroup = vim.api.nvim_create_augroup("FloatingTermLeave_" .. terminal_state.win, { clear = true })
	vim.api.nvim_create_autocmd("BufLeave", {
		group = term_augroup,
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

vim.keymap.set("n", "<leader>t", FloatingTerminal, { noremap = true, silent = true, desc = "Toggle floating terminal" })
-- double <Esc> so a single <Esc> still reaches the shell (zsh-vi-mode uses it for normal mode)
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { noremap = true, silent = true, desc = "Terminal normal mode" })
vim.keymap.set("t", "<C-q>", function()
	if terminal_state.is_open and terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
		vim.api.nvim_win_close(terminal_state.win, false)
		terminal_state.is_open = false
	end
end, { noremap = true, silent = true, desc = "Close floating terminal" })
