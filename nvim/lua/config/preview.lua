-- PDF: open as readable text via pdftotext (requires poppler)
vim.api.nvim_create_autocmd("BufReadPre", {
  pattern = "*.pdf",
  callback = function()
    local file = vim.fn.expand("<afile>")
    vim.bo.buftype = "nofile"
    vim.bo.readonly = true
    vim.cmd("silent! %d")
    vim.fn.jobstart({ "pdftotext", "-layout", file, "-" }, {
      stdout_buffered = true,
      on_stdout = function(_, data)
        if data then
          vim.api.nvim_buf_set_lines(0, 0, -1, false, data)
        end
      end,
    })
    vim.bo.filetype = "text"
  end,
})

-- DOCX: convert to markdown via pandoc
vim.api.nvim_create_autocmd("BufReadPre", {
  pattern = "*.docx",
  callback = function()
    local file = vim.fn.expand("<afile>")
    vim.bo.buftype = "nofile"
    vim.bo.readonly = true
    vim.cmd("silent! %d")
    vim.fn.jobstart({ "pandoc", "--to=markdown", file }, {
      stdout_buffered = true,
      on_stdout = function(_, data)
        if data then
          vim.api.nvim_buf_set_lines(0, 0, -1, false, data)
        end
      end,
    })
    vim.bo.filetype = "markdown"
  end,
})
