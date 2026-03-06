# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a minimal single-file Neovim configuration targeting NeoVim 0.12+. All configuration lives in `init.lua`. The config uses `vim.pack` (built-in) for plugin management, not an external plugin manager.

## Prerequisites

### Required
- NeoVim 0.12 or later
- tree-sitter-cli 0.26.5+ (install via `cargo install --locked tree-sitter-cli`)
- golang (for efm-langserver)
- lua-jsregexp (for LuaSnip)

### Recommended
- fzf, ripgrep, fd (for fuzzy finding)

## Architecture

### Single-File Design
All configuration is in `init.lua` with these main sections:
1. **Options** (line 27-110): Editor settings, colorscheme, transparency
2. **Statusline** (line 112-256): Custom statusline with Nerd Font icons and git branch caching
3. **Keymaps** (line 258-316): Leader key (`<Space>`), window navigation, LSP bindings
4. **Autocmds** (line 318-417): Format on save, yank highlighting, cursor position restoration
5. **Plugin Management** (line 419-440): Plugin declarations using `vim.pack.add()`
6. **Plugin Configs** (line 457-807): Individual plugin setup including Treesitter, LSP, completion
7. **Floating Terminal** (line 849-938): Custom floating terminal implementation

### Plugin System
Uses `vim.pack.add()` (NeoVim 0.12+ native) instead of external managers:
- Plugins are declared in `vim.pack.add()` calls
- Plugin lock file: `nvim-pack-lock.json` (git tracked)
- Auto-installation on first run
- Manual installation: Restart neovim after editing `init.lua`

### LSP & Tooling
- **LSP**: Uses `vim.lsp.config()` (NeoVim 0.12+ API), not `nvim-lspconfig`'s old setup
- **Linting/Formatting**: efm-langserver configured via efmls-configs-nvim
- **Completion**: blink.cmp (1.x) with LuaSnip for snippets
- **Fuzzy Finding**: fzf-lua (integrates with fzf/ripgrep/fd)

## Key Features

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

### Claude Code Integration
Claude Code is integrated directly into the editor with floating terminal windows:

**Keybindings:**
- `<leader>cc` - Open Claude Code terminal for interactive sessions
- `<leader>cf` - Send current file to Claude Code (uses `--file` flag)
- `<leader>cs` - Send visual selection to Claude Code (visual mode only)

**Features:**
- Uses floating terminal for Claude Code sessions
- Auto-closes on buffer leave for seamless workflow
- Handles partial line selections correctly
- Escapes shell arguments properly for safe command execution

### Nerd Font Icons
The config assumes Nerd Fonts are installed. File type icons are hardcoded in the `file_type()` function.

## Development Workflow

### Testing Changes
1. Edit `init.lua`
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
- `<leader>pa`: Copy full file path
- `<leader>td`: Toggle diagnostics
- `<leader>sv/sh`: Split vertical/horizontal
- `<C-h/j/k/l>`: Navigate windows
- LSP: `<leader>gd` (definition), `<leader>fr` (references), `<leader>ca` (code actions), `K` (hover)
- **Claude Code**: `<leader>cc` (open terminal), `<leader>cf` (with current file), `<leader>cs` (with selection)
