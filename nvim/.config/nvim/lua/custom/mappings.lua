---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
    ["<C-h>"] = { "<cmd> TmuxNavigateLeft<CR>", "window left" },
    ["<C-l>"] = { "<cmd> TmuxNavigateRight<CR>", "window right" },
    ["<C-j>"] = { "<cmd> TmuxNavigateDown<CR>", "window down" },
    ["<C-k>"] = { "<cmd> TmuxNavigateUp<CR>", "window up" },
    ["<C-d>"] = { "<C-d>zz", },
    ["<C-u>"] = { "<C-u>zz", },
    -- ["<leader>p"] = { [[\"_dP]], "Paste void" },
    ["<leader>y"] = { [["+y]], "yank to system clipboard" },
    ["<leader>Y"] = { [["+Y]], "yank line to system clipboard" },
    ["<leader>ya"] = { [[:% y+<CR>]], "yank all to system clipboard" },
    ["<leader>re"] = { [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], "Rename" },
    -- ["<leader>d"] = { "<cmd> Lspsaga hover_doc<CR>", "Show quick docs" },
    -- ["ca"] = { "<cmd> Lspsaga code-action<CR>", "Code action" },
  },
  v = {
    ["<C-j>"] = { "<cmd> move '>+1<CR>gv=gv", "move line down" },
    ["<C-k>"] = { "<cmd> move '<-2<CR>gv=gv", "move line up" },
    ["<leader>y"] = { [["+y]], "Yank line to system clipboard" },
  },
}

-- more keybinds!
M.dap = {
  plugin = true,
  n = {
    ["<leader>db"] = { "<cmd> DapToggleBreakpoint <CR>", "Toggle breakpoint" },
    ["<leader>dus"] = {
      function()
        local widgets = require "dap.ui.widgets"
        local sidebar = widgets.sidebar(widgets.scopes)
        sidebar.open()
      end,
      "Open debugging sidebar",
    },
    ["<leader>dr"] = {
      "<cmd> DapContinue <CR>",
      "Run or continue the debugger",
    },
  },
}

M.crates = {
  plugin = true,
  n = {
    ["<leader>rcu"] = {
      function()
        require("crates").upgrade_all_crates()
      end,
      "update crates",
    },
  },
}

M.autosave = {
  n = {
    ["<leader>as"] = { "<cmd> ASToggle <CR>" },
  },
}

M.harpoon = {
  n = {
    ["<leader>a"] = {
      function()
        require("harpoon.mark").add_file()
      end,
      "󱡁 Harpoon Add file",
    },
    ["<leader>ta"] = { "<CMD>Telescope harpoon marks<CR>", "󱡀 Toggle quick menu" },
    ["<leader>aa"] = {
      function()
        require("harpoon.ui").toggle_quick_menu()
      end,
      "󱠿 Harpoon Menu",
    },
    ["<leader>h"] = {
      function()
        require("harpoon.ui").nav_file(1)
      end,
      "󱪼 Navigate to file 1",
    },
    ["<leader>l"] = {
      function()
        require("harpoon.ui").nav_file(2)
      end,
      "󱪽 Navigate to file 2",
    },
    ["<leader>3"] = {
      function()
        require("harpoon.ui").nav_file(3)
      end,
      "󱪾 Navigate to file 3",
    },
    ["<leader>4"] = {
      function()
        require("harpoon.ui").nav_file(4)
      end,
      "󱪿 Navigate to file 4",
    },
  },
}
return M
