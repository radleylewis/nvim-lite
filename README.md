# nvim-lite
A minimal neovim configuration.

- IntelliJ migration guide: `IDEA_TO_NEOVIM_GUIDE.md`

Requires NeoVim 0.12 or later

Copy and enjoy it with:
```bash
mkdir -p ~/.config/nvim && curl -fsSL https://raw.githubusercontent.com/radleylewis/nvim-lite/master/init.lua -o ~/.config/nvim/init.lua
```

## Dependencies

NeoVim `0.12` (available in the AUR)
```bash
paru -S neovim-git
```

Treesitter `0.26.5` (install using `cargo`)
```bash
cargo install --locked tree-sitter-cli
```

`golang` (for `efm-langserver`)
```bash
sudo pacman -S go
```

LuaSnip dependencies:
```bash
sudo pacman -S lua-jsregexp
```

Other general dependencies:
```bash
sudo pacman -S git ripgrep fzf fd
```
