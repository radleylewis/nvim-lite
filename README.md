
<div align="right">
  <details>
    <summary >🌐 Language</summary>
    <div>
      <div align="center">
        <a href="https://openaitx.github.io/view.html?user=radleylewis&project=nvim-lite&lang=en">English</a>
        | <a href="https://openaitx.github.io/view.html?user=radleylewis&project=nvim-lite&lang=zh-CN">简体中文</a>
        | <a href="https://openaitx.github.io/view.html?user=radleylewis&project=nvim-lite&lang=zh-TW">繁體中文</a>
        | <a href="https://openaitx.github.io/view.html?user=radleylewis&project=nvim-lite&lang=ja">日本語</a>
        | <a href="https://openaitx.github.io/view.html?user=radleylewis&project=nvim-lite&lang=ko">한국어</a>
        | <a href="https://openaitx.github.io/view.html?user=radleylewis&project=nvim-lite&lang=hi">हिन्दी</a>
        | <a href="https://openaitx.github.io/view.html?user=radleylewis&project=nvim-lite&lang=th">ไทย</a>
        | <a href="https://openaitx.github.io/view.html?user=radleylewis&project=nvim-lite&lang=fr">Français</a>
        | <a href="https://openaitx.github.io/view.html?user=radleylewis&project=nvim-lite&lang=de">Deutsch</a>
        | <a href="https://openaitx.github.io/view.html?user=radleylewis&project=nvim-lite&lang=es">Español</a>
        | <a href="https://openaitx.github.io/view.html?user=radleylewis&project=nvim-lite&lang=it">Italiano</a>
        | <a href="https://openaitx.github.io/view.html?user=radleylewis&project=nvim-lite&lang=ru">Русский</a>
        | <a href="https://openaitx.github.io/view.html?user=radleylewis&project=nvim-lite&lang=pt">Português</a>
        | <a href="https://openaitx.github.io/view.html?user=radleylewis&project=nvim-lite&lang=nl">Nederlands</a>
        | <a href="https://openaitx.github.io/view.html?user=radleylewis&project=nvim-lite&lang=pl">Polski</a>
        | <a href="https://openaitx.github.io/view.html?user=radleylewis&project=nvim-lite&lang=ar">العربية</a>
        | <a href="https://openaitx.github.io/view.html?user=radleylewis&project=nvim-lite&lang=fa">فارسی</a>
        | <a href="https://openaitx.github.io/view.html?user=radleylewis&project=nvim-lite&lang=tr">Türkçe</a>
        | <a href="https://openaitx.github.io/view.html?user=radleylewis&project=nvim-lite&lang=vi">Tiếng Việt</a>
        | <a href="https://openaitx.github.io/view.html?user=radleylewis&project=nvim-lite&lang=id">Bahasa Indonesia</a>
      </div>
    </div>
  </details>
</div>

# nvim-lite
A minimal neovim configuration.

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
