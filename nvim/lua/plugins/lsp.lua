return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = {
      enabled = false, -- Toggle on/off anytime with <leader>uh
    },
    servers = {
      pyright = { enabled = false },
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
