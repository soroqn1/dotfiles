return {
  "folke/snacks.nvim",
  opts = {
    explorer = {
      enabled = false,
    },
    picker = {
      sources = {
        files = {
          hidden = true, -- search hidden files
          ignored = true, -- search gitignored files
          exclude = { ".DS_Store", "thumbs.db" },
        },
      },
    },
  },
  keys = {
    { "<leader>e", false },
    { "<leader>E", false },
  },
}
