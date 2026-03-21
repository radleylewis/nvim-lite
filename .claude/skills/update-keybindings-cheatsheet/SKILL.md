---
name: update-keybindings-cheatsheet
description: Refresh KEYBINDINGS.md from current Neovim keymaps in this repository.
---

# Update Keybindings Cheatsheet

## Purpose

Keep `KEYBINDINGS.md` synchronized with the active Neovim keymaps defined in this config.

## Repository Context

- Config entrypoint: `init.lua`
- Core keymaps: `lua/core/keymaps.lua`
- Plugin keymaps usually live in `lua/plugins/**/*.lua`
- LSP attach keymaps: `lua/plugins/lsp/handlers.lua`
- Cheatsheet target: `KEYBINDINGS.md`

## Rules

1. Document only mappings that are currently active through loaded modules.
   - `lua/plugins/init.lua` controls what plugin modules are loaded.
   - If a file defines mappings but is not required by `lua/plugins/init.lua`, do not list those mappings as active.
2. Preserve mode clarity (`n`, `v`, `x`, `t`, insert/completion context).
3. Keep descriptions concise and action-oriented.
4. Include source file references in section headers.
5. Keep markdown ASCII-only.

## Update Procedure

### 1) Confirm load path

Read:

- `init.lua`
- `lua/plugins/init.lua`

Verify which modules are actually required.

### 2) Collect mappings

Search for direct keymap definitions:

- `vim.keymap.set(...)`
- `vim.api.nvim_set_keymap(...)`
- plugin-specific keymap tables (for example completion frameworks)

Primary files to review:

- `lua/core/keymaps.lua`
- `lua/plugins/which-key.lua`
- `lua/plugins/fzf-lua.lua`
- `lua/plugins/nvim-tree.lua`
- `lua/plugins/gitsigns.lua`
- `lua/plugins/terminal.lua`
- `lua/plugins/kilo.lua`
- `lua/plugins/lsp/handlers.lua`
- `lua/plugins/completion.lua`

Also check any new plugin files under `lua/plugins/` for keymap additions.

### 3) Normalize and categorize

Update `KEYBINDINGS.md` by grouping into:

- Core
- File/Search
- Git
- Terminal/AI integration
- LSP/Diagnostics
- Which-key helpers
- Completion

For LSP maps, explicitly mark them as buffer-local on `LspAttach`.

### 4) Validate correctness

Run these checks:

```bash
luacheck lua/core/keymaps.lua lua/plugins/*.lua lua/plugins/lsp/*.lua
nvim --headless -u ./init.lua "+qa"
```

If `luacheck` is not installed, still run the headless startup check.

### 5) Final consistency pass

Ensure:

- Leader key note is correct (`<leader>` is `Space`)
- No stale mappings remain
- No duplicate rows with contradictory actions
- Section/file references still match source files

## Common Pitfalls

- Listing mappings from disabled/unloaded modules.
- Forgetting completion keymap tables that are not `vim.keymap.set` calls.
- Treating LSP attach maps as global.
- Missing terminal-mode mappings.
