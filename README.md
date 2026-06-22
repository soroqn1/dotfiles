# dotfiles

My personal configuration files for everyday development.

## Stack

| Tool | Description |
| ---- | ----------- |
| [Ghostty](https://ghostty.org) | Terminal emulator |
| [Fish](https://fishshell.com) | Shell |
| [Tide](https://github.com/IlanCosman/tide) | Fish prompt |
| [Neovim](https://neovim.io) + [LazyVim](https://lazyvim.org) | Editor |
| [atuin](https://atuin.sh) | Shell history (fuzzy, Ctrl+R) |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart directory jumping (`z`) |

## Neovim keybindings

`Leader` = `Space`

### Buffers

| Key | Action |
| --- | ------ |
| `Tab` | Next buffer |
| `Shift+Tab` | Previous buffer |
| `<leader>x` | Close current buffer |

### Windows

| Key | Action |
| --- | ------ |
| `Ctrl+h/j/k/l` | Move between splits |
| `Ctrl+↑↓←→` | Resize split |

### Diagnostics

| Key | Action |
| --- | ------ |
| `]e` / `[e` | Next / prev error |
| `]d` / `[d` | Next / prev diagnostic |
| `<leader>D` | Show diagnostic float |

### Git (gitsigns)

| Key | Action |
| --- | ------ |
| `]h` / `[h` | Next / prev hunk |
| `<leader>gp` | Preview hunk |
| `<leader>gs` | Stage hunk |
| `<leader>gr` | Reset hunk |
| `<leader>gb` | Blame line |

### Editor

| Key | Action |
| --- | ------ |
| `Ctrl+d/u` | Scroll down / up (centered) |
| `J/K` (visual) | Move selection down / up |
| `p` (visual) | Paste without losing clipboard |
| `Ctrl+J` | Accept Copilot suggestion |

## Fish abbreviations

| Abbr | Command |
| ---- | ------- |
| `v` | `nvim` |
| `lg` | `lazygit` |
| `lzd` | `lazydocker` |
| `z <name>` | Jump to directory (zoxide) |

## Setup

```sh
git clone git@github.com:soroqn1/dotfiles.git ~/dotfiles

ln -sf ~/dotfiles/ghostty ~/.config/ghostty
ln -sf ~/dotfiles/fish ~/.config/fish
ln -sf ~/dotfiles/nvim ~/.config/nvim
ln -sf ~/dotfiles/atuin ~/.config/atuin
ln -sf ~/dotfiles/bin/copilot-commit.sh ~/.local/bin/copilot-commit.sh
```
