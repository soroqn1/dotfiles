return {
  "nvim-neo-tree/neo-tree.nvim",
  keys = {
    { "<leader>e", "<cmd>Neotree toggle left<cr>", desc = "Toggle File Explorer (Side)" },
    { "<leader>E", "<cmd>Neotree toggle float<cr>", desc = "Toggle File Explorer (Full/Float)" },
  },
  opts = {
    filesystem = {
      filtered_items = {
        visible = true, -- show hidden files by default
        hide_dotfiles = false,
        hide_gitignored = false,
        never_show = {
          ".DS_Store",
          "thumbs.db",
        },
      },
    },
    window = {
      position = "left",
      width = 32,
      mappings = {
        ["q"] = "close_window",
        ["<esc>"] = "close_window",
        ["h"] = "close_node",
        ["l"] = "open",
        ["<cr>"] = "open",
        ["n"] = "add",
        ["Y"] = function(state)
          local node = state.tree:get_node()
          local filepath = node:get_id()
          local filename = node.name
          local modify = vim.fn.fnamemodify

          local results = {
            filepath,
            modify(filepath, ":."),
            filename,
          }

          vim.ui.select({
            "Absolute path: " .. results[1],
            "Relative path: " .. results[2],
            "Filename: " .. results[3],
          }, {
            prompt = "Copy to clipboard:",
          }, function(choice)
            if choice then
              local i = 1
              if choice:match("^Relative") then
                i = 2
              elseif choice:match("^Filename") then
                i = 3
              end
              local val = results[i]
              vim.fn.setreg("+", val)
              vim.fn.setreg('"', val)
              vim.notify("Copied: " .. val)
            end
          end)
        end,
      },
    },
  },
}
