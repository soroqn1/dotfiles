local map = vim.keymap.set

-- ─── Buffers (tab bar at the top) ──────────────────────────────────────────
-- Tab / Shift+Tab to cycle like browser tabs
map("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })

-- <leader>x to close current buffer (keeps window open)
map("n", "<leader>x", "<cmd>bp|bd #<cr>", { desc = "Close buffer" })

-- ─── Windows / Splits ──────────────────────────────────────────────────────
-- Ctrl+h/j/k/l is already set by LazyVim
-- Resize with arrows
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- ─── Diagnostics ───────────────────────────────────────────────────────────
-- Jump to errors only (skip hints/warnings noise)
map("n", "[e", function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Prev error" })
map("n", "]e", function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Next error" })

-- Jump to any diagnostic (existing LazyVim [d/]d, adding <leader>D as float)
map("n", "<leader>D", vim.diagnostic.open_float, { desc = "Show diagnostic float" })

-- ─── Movements ─────────────────────────────────────────────────────────────
-- Keep cursor centered when scrolling / searching
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up centered" })
map("n", "n", "nzzzv", { desc = "Next match centered" })
map("n", "N", "Nzzzv", { desc = "Prev match centered" })

-- Move selected lines up/down in visual mode
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Don't lose clipboard when pasting over selection
map("v", "p", '"_dP', { desc = "Paste without losing clipboard" })

-- Warn on Ctrl+C in normal mode (doesn't quit vim, but confuses muscle memory)
map("n", "<C-c>", function()
  vim.notify("Use :q to quit, :w to save", vim.log.levels.WARN, { title = "vim" })
end, { desc = "Ctrl+C warning" })
