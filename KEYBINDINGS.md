# Neovim Keybindings Cheatsheet

This document lists the keymaps currently configured in this repository.

- Leader key: `<leader>` = `Space`
- Local leader key: `<localleader>` = `Space`
- Scope notes:
  - `LSP` mappings are buffer-local and available after an LSP client attaches.
  - `Completion` mappings apply inside the blink.cmp completion menu context.

## Core (`lua/core/keymaps.lua`)

| Mode | Key | Action |
|---|---|---|
| n | `j` | Down (wrap-aware) |
| n | `k` | Up (wrap-aware) |
| n | `<leader>c` | Clear search highlights |
| n | `n` | Next search result (centered) |
| n | `N` | Previous search result (centered) |
| n | `<C-d>` | Half page down (centered) |
| n | `<C-u>` | Half page up (centered) |
| x | `<leader>p` | Paste without yanking |
| n,v | `<leader>x` | Delete without yanking |
| n | `<leader>bn` | Next buffer |
| n | `<leader>bp` | Previous buffer |
| n | `<C-h>` | Move to left window |
| n | `<C-j>` | Move to bottom window |
| n | `<C-k>` | Move to top window |
| n | `<C-l>` | Move to right window |
| n | `<leader>sv` | Split window vertically |
| n | `<leader>sh` | Split window horizontally |
| n | `<C-Up>` | Increase window height |
| n | `<C-Down>` | Decrease window height |
| n | `<C-Left>` | Decrease window width |
| n | `<C-Right>` | Increase window width |
| n | `<C-A-j>` | Move line down |
| n | `<C-A-k>` | Move line up |
| v | `<C-A-j>` | Move selection down |
| v | `<C-A-k>` | Move selection up |
| v | `<` | Indent left and reselect |
| v | `>` | Indent right and reselect |
| n | `J` | Join lines and keep cursor position |
| n | `<leader>pa` | Copy full file path to clipboard |
| n | `<leader>td` | Toggle diagnostics |

## File/Search (`lua/plugins/nvim-tree.lua`, `lua/plugins/fzf-lua.lua`)

| Mode | Key | Action |
|---|---|---|
| n | `<leader>e` | Toggle NvimTree |
| n | `<leader>ff` | FZF files |
| n | `<leader>fg` | FZF live grep |
| n | `<leader>fb` | FZF buffers |
| n | `<leader>fh` | FZF help tags |
| n | `<leader>fx` | FZF diagnostics (document) |
| n | `<leader>fX` | FZF diagnostics (workspace) |

## Git (`lua/plugins/gitsigns.lua`)

| Mode | Key | Action |
|---|---|---|
| n | `]h` | Next git hunk |
| n | `[h` | Previous git hunk |
| n | `<leader>hs` | Stage hunk |
| n | `<leader>hr` | Reset hunk |
| n | `<leader>hp` | Preview hunk |
| n | `<leader>hb` | Blame line |
| n | `<leader>hB` | Toggle inline blame |
| n | `<leader>hd` | Open file diff |
| n | `<leader>hD` | Close file diff |
| n | `<leader>ht` | Toggle file diff |

## Terminal and Kilo (`lua/plugins/terminal.lua`, `lua/plugins/kilo.lua`)

| Mode | Key | Action |
|---|---|---|
| n | `<leader>t` | Toggle floating terminal |
| t | `<Esc>` | Close floating terminal |
| n | `<leader>cc` | Open Kilo terminal |
| n | `<leader>cf` | Run Kilo with current file |
| v | `<leader>cs` | Run Kilo with selection |

## LSP and Diagnostics (`lua/plugins/lsp/handlers.lua`)

### LSP attach (buffer-local)

| Mode | Key | Action |
|---|---|---|
| n | `<leader>gd` | Go to definition (fzf-lua) |
| n | `<leader>gD` | Go to definition (direct LSP) |
| n | `<leader>gS` | Open definition in vertical split |
| n | `<leader>ca` | Code action |
| n | `<leader>rn` | Rename symbol |
| n | `<leader>D` | Line diagnostics float |
| n | `<leader>d` | Cursor diagnostics float |
| n | `<leader>nd` | Next diagnostic |
| n | `<leader>pd` | Previous diagnostic |
| n | `K` | Hover |
| n | `<leader>fd` | LSP definitions (fzf-lua) |
| n | `<leader>fr` | LSP references (fzf-lua) |
| n | `<leader>ft` | LSP type definitions (fzf-lua) |
| n | `<leader>fs` | LSP document symbols (fzf-lua) |
| n | `<leader>fw` | LSP workspace symbols (fzf-lua) |
| n | `<leader>fi` | LSP implementations (fzf-lua) |
| n | `<leader>oi` | Organize imports + format (if supported) |

### Global diagnostics

| Mode | Key | Action |
|---|---|---|
| n | `<leader>q` | Open diagnostic location list |
| n | `<leader>dl` | Show line diagnostics |

## Which-Key (`lua/plugins/which-key.lua`)

| Mode | Key | Action |
|---|---|---|
| n | `<leader>?` | Show buffer-local keymaps (which-key) |
| n | `<C-w><Space>` | Window hydra mode (which-key) |

Registered prefix groups (discoverability labels):

- `<leader><Tab>` tabs
- `<leader>b` buffer
- `<leader>c` code
- `<leader>d` debug
- `<leader>dp` profiler
- `<leader>f` file/find
- `<leader>g` git
- `<leader>gh` hunks
- `<leader>q` quit/session
- `<leader>s` search
- `<leader>u` ui
- `<leader>w` windows (proxy for `<C-w>`)
- `<leader>x` diagnostics/quickfix
- `[` prev, `]` next, `g` goto, `gs` surround, `z` fold
- `gx` open with system app

## Completion (`lua/plugins/completion.lua`)

| Mode | Key | Action |
|---|---|---|
| i/cmp | `<C-Space>` | Show/hide completion menu |
| i/cmp | `<CR>` | Accept completion |
| i/cmp | `<C-j>` | Select next item |
| i/cmp | `<C-k>` | Select previous item |
| i/cmp | `<Tab>` | Snippet jump forward |
| i/cmp | `<S-Tab>` | Snippet jump backward |
