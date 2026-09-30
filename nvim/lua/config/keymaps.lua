local map = vim.keymap.set

-- ─── Buffers (tab bar at the top) ──────────────────────────────────────────
-- Tab / Shift+Tab to cycle like browser tabs
map("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })

map("n", "<leader>w", "<cmd>bd<cr>", { desc = "Close current tab" })

map("n", "<leader>x", "<cmd>bp|bd #<cr>", { desc = "Close buffer (keep layout)" })

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

-- ─── Docker ────────────────────────────────────────────────────────────────
map("n", "<leader>dl", function()
  Snacks.terminal({ "lazydocker" }, {
    esc_esc = false,
    ctrl_hjkl = false,
    win = {
      position = "float",
      border = "rounded",
      height = 0.9,
      width = 0.9,
    },
  })
end, { desc = "Lazydocker" })

-- ─── Window Controls (close & manage without mouse) ───────────────────────
map("n", "<leader>wc", "<cmd>close<cr>", { desc = "Close current split window" })
map("n", "<leader>wo", "<cmd>only<cr>", { desc = "Close all other windows" })

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

-- ─── Search (<leader>f and Ctrl shortcuts) ─────────────────────────────────
-- Unmap extra clutter from <leader>f
local unmap = vim.keymap.del
for _, k in ipairs({
  "<leader>fF",
  "<leader>fb",
  "<leader>fn",
  "<leader>fr",
  "<leader>fR",
  "<leader>ft",
  "<leader>fT",
  "<leader>fp",
  "<leader>fe",
  "<leader>fE",
}) do
  pcall(unmap, "n", k)
end

-- Only the 3 search actions in <leader>f:
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Search files by name (<C-p>)" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Search text in project (<C-g>)" })
map("n", "<leader>fc", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Search text in current file (<C-f>)" })

-- Ctrl shortcuts (same 3 searches)
map("n", "<C-p>", "<cmd>Telescope find_files<cr>", { desc = "Search files by name" })
map("n", "<C-g>", "<cmd>Telescope live_grep<cr>", { desc = "Search text in project" })
map("n", "<C-f>", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Search text in current file" })

map("n", "<C-a>", "ggVG", { desc = "Select all text" })
map("n", "<Esc>", "<cmd>noh<cr><esc>", { desc = "Clear search highlight" })

