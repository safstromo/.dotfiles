return {
  "folke/todo-comments.nvim",
  lazy = false,
  opts = {
    highlight = {
      pattern = [[.*<(KEYWORDS)\s*]],
    },
    search = {
      pattern = [[\b(KEYWORDS)\b]],
    },
  },
  config = function()
    require("todo-comments").setup()
    vim.keymap.set(
      "n",
      "<leader>tn",
      "<cmd> lua require'todo-comments'.jump_next()<CR>",
      { desc = "Jump to next TODO" }
    )
    vim.keymap.set(
      "n",
      "<leader>tp",
      "<cmd> lua require'todo-comments'.jump_prev()<CR>",
      { desc = "Jump to prev TODO" }
    )
  end,
}
