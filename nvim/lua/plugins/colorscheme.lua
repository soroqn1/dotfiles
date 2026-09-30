local themes = {
  ["luminous-lake"] = {
    bg = "#1c2f33",
    bg_dark = "#16262a",
    bg_highlight = "#243e43",
    bg_visual = "#30535a",
    border = "#426e76",
    border_highlight = "#5bcde0",
    fg = "#ebf7f7",
    fg_dark = "#78a3a8",
    fg_gutter = "#4a747b",
    comment = "#78a3a8",
    cyan = "#5bcde0",
    teal = "#6bb389",
    green = "#6bb389",
    green1 = "#86d1a5",
    green2 = "#8de6f5",
    blue = "#5299b8",
    blue0 = "#243e43",
    blue1 = "#74bad9",
    blue2 = "#8de6f5",
    blue5 = "#a5d8e2",
    blue6 = "#c2ebf2",
    blue7 = "#1c2f33",
    magenta = "#8d9bf4",
    magenta2 = "#aeb8ff",
    purple = "#8d9bf4",
    yellow = "#f3c36d",
    orange = "#f88b68",
    red = "#f16c44",
    red1 = "#f88b68",
    git_add = "#6bb389",
    git_change = "#f3c36d",
    git_delete = "#f16c44",
    cursor_line_nr = "#6fe7f5",
    win_separator = "#2f4f54",
    inlay_hint = "#52757c",
  },
  ["monterey-dark"] = {
    bg = "#121214",
    bg_dark = "#0a0a0c",
    bg_highlight = "#1c1c1f",
    bg_visual = "#2c3240",
    border = "#323238",
    border_highlight = "#0a84ff",
    fg = "#f0f0f2",
    fg_dark = "#8e8e93",
    fg_gutter = "#636366",
    comment = "#8e8e93",
    cyan = "#64d2ff",
    teal = "#30d158",
    green = "#30d158",
    green1 = "#4cd964",
    green2 = "#8ae0ff",
    blue = "#0a84ff",
    blue0 = "#1c1c1f",
    blue1 = "#409cff",
    blue2 = "#64d2ff",
    blue5 = "#8ae0ff",
    blue6 = "#d0e8ff",
    blue7 = "#121214",
    magenta = "#bf5af2",
    magenta2 = "#da8fff",
    purple = "#bf5af2",
    yellow = "#ffd60a",
    orange = "#ff9f0a",
    red = "#ff453a",
    red1 = "#ff6961",
    git_add = "#30d158",
    git_change = "#ff9f0a",
    git_delete = "#ff453a",
    cursor_line_nr = "#0a84ff",
    win_separator = "#28282d",
    inlay_hint = "#636366",
  },
}

-- Active theme selection: "monterey-dark" or "luminous-lake"
local active_theme = "monterey-dark"
local theme = themes[active_theme] or themes["monterey-dark"]

return {
  -- Configure Tokyo Night with custom palette + Transparency
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      on_colors = function(colors)
        colors.bg = theme.bg
        colors.bg_dark = theme.bg_dark
        colors.bg_float = theme.bg_dark
        colors.bg_sidebar = theme.bg_dark
        colors.bg_statusline = theme.bg_dark
        colors.bg_highlight = theme.bg_highlight
        colors.bg_visual = theme.bg_visual
        colors.border = theme.border
        colors.border_highlight = theme.border_highlight

        colors.fg = theme.fg
        colors.fg_dark = theme.fg_dark
        colors.fg_gutter = theme.fg_gutter
        colors.comment = theme.comment

        colors.cyan = theme.cyan
        colors.teal = theme.teal
        colors.green = theme.green
        colors.green1 = theme.green1
        colors.green2 = theme.green2
        colors.blue = theme.blue
        colors.blue0 = theme.blue0
        colors.blue1 = theme.blue1
        colors.blue2 = theme.blue2
        colors.blue5 = theme.blue5
        colors.blue6 = theme.blue6
        colors.blue7 = theme.blue7
        colors.magenta = theme.magenta
        colors.magenta2 = theme.magenta2
        colors.purple = theme.purple
        colors.yellow = theme.yellow
        colors.orange = theme.orange
        colors.red = theme.red
        colors.red1 = theme.red1

        colors.git = {
          add = theme.git_add,
          change = theme.git_change,
          delete = theme.git_delete,
        }
      end,
      on_highlights = function(hl, c)
        hl.Normal = { bg = "none" }
        hl.NormalNC = { bg = "none" }
        hl.NormalFloat = { bg = "none" }
        hl.SignColumn = { bg = "none" }
        hl.FoldColumn = { bg = "none" }
        hl.LineNr = { fg = theme.fg_gutter, bg = "none" }
        hl.CursorLineNr = { fg = theme.cursor_line_nr, bold = true, bg = "none" }
        hl.FloatBorder = { fg = theme.border, bg = "none" }
        hl.FloatTitle = { fg = theme.border_highlight, bg = "none", bold = true }
        hl.WinSeparator = { fg = theme.win_separator }
        hl.NeoTreeNormal = { bg = "none" }
        hl.NeoTreeNormalNC = { bg = "none" }
        hl.NeoTreeWinSeparator = { fg = theme.win_separator, bg = "none" }
        hl.TelescopeBorder = { fg = theme.border, bg = "none" }
        hl.TelescopePromptBorder = { fg = theme.border_highlight, bg = "none" }
        hl.TelescopeNormal = { bg = "none" }
        hl.LspInlayHint = { fg = theme.inlay_hint, bg = "none" }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },
}
