# dotfiles

Personal configuration files for terminal setup.

## Structure

```
.config/
  ghostty/    — Ghostty terminal config
  fish/       — Fish shell config, abbreviations, completions
  nvim/       — Neovim config (LazyVim-based)
.local/
  bin/
    copilot-commit.sh  — AI commit message generator via GitHub Copilot
```

## Setup

```sh
# Clone
git clone git@github.com:soroqn1/dotfiles.git ~/dotfiles

# Symlink configs
ln -sf ~/dotfiles/.config/ghostty ~/.config/ghostty
ln -sf ~/dotfiles/.config/fish ~/.config/fish
ln -sf ~/dotfiles/.config/nvim ~/.config/nvim
ln -sf ~/dotfiles/.local/bin/copilot-commit.sh ~/.local/bin/copilot-commit.sh
```

## Stack

- **Terminal**: [Ghostty](https://ghostty.org)
- **Shell**: [Fish](https://fishshell.com) + [Tide](https://github.com/IlanCosman/tide) prompt
- **Editor**: [Neovim](https://neovim.io) + [LazyVim](https://lazyvim.org)
- **History**: [atuin](https://atuin.sh)
- **Jump**: [zoxide](https://github.com/ajeetdsouza/zoxide)
