# Neovim for IntelliJ IDEA Developers

This guide translates common IntelliJ IDEA workflows into this Neovim configuration.

Audience: developers who are productive in IntelliJ and want equivalent daily workflows in Neovim without losing speed.

## Mental Model Shift

- IntelliJ: one integrated UI with fixed workflows.
- This Neovim setup: composable tools with leader-key commands and fuzzy pickers.
- Goal: keep your intent the same (navigate, refactor, run, debug, test), even if the UI shape is different.

Leader key in this config is `Space`.

## Quick Start (What to Learn First)

1. File and symbol navigation: `<leader>ff`, `<leader>fs`, `<leader>fw`, `<leader>se`
2. Code intelligence: `<leader>gd`, `<leader>fr`, `<leader>ca`, `<leader>rn`
3. Run/test/debug loop: `<leader>rr`, `<leader>tn`, `<leader>db`, `<leader>dc`, `<leader>du`
4. Diagnostics and fixes: `<leader>xx`, `<leader>oi`, `<leader>ou`, `<leader>of`
5. IntelliJ-style aliases (single prefix): `<leader>j*`

## Common Action Mapping (IntelliJ -> Neovim)

| Developer intent | IntelliJ IDEA action | This Neovim mapping | Backend |
|---|---|---|---|
| Search actions/features | Search Everywhere (`Shift` x2) | `<leader>se` or `<leader>fe` | `fzf-lua` builtin picker |
| Go to file | Go to File (`Cmd/Ctrl+Shift+O` / `N`) | `<leader>ff` or `<leader>jf` | `fzf-lua files` |
| Recent files | Recent Files (`Cmd/Ctrl+E`) | `<leader>fo` | `fzf-lua oldfiles` |
| Recent locations | Recent Locations (`Cmd/Ctrl+Shift+E`) | `<leader>fj` | `fzf-lua jumps` |
| Go to class | Go to Class (`Cmd/Ctrl+O` / `N`) | `<leader>jc` | `fzf-lua lsp_workspace_symbols` |
| Go to symbol | Go to Symbol (`Cmd/Ctrl+Alt+O`) | `<leader>js` or `<leader>fs` | `fzf-lua lsp_document_symbols` |
| Go to definition | Go to Declaration/Definition (`Cmd/Ctrl+B`) | `<leader>gd` | LSP + `fzf-lua` |
| Find usages | Find Usages (`Alt+F7`) | `<leader>ju` or `<leader>fr` | LSP references |
| Show docs | Quick Documentation (`F1`) | `K` | LSP hover |
| Rename symbol | Rename (`Shift+F6`) | `<leader>rn` or `<leader>jr` | LSP + `inc-rename` |
| Quick fix / intention actions | Show Context Actions (`Alt+Enter`) | `<leader>ca` | LSP code actions |
| Organize imports | Optimize Imports (`Cmd/Ctrl+Alt+O`) | `<leader>oi` | LSP source action |
| Remove unused imports | (Usually via inspections/fix) | `<leader>ou` | LSP source action |
| Fix all auto-fixables | (Usually via inspections/fix) | `<leader>of` | LSP source action |
| Refactor menu | Refactor This (`Cmd/Ctrl+Alt+Shift+T`) | `<leader>jm` or `<leader>rm` | `refactoring.nvim` |
| Extract method/function | Extract Method (`Cmd/Ctrl+Alt+M`) | `<leader>re` (normal/visual) | `refactoring.nvim` |
| Extract variable | Extract Variable (`Cmd/Ctrl+Alt+V`) | `<leader>rv` (normal/visual) | `refactoring.nvim` |
| Show problems panel | Problems tool window | `<leader>xx`, `<leader>xw`, `<leader>xq`, `<leader>xl` | `trouble.nvim` |
| Run named task | Run Anything / Run config | `<leader>rr`, `<leader>rd/rb/rt/rl` | `overseer.nvim` + language task providers |
| Run nearest test | Run test at cursor | `<leader>tn` or `<leader>jt` | `neotest` |
| Run test file | Run current test file | `<leader>tf` | `neotest` |
| Run full test project | Run all tests | `<leader>ta` | `neotest` |
| Debug nearest test | Debug test | `<leader>tv` | `neotest` + DAP |
| Toggle breakpoint | Toggle breakpoint (`Cmd/Ctrl+F8`) | `<leader>db` | `nvim-dap` |
| Start/continue debug | Resume Program (`F9`) | `<leader>dc` or `<leader>jd` | `nvim-dap` |
| Step over | Step Over (`F8`) | `<leader>do` | `nvim-dap` |
| Step into | Step Into (`F7`) | `<leader>di` | `nvim-dap` |
| Step out | Step Out (`Shift+F8`) | `<leader>dO` | `nvim-dap` |
| View variables/frames | Debug tool windows | `<leader>du` | `nvim-dap-ui` |
| Stop debugging | Stop (`Cmd/Ctrl+F2`) | `<leader>dx` | `nvim-dap` |

