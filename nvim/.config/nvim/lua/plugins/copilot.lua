return {
  "github/copilot.vim",
  event = "InsertEnter",
  config = function()
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_assume_mapped = true
    vim.g.copilot_tab_fallback = ""

    vim.keymap.set("i", "<C-l>",
      function()
        vim.fn.feedkeys(vim.fn["copilot#Accept"](), "")
      end,
      {
        desc = "Copilot Accept",
        replace_keycodes = true,
        nowait = true,
        silent = true,
        expr = true,
        noremap = true
      }
    )
  end
}

