return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "pyright",
        "ruff",
        "vtsls",
        "yaml-language-server",
        "json-lsp",
      })
      opts.ui = opts.ui or {}
      opts.ui.border = "rounded"
    end,
  },
}
