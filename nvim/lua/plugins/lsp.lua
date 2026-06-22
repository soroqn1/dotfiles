return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- basedpyright: drop-in replacement for pyright, doesn't hang
      basedpyright = {
        settings = {
          basedpyright = {
            analysis = {
              diagnosticMode = "workspace",
              typeCheckingMode = "standard",
            },
          },
        },
      },
      ruff = {
        cmd = { "ruff", "server", "--preview" },
      },
    },
  },
}
