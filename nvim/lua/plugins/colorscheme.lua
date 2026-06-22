return {
  -- Configure the Tokyo Night theme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night", -- options: storm, moon, night, day
      transparent = false, -- change to true if you prefer transparent backgrounds
      styles = {
        sidebars = "dark",
        floats = "dark",
      },
    },
  },
  -- Configure LazyVim to load tokyonight-night
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },
}
