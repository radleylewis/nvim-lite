# AGENTS.md

Guidance for agentic coding tools operating in `/Users/pwlazlo/.config/nvim`.
This file documents practical build/lint/test commands and code style rules.

## Repository snapshot
- Type: NeoVim config in Lua.
- Minimum NeoVim version: `0.12+`.
- Entry point: `init.lua`.
- Main modules: `lua/core`, `lua/plugins`, `lua/ui`.
- Language provisioning module: `lua/core/tooling.lua`.
- Plugin management: native `vim.pack.add()`.
- LSP setup: native `vim.lsp.config()` and `vim.lsp.enable()`.
- Lock file: `nvim-pack-lock.json` is tracked; keep it reproducible.
- Lua lint config: `.luacheckrc` (declares `vim` global).
- LuaLS config: `.luarc.json` (declares `vim` global).

## Rule sources checked
- `CLAUDE.md`: present; treat as repository-specific source of truth.
- `.cursor/rules/`: not present.
- `.cursorrules`: not present.
- `.github/copilot-instructions.md`: not present.

If Cursor/Copilot rules are later added, merge them into this file.

## Prerequisites for validation
- Required:
  - `nvim >= 0.12`
  - `tree-sitter-cli >= 0.26.5`
  - `go`
  - `lua-jsregexp`
- Recommended:
  - `git`, `ripgrep`, `fzf`, `fd`
- Optional but useful for agents:
  - `luacheck`
  - `stylua`

## Build/lint/test commands

There is no compile/build system in this repository.
Validation is done with headless startup checks + lint/format checks.

## Language onboarding/tooling behavior
- Language modules (`lua/languages/*.lua`) can declare:
  - `required_tools`
  - `optional_tools`
  - `tool_descriptions`
- On `FileType`, language bootstrap checks required tools and prompts mode when missing:
  - `Interactive`: per-tool decisions with descriptions.
  - `Defaults`: install missing default set without extra per-tool prompts.
- `cancel` does not fail silently; user-facing keymaps report actionable diagnostics.
- `:ToolingHealth` reports installed/missing status per enabled language and can trigger installs.

### Environment and startup checks
- NeoVim version:
  - `nvim --version`
- Basic startup smoke test:
  - `nvim --headless "+qa"`
- Explicitly use this config entrypoint:
  - `nvim --headless -u ./init.lua "+qa"`

### Lint commands
- Lint all Lua code:
  - `luacheck init.lua lua/`
- Lint one file (fast loop):
  - `luacheck lua/plugins/claude.lua`
- Lint selected files:
  - `luacheck lua/core/autocommands.lua lua/plugins/lsp/handlers.lua`

Notes:
- `.luacheckrc` only defines the `vim` global.
- Keep changed files lint-clean at minimum.

### Formatting commands
- Format all Lua files:
  - `stylua init.lua lua/`
- Format one file:
  - `stylua lua/plugins/terminal.lua`
- Check-only mode (if supported by installed Stylua):
  - `stylua --check init.lua lua/`

Notes:
- No `stylua.toml` exists.
- Preserve local file consistency where style differs slightly.

### Test commands

No dedicated unit/integration test suite exists in this repo today.
Use these as the practical test matrix:

- Full smoke test:
  - `nvim --headless -u ./init.lua "+qa"`
- Single module load test:
  - `nvim --headless -u ./init.lua "+lua require('plugins.lsp')" "+qa"`
- Another module load test:
  - `nvim --headless -u ./init.lua "+lua require('plugins.claude')" "+qa"`

### Running a single test (important)

Since no formal test runner exists, a "single test" means:
- `luacheck` on one changed file, or
- one targeted `require()` run in headless NeoVim.

Recommended single-test loop:
1. `luacheck <changed-file>`
2. `nvim --headless -u ./init.lua "+lua require('<changed-module>')" "+qa"`

## Code style guidelines

### General approach
- Write new logic in Lua (avoid new Vimscript unless unavoidable).
- Prefer explicit, readable code over abstraction-heavy helpers.
- Keep modules focused; split only when separation is clear.
- Keep changes minimal and aligned with existing architecture.

### Imports and module boundaries
- Use top-of-file imports: `local x = require("module.path")`.
- Alias reused module values locally (example: `augroup`, `terminal_state`).
- Avoid circular requires and preserve load-order assumptions in `init.lua`.
- Return tables from modules when shared state/functions are needed.

### Formatting and structure
- Match surrounding file indentation and spacing.
- Respect readability around the configured `colorcolumn` of 100 chars.
- Keep trailing commas in multiline tables.
- Do not add low-value comments; comment only non-obvious intent.

### Naming conventions
- Use `snake_case` for locals and local functions.
- Use descriptive names for actions/state (`open_claude_terminal`, `terminal_state`).
- Avoid single-letter names except short loop indices.
- Keep module names purpose-driven and predictable.

### Types and diagnostics
- Keep code compatible with LuaLS behavior.
- Treat `vim` as the intentional global.
- Prefer predictable table shapes and return values.
- If annotations are used, keep them EmmyLua/LuaLS compatible.

### Error handling
- Validate windows/buffers/clients before acting.
- Use early returns for invalid state.
- Wrap risky runtime API calls in `pcall(...)` when appropriate.
- Use `vim.notify(..., vim.log.levels.ERROR/WARN)` for user-visible failures.
- Keep failures non-fatal so startup remains resilient.

### NeoVim API and plugin rules
- Prefer native NeoVim 0.12 APIs over legacy patterns.
- Keep plugin declarations in `vim.pack.add()`.
- Keep LSP config in `vim.lsp.config()` / `vim.lsp.enable()` style.
- When plugin set changes, update and commit `nvim-pack-lock.json`.

### Keymaps and autocmds
- Provide `desc` for non-trivial keymaps.
- Reuse existing augroups instead of ad hoc groups.
- Scope autocmds by `pattern`/`buffer` where possible.
- Keep callbacks small; extract local helpers as complexity grows.

## Change management expectations
- Do not introduce external plugin managers.
- Do not remove user-facing keybinds without clear replacement rationale.
- Update `CLAUDE.md` when behavior or workflow materially changes.
- Prefer minimal diffs over broad rewrites.

## Recommended pre-handoff validation
1. `luacheck <touched-lua-files>`
2. `nvim --headless -u ./init.lua "+qa"`
3. Targeted module check with `require()` for changed modules

For larger refactors, also run:
4. `luacheck init.lua lua/`
5. Manual interactive sanity check by launching `nvim`

Keep this file synchronized with real repository behavior.