## Java Workflow (Maven + Gradle)

- LSP attaches via `nvim-jdtls` with `start_or_attach` on Java buffers.
- Root detection includes `.git`, `mvnw`, `pom.xml`, `gradlew`, `settings.gradle`, `build.gradle`.
- Wrapper-first task execution is built in:
  - Gradle: `./gradlew` before `gradle`
  - Maven: `./mvnw` before `mvn`
- Keymaps:
  - `<leader>rr` task picker (shows Java build/test/clean/run tasks)
  - `<leader>rb`, `<leader>rt`, `<leader>rd` for fast build/test/run
  - `<leader>tC` test Java class (buffer-local)
  - `<leader>jO` organize imports (buffer-local)
- Debugging reuses existing DAP keymaps (`<leader>d*`) through jdtls DAP integration.

## IntelliJ-Style Alias Layer (`<leader>j`)

For muscle-memory-friendly workflows, this config includes a dedicated IDEA-like alias prefix:

- `<leader>jf`: go to file
- `<leader>jc`: go to class
- `<leader>js`: go to symbol
- `<leader>ju`: find usages
- `<leader>jr`: rename
- `<leader>jm`: refactor menu
- `<leader>jd`: debug/continue
- `<leader>jt`: run nearest test

These aliases are additive and do not replace existing Vim-native mappings.

## Feature Comparison: IntelliJ IDEA vs This Neovim Setup

| Capability | IntelliJ IDEA | This Neovim setup (Phase 1 baseline) |
|---|---|---|
| Editor and modal speed | Non-modal, heavy IDE UX | Modal editing, lightweight, highly keyboard-driven |
| Search everywhere | Unified, first-class global action | Action-level search hub via `fzf-lua` builtin (`<leader>se`) |
| Project/file navigation | Excellent | Excellent with `fzf-lua` + tree + recent pickers |
| Symbol navigation | Excellent | Strong (LSP + aerial + fzf symbol pickers) |
| Find usages/references | Excellent | Strong (LSP references via `fzf-lua`) |
| Refactorings depth | Very deep and language-specific | Good baseline (`rename`, extracts, code actions), less exhaustive |
| Import management | Strong | Strong where LSP server supports source actions |
| Debugger UX | Integrated, polished | Functional and productive (`nvim-dap` + `dap-ui`), less turnkey |
| Test runner UX | Integrated runners, gutters, history | Strong baseline with `neotest` (nearest/file/project/debug) |
| Build/run configurations | Rich GUI configs, templates | Script/task-oriented via `overseer` and package scripts |
| Diagnostics/problems panel | Mature inspections + workflow | Good parity via `trouble.nvim` + diagnostics lists |
| VCS workflows | Rich built-in log/changelists/merge tools | Solid basics (`gitsigns` + fuzzy + terminal git), less visual breadth |
| Session/workspace restore | Built-in project model | Planned for Phase 2 (not baseline-complete yet) |
| Monorepo ergonomics | Mature | Basic root detection now; monorepo hardening planned (Phase 2) |
| Startup/perf footprint | Heavier | Lighter runtime footprint |
| Extensibility | Plugin ecosystem, IDE-centric | Extremely flexible Lua ecosystem and terminal composability |

## Current Baseline vs Planned Enhancements

Phase 1+ delivered:

- JS/TS + Node run/test/debug backbone
- Java Maven/Gradle LSP + test + debug + task support
- IntelliJ-like alias keymaps without removing existing mappings
- Search/symbol/diagnostics/refactor baseline ergonomics

Planned next (Phase 2+):

- Stronger workspace/session restore
- Better monorepo root/workspace behavior
- Enhanced diagnostics/project inspection views
- Expanded polyglot parity (Python/Go/C++) with same architecture

## Suggested Transition Plan for IntelliJ Users

Week 1:

- Use Neovim for navigation + edits only (`<leader>ff`, `<leader>gd`, `<leader>fr`, `K`, `<leader>rn`).

Week 2:

- Move test loop into Neovim (`<leader>tn`, `<leader>tf`, `<leader>ta`).

Week 3:

- Move debug loop into Neovim (`<leader>db`, `<leader>dc`, `<leader>du`).

Week 4:

- Adopt alias layer `<leader>j*` as your default IDE workflow surface.

## Notes

- If an action appears missing, first check whether your active LSP server supports it.
- `js-debug-adapter` must be available for Node debug sessions.
- For complete mapping reference, see `KEYBINDINGS.md`.
