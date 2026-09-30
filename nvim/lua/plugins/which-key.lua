return {
  "folke/which-key.nvim",
  opts = {
    win = {
      border = "rounded",
    },
    spec = {
      { "<leader>d", group = "docker" },
      { "<leader>dl", desc = "Lazydocker" },
      { "<leader>D", group = "debug" },
      { "<leader>f", group = "file/search" },
      { "<leader>w", group = "windows/tabs" },
    },
  },
}
