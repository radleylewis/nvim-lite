# nvim-lite

A powerful but tastefully minimal Neovim configuration in a single file. No third-party plugin manager. No bloat.

*Author: Radley E. Sidwell-Lewis*

## Requirements

- Neovim `0.12` or later (uses the built-in `vim.pack` plugin manager)
- A [Nerd Font](https://www.nerdfonts.com/) (FiraCode Nerd Font recommended)
- `git`, `ripgrep`, `fzf`, `fd`: fuzzy finding and grep
- `tree-sitter` CLI: compiles Treesitter parsers
- `node` / `npm`: most language servers and formatters are Node packages
- `go`: Mason builds `gopls`, `gofumpt` and `revive` from source
- `wl-clipboard` (Wayland) or `xclip` (X11): system clipboard integration

## Installation

```bash
mkdir -p ~/.config/nvim && curl -fsSL https://raw.githubusercontent.com/radleylewis/nvim-lite/master/init.lua -o ~/.config/nvim/init.lua
```

> **Note:** If you already have a Neovim config, back it up first.

Plugins are installed automatically on first launch. Treesitter parsers are installed in the background on first launch too, so highlighting may take a moment to appear the first time.

## Dependencies

**Arch:**

```bash
sudo pacman -S neovim tree-sitter-cli git ripgrep fzf fd go nodejs npm wl-clipboard
```

**Language servers, linters and formatters** are managed via [Mason](https://github.com/mason-org/mason.nvim). To install everything this config uses in one go, run inside Neovim:

```vim
:MasonInstall lua-language-server pyright bash-language-server typescript-language-server gopls clangd json-lsp yaml-language-server docker-language-server emmet-language-server tailwindcss-language-server rust-analyzer efm stylua ruff prettierd eslint_d fixjson shellcheck shfmt cpplint clang-format revive gofumpt hadolint
```

Keep them up to date with `:Mason` then `U`.

> **Rust:** `rustaceanvim` uses whichever `rust-analyzer` is on your `PATH`. Either the Mason install above or `rustup component add rust-analyzer` works.

## Features

- Single `init.lua`, using Neovim's native `vim.pack` with a committed lockfile (`nvim-pack-lock.json`)
- Treesitter highlighting and folding (`nvim-treesitter`, `main` branch)
- LSP via `nvim-lspconfig` + `vim.lsp.enable`, with `blink.cmp` (v1, prebuilt Rust fuzzy matcher downloaded automatically) for completion and signature help
- Linting and formatting via `efm-langserver`, with format-on-save for every language in the table below except Markdown (so notes aren't rewritten on every save)
- Per-project sessions: run `nvim` with no file arguments in a directory to reopen the files and splits you had last time there. Sessions are saved on exit and stored in `~/.local/share/nvim/session/`, not in your projects. `nvim somefile` opens normally and never overwrites the session
- Rust support via `rustaceanvim`
- Fuzzy finding via `fzf-lua`
- File tree via `nvim-tree`
- Git hunks, staging and blame via `mini.diff` and `mini.git`
- `mini.nvim` modules: `ai`, `comment`, `move`, `surround`, `pairs`, `cursorword`, `indentscope`, `trailspace`, `notify`, `icons`, `clue`, `sessions`, `diff`, `git`
- Keymap hints as you type (`mini.clue`): press `<leader>`, `g`, `[` or `]` and wait
- Floating terminal (`<leader>t`)
- Obsidian note-taking via `obsidian.nvim` (notes at `~/Documents/Notes` on Artix, `Documents/Notes` in your Windows user folder on Ubuntu/WSL, found automatically; skipped on other systems or if no Notes folder exists). Lazy-loaded: it only starts when you open a Markdown file or press a `<leader>n` key
- Persistent undo (history survives closing files), stored in `~/.local/state/nvim/undo/`
- Fast startup (~75ms): `obsidian.nvim` and `fzf-lua` load on first use
- Seamless navigation between Neovim splits and tmux panes (`vim-tmux-navigator`)
- `lualine` statusline (melange theme) with mode, branch, filename, file size and filetype
- `melange` colour scheme with a transparent background (re-applied after any `:colorscheme` change), and rounded borders on all floating windows
- CI: every push and PR does a fresh install of the config on Neovim 0.12 and fails if startup reports any error, then installs `lua_ls`, `efm` and `stylua` and checks that they attach and that format-on-save works

## Language support

| Language | LSP | Lint / format (efm) |
|----------|-----|---------------------|
| Lua | `lua_ls` (also does linting) | — / stylua |
| Python | `pyright` | ruff / ruff |
| JavaScript / TypeScript (+ JSX/TSX) | `ts_ls` | eslint_d / prettierd |
| Vue / Svelte | — | eslint_d / prettierd |
| HTML / CSS | `emmet_language_server`, `tailwindcss` (only in projects with a `tailwind.config.*` or `tailwindcss` in `package.json`) | — / prettierd |
| JSON | `jsonls` | — / fixjson |
| JSONC | `jsonls` | — / prettierd (keeps comments) |
| YAML | `yamlls` | — |
| Markdown | — | — / prettierd (manual only: `:lua vim.lsp.buf.format()`) |
| Bash / sh | `bashls` | shellcheck / shfmt |
| Go | `gopls` | revive / gofumpt |
| C / C++ | `clangd` | cpplint / clang-format |
| Rust | `rust-analyzer` (via rustaceanvim) | — |
| Dockerfile | `docker_language_server` | hadolint / — |

## Keymaps

The leader key is `<Space>`. Press `<leader>` and pause to see every available mapping (`mini.clue`).

### General

| Key | Mode | Action |
|-----|------|--------|
| `<Esc>` | n | Clear search highlights |
| `n` / `N` | n | Next / previous search result (centred) |
| `<C-d>` / `<C-u>` | n | Half-page down / up (centred) |
| `j` / `k` | n | Move by display line when lines wrap |
| `J` | n | Join lines, keeping the cursor in place |
| `<A-j>` / `<A-k>` | n, v | Move line / selection down / up (re-indents) |
| `<A-h>` / `<A-l>` | n, v | Move line / selection left / right |
| `<` / `>` | v | Indent and keep the selection |
| `<leader>p` | v | Paste over selection without overwriting the register |
| `<leader>x` | n, v | Delete without yanking |
| `<leader>pa` | n | Copy the current file's full path |

### Windows, buffers & terminal

| Key | Action |
|-----|--------|
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | Move between splits and tmux panes |
| `<leader>sv` / `<leader>sh` | Split vertically / horizontally |
| `<C-Up>` / `<C-Down>` | Increase / decrease window height |
| `<C-Left>` / `<C-Right>` | Decrease / increase window width |
| `<leader>bn` / `<leader>bp` | Next / previous buffer |
| `<leader>e` | Toggle file tree |
| `<leader>t` | Toggle floating terminal |
| `<Esc><Esc>` | (terminal) Exit to normal mode. A single `<Esc>` is passed to the shell |
| `<C-q>` | (terminal) Close the floating terminal |

### Search (fzf-lua)

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fh` | Help tags |
| `<leader>fx` / `<leader>fX` | Diagnostics for this file / workspace |

### LSP

Available in buffers with a language server attached.

| Key | Action |
|-----|--------|
| `K` | Hover documentation |
| `<leader>gd` | Go to definition (fzf picker; jumps directly if only one result) |
| `<leader>gD` | Go to definition (built-in) |
| `<leader>gS` | Go to definition in a vertical split |
| `<leader>fr` | References |
| `<leader>fi` | Implementations |
| `<leader>ft` | Type definitions |
| `<leader>fs` / `<leader>fw` | Document / workspace symbols |
| `<leader>ca` | Code action |
| `<leader>rn` | Rename symbol |
| `<leader>oi` | Organise imports, then format |

### Diagnostics

| Key | Action |
|-----|--------|
| `<leader>d` | Show diagnostics under the cursor |
| `<leader>D` | Show diagnostics for the whole line |
| `<leader>nd` / `<leader>pd` | Next / previous diagnostic |
| `<leader>q` | Open all diagnostics in the location list |
| `<leader>ud` | Toggle diagnostics on/off |

### Git (mini.diff / mini.git)

| Key | Action |
|-----|--------|
| `]h` / `[h` | Next / previous hunk |
| `]H` / `[H` | Last / first hunk |
| `<leader>hs` | Stage the hunk under the cursor |
| `gh{motion}` / `gH{motion}` | Stage / reset hunks covered by a motion (e.g. `ghip`, `gHgh`) |
| `<leader>hp` | Toggle the inline diff overlay |
| `<leader>hb` | Show git blame / history for the line under the cursor |

### Notes (obsidian.nvim)

| Key | Action |
|-----|--------|
| `<leader>nn` | New note |
| `<leader>nf` | Find note |
| `<leader>ns` | Search notes |
| `<leader>nt` | Today's daily note |
| `<leader>nw` | Switch workspace |

### Completion (blink.cmp, insert mode)

| Key | Action |
|-----|--------|
| `<C-Space>` | Show / hide the completion menu |
| `<C-j>` / `<C-k>` | Next / previous item |
| `<CR>` | Accept |
| `<Tab>` / `<S-Tab>` | Jump to next / previous snippet placeholder |

The completion menu does not open automatically in Markdown files; use `<C-Space>`.

### Editing (mini.nvim)

| Key | Action |
|-----|--------|
| `gc{motion}` / `gcc` | Toggle comment (motion / line) |
| `sa` / `sd` / `sr` | Add / delete / replace surrounding (e.g. `saiw"`, `sd"`, `sr"'`) |
| `a` / `i` text objects | Extended around/inside objects, e.g. `cia` (argument), `dif` (function call), `vaq` (any quote) |
