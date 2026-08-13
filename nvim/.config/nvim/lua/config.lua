local opt = vim.opt
local keymap = vim.keymap
-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

opt.relativenumber = true
opt.number = true
opt.numberwidth = 2
opt.scrolloff = 8
opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.smartindent = true
opt.clipboard = "unnamedplus"
opt.ignorecase = true
opt.smartcase = true
opt.splitbelow = true
opt.splitright = true
opt.termguicolors = true

-- Visual Blockmode goes beyond the end of the line
opt.virtualedit = "block"

vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    vim.opt_local.softtabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
})

vim.filetype.add({
  extension = {
    wxs = "xml",
    env = "sh", -- foo.env
    gotmpl = "gotmpl", -- lets gopls attach to Go template files
    mdx = "markdown.mdx", -- lets marksman attach to MDX files
  },
  filename = {
    [".env"] = "sh",
    -- lets buf_ls attach to buf config files (in addition to .proto)
    ["buf.yaml"] = "buf-config",
    ["buf.gen.yaml"] = "buf-config",
    ["buf.lock"] = "buf-config",
  },
  pattern = {
    -- .env.local, .env.production, .env.development, ...
    ["%.env%.[%w_.-]+"] = "sh",
  },
})

-- disable nvim intro
opt.shortmess:append("sI")

--General keymaps
vim.g.mapleader = " "
keymap.set("n", ";", ":", {})
keymap.set("n", "<Esc>", ":noh <CR>")
keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { desc = "start tmux-sessionizer" })
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "<leader>y", ":+y", { desc = "Yank line to systemclipboard" })
keymap.set("n", "<leader>ya", ":% y+<CR>", { desc = "Yank all to system clipboard" })
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })
keymap.set("n", "<leader>re", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Rename in buffer" })

opt.conceallevel = 1

-- Navigate vim panes better
keymap.set("n", "<c-k>", "<C-w>k")
keymap.set("n", "<c-j>", "<C-w>j")
keymap.set("n", "<c-h>", "<C-w>h")
keymap.set("n", "<c-l>", "<C-w>l")

local symbols = { Error = "󰅙", Info = "󰋼", Hint = "󰌵", Warn = "" }

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = symbols.Error,
      [vim.diagnostic.severity.WARN]  = symbols.Warn,
      [vim.diagnostic.severity.HINT]  = symbols.Hint,
      [vim.diagnostic.severity.INFO]  = symbols.Info,
    },
  },
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("LaunchSnacksOnStartup", { clear = true }),
  callback = function()
    if vim.fn.argv(0) == "" then
      require("snacks.picker").files()
    end
  end,
})
