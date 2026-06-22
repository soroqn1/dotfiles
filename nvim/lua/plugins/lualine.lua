return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    -- Remove the cursor position, file progress, and time from the right side
    opts.sections.lualine_y = {}
    opts.sections.lualine_z = {}

    -- Use rounded (pill-like) separators for statusline blocks
    opts.options = opts.options or {}
    opts.options.component_separators = { left = "", right = "" }
    opts.options.section_separators = { left = "", right = "" }

    -- Show only the active virtual environment on the right side
    opts.sections.lualine_x = {
      {
        function()
          local venv = vim.env.VIRTUAL_ENV or vim.env.CONDA_DEFAULT_ENV
          if venv then
            return " (" .. vim.fn.fnamemodify(venv, ":t") .. ")"
          end
          return ""
        end,
        color = { fg = "#7aa2f7" }, -- Tokyo Night blue color
      },
    }
  end,
}
