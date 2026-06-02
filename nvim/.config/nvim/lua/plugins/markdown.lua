-- Markdown checkbox toggle (independent of any plugin)
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function()
    vim.keymap.set('n', '<leader>x', function()
      local line = vim.api.nvim_get_current_line()
      local new_line
      if line:match("^%s*[%-%*]%s%[ %]") then
        new_line = line:gsub("%[ %]", "[x]", 1)
      elseif line:match("^%s*[%-%*]%s%[x%]") then
        new_line = line:gsub("%[x%]", "[ ]", 1)
      else
        new_line = line:gsub("^(%s*)", "%1- [ ] ")
      end
      vim.api.nvim_set_current_line(new_line)
    end, { buffer = true, desc = "Toggle Markdown Checkbox" })
  end,
})

return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = 'markdown',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    opts = {},
  }
}
