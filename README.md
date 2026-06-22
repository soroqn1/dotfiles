# dotfiles

Personal configuration files.

## Structure

```
ghostty/    — Ghostty terminal config
fish/       — Fish shell (config, abbreviations, completions)
nvim/       — Neovim config (LazyVim-based)
bin/
  copilot-commit.sh  — AI commit message via GitHub Copilot
```

## Setup

```sh
git clone git@github.com:soroqn1/dotfiles.git ~/dotfiles

ln -sf ~/dotfiles/ghostty ~/.config/ghostty
ln -sf ~/dotfiles/fish ~/.config/fish
ln -sf ~/dotfiles/nvim ~/.config/nvim
ln -sf ~/dotfiles/bin/copilot-commit.sh ~/.local/bin/copilot-commit.sh
```

## Stack

- **Terminal**: [Ghostty](https://ghostty.org)
- **Shell**: [Fish](https://fishshell.com) + [Tide](https://github.com/IlanCosman/tide)
- **Editor**: [Neovim](https://neovim.io) + [LazyVim](https://lazyvim.org)
- **History**: [atuin](https://atuin.sh)
- **Jump**: [zoxide](https://github.com/ajeetdsouza/zoxide)
