return {
  "lewis6991/gitsigns.nvim",
  opts = {
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
    },
    -- show git blame inline on current line
    current_line_blame = true,
    current_line_blame_opts = {
      delay = 500,
      virt_text_pos = "eol",
    },
    on_attach = function(buf)
      local gs = package.loaded.gitsigns
      local map = function(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = buf, desc = desc })
      end

      -- navigation
      map("n", "]h", gs.next_hunk, "Next hunk")
      map("n", "[h", gs.prev_hunk, "Prev hunk")

      -- actions
      map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
      map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
      map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
      map("n", "<leader>gb", gs.blame_line, "Blame line")

    end,
  },
}
