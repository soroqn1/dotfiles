return {
  -- Official Copilot plugin — inline ghost text suggestions (like Cursor)
  {
    "github/copilot.vim",
    event = "InsertEnter",
    config = function()
      -- Tab is used by blink.cmp, so use Ctrl+J to accept Copilot suggestion
      vim.g.copilot_no_tab_map = true
      vim.keymap.set("i", "<C-j>", 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
        desc = "Accept Copilot suggestion",
      })
      vim.keymap.set("i", "<C-]>", "<Plug>(copilot-next)", { desc = "Next Copilot suggestion" })
      vim.keymap.set("i", "<C-[>", "<Plug>(copilot-previous)", { desc = "Prev Copilot suggestion" })
      vim.keymap.set("i", "<C-e>", "<Plug>(copilot-dismiss)", { desc = "Dismiss Copilot suggestion" })
    end,
  },
}
