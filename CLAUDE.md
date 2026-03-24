# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a modular Neovim configuration targeting NeoVim 0.12+. Entry point is `init.lua` and feature modules live under `lua/` (`core`, `plugins`, `ui`). The config uses `vim.pack` (built-in) for plugin management, not an external plugin manager.

## Prerequisites

### Required
- NeoVim 0.12 or later
- tree-sitter-cli 0.26.5+ (install via `cargo install --locked tree-sitter-cli`)
- golang (for efm-langserver)
- lua-jsregexp (for LuaSnip)

### Recommended
- fzf, ripgrep, fd (for fuzzy finding)

## Architecture

### Modular Design
- `init.lua`: bootstraps modules in load order
- `lua/core`: options, keymaps, autocmds, transparency
- `lua/plugins`: plugin registration and per-plugin configuration
- `lua/ui`: statusline and other UI modules

### Plugin System
Uses `vim.pack.add()` (NeoVim 0.12+ native) instead of external managers:
- Plugins are declared in `vim.pack.add()` calls
- Plugin lock file: `nvim-pack-lock.json` (git tracked)
- Auto-installation on first run
- Manual installation: restart Neovim after editing plugin declarations

### LSP & Tooling
- **LSP**: Uses `vim.lsp.config()` (NeoVim 0.12+ API), not `nvim-lspconfig`'s old setup
- **Linting/Formatting**: efm-langserver configured via efmls-configs-nvim
- **Completion**: blink.cmp (1.x) with LuaSnip for snippets
- **Fuzzy Finding**: fzf-lua (integrates with fzf/ripgrep/fd)

## Key Features

### IDE Workflow Baseline (Phase 1)
- **Run tasks**: `overseer.nvim` powers repeatable Node scripts (`dev`, `build`, `test`, `lint`) and script picker flows.
- **Debugging**: `nvim-dap` + `nvim-dap-ui` + `nvim-dap-virtual-text` + `nvim-dap-vscode-js` provide JS/TS Node debugging.
- **Testing**: `neotest` with `neotest-jest` and `neotest-vitest` supports nearest/file/project test runs.
- **Navigation**: `fzf-lua` search-everywhere flow + `aerial.nvim` outline/breadcrumb context.
- **Refactor/diagnostics UX**: `inc-rename.nvim`, `refactoring.nvim`, and `trouble.nvim` add IDE-style ergonomics.

### Custom Statusline
- Nerd Font icons for file types and modes
- Git branch display with 5-second caching to avoid shell calls
- Dynamic highlighting based on window focus
- File size display

### Format on Save
Automatic formatting for: `lua`, `python`, `go`, `js`, `jsx`, `ts`, `tsx`, `json`, `css`, `scss`, `html`, `sh`, `bash`, `zsh`, `c`, `cpp`, `h`, `hpp`

Only triggers when:
- Buffer is a real file (not special buffer)
- Buffer is modifiable
- efm-langserver is attached

### Floating Terminal
- Toggle with `<leader>t`
- Auto-closes on buffer leave
- Persists buffer content across toggles
- Terminal starts in `$SHELL`

### Kilo CLI Integration
Kilo is integrated directly into the editor with floating terminal windows:

**Keybindings:**
- `<leader>cc` - Open Kilo interactive terminal
- `<leader>cf` - Run Kilo with current file context
- `<leader>cs` - Run Kilo with visual selection (visual mode)

**Features:**
- Uses floating terminal for Kilo sessions
- Auto-closes on buffer leave for seamless workflow
- Handles partial line selections correctly
- Uses argv-based command execution (`termopen({ ... })`) for safe argument handling

**Optional shell integration:**
- Set `EDITOR`/`VISUAL` to Neovim so Kilo `/editor` opens in Neovim (for example in shell rc: `export EDITOR=nvim` and `export VISUAL=nvim`)

### Nerd Font Icons
The config assumes Nerd Fonts are installed. File type icons are hardcoded in the `file_type()` function.

### Which-Key
- `which-key.nvim` is configured to match LazyVim-style behavior (`preset = "helix"`).
- `<leader>?` shows buffer-local keymaps.
- `<C-w><Space>` opens window hydra mode for window commands.

### Keybindings Cheatsheet
- Canonical keybindings reference: `KEYBINDINGS.md`.
- To refresh it after keymap changes, use skill: `.claude/skills/update-keybindings-cheatsheet/SKILL.md`.

## Development Workflow

### Testing Changes
1. Edit the relevant module in `lua/` (or `init.lua` for bootstrapping changes)
2. Restart Neovim to reload configuration
3. For plugin changes: plugins auto-install on restart

### Plugin Lock File
`nvim-pack-lock.json` tracks exact plugin revisions. Commit this file to ensure reproducible installs.

### Adding a Plugin
Add to `vim.pack.add()` in the plugins section:
```lua
vim.pack.add("https://github.com/user/repo")
```
Then add corresponding `packadd()` call and configuration.

## Configuration Files

- `.luarc.json`: Lua language server configuration (declares `vim` global)
- `nvim-pack-lock.json`: Plugin lock file (auto-generated, commit to git)

## Key Leader Keybindings

- `<leader>c`: Clear search highlights
- `<leader>e`: Toggle file tree (nvim-tree)
- `<leader>t`: Toggle floating terminal
- `<leader>ff/fg/fb/fh`: FZF files/grep/buffers/help
- `<leader>fe`: FZF search everywhere
- `<leader>?`: Buffer keymaps (which-key)
- `<C-w><Space>`: Window hydra mode (which-key)
- `<leader>pa`: Copy full file path
- `<leader>td`: Toggle diagnostics
- `<leader>sv/sh`: Split vertical/horizontal
- `<C-h/j/k/l>`: Navigate windows
- LSP: `<leader>gd` (definition), `<leader>fr` (references), `<leader>ca` (code actions), `K` (hover)
- **Run/Tasks**: `<leader>rr` (script picker), `<leader>rd/rb/rt/rl` (dev/build/test/lint), `<leader>rp` (task list)
- **Debug**: `<leader>db` (breakpoint), `<leader>dc` (continue), `<leader>du` (debug UI), `<leader>dx` (terminate)
- **Tests**: `<leader>tn` (nearest), `<leader>tf` (file), `<leader>ta` (project), `<leader>tv` (nearest with DAP)
- **IDE aliases**: `<leader>jf/jc/js/ju/jr/jm` (go to file/class/symbol/usages, rename, refactor)
- **Kilo CLI**: `<leader>cc` (open terminal), `<leader>cf` (with current file), `<leader>cs` (with selection)
