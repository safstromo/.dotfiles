local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- temp fix https://github.com/neovim/neovim/issues/39032
local orig_get_node_text = vim.treesitter.get_node_text
vim.treesitter.get_node_text = function(node, source, opts)
  local ok, result = pcall(orig_get_node_text, node, source, opts)
  if ok then
    return result
  end
  return ""
end

require("config")
require("lazy").setup("plugins")

vim.keymap.set('n', '<leader>cc', ':CodeCompanionChat<CR>', { desc = 'CodeCompanion Chat' })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "xml",
  callback = function()
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.expandtab = true
  end,
})
