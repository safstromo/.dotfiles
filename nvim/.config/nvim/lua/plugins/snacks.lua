return
{
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    picker = {
      -- your picker configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  },
  keys = {
    { "<leader>ff", function() Snacks.picker.files() end,                desc = "Find Files" },
    { "<leader>fw", function() Snacks.picker.grep() end,                 desc = "Grep" },
    { "<leader>fb", function() Snacks.picker.buffers() end,              desc = "Buffers" },
    { "<leader>fa", function() Snacks.picker.smart() end,                desc = "Smart Find Files" },
    { "<leader>sd", function() Snacks.picker.diagnostics() end,          desc = "Diagnostics" },
    { "<leader>st", function() Snacks.picker.todo_comments() end,        desc = "Todo" },
    { "<leader>gr", function() Snacks.picker.lsp_references() end,       nowait = true,                desc = "References" },
    { "<leader>gi", function() Snacks.picker.lsp_implementations() end,  desc = "Goto Implementation" },
    { "<leader>gt", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto Type Definition" },
  },
  event = "VimEnter",
  config = function()
    if vim.fn.argv(0) == "" then
      require("snacks.picker").files()
    end
  end,
}
