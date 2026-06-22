return {
  -- Inline image rendering (Kitty/Ghostty graphics protocol)
  {
    "3rd/image.nvim",
    lazy = true,
    ft = { "markdown", "norg", "oil" },
    opts = {
      backend = "kitty",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = false,
          filetypes = { "markdown" },
        },
      },
      max_width = 80,
      max_height = 30,
      window_overlap_clear_enabled = true,
    },
  },
}
