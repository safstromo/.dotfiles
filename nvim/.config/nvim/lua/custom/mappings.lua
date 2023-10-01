---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
    ["<C-h>"] = { "<cmd> TmuxNavigateLeft<CR>", "window left" },
    ["<C-l>"] = { "<cmd> TmuxNavigateRight<CR>", "window right" },
    ["<C-j>"] = { "<cmd> TmuxNavigateDown<CR>", "window down" },
    ["<C-k>"] = { "<cmd> TmuxNavigateUp<CR>", "window up" },
    ["<C-f>"] = { "[[:silent !tmux neww tmux-sessionizer<CR>]]", "start tmux-sessionizer" },
    ["<C-d>"] = { "<C-d>zz" },
    ["<C-u>"] = { "<C-u>zz" },
    ["<leader>y"] = { [["+y]], "yank to systemclipboard" },
    ["<leader>Y"] = { [["+Y]], "yank line to system clipboard" },
    ["<leader>ya"] = { [[:% y+<CR>]], "yank all to system clipboard" },
    ["<leader>re"] = { [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], "Rename" },
    ["<leader>st"] = { "<cmd> Telescope diagnostics<CR>", "Show Diagnostics" },
    ["<leader>sl"] = { "<cmd> Telescope notify<CR>", "Show Notify log" },
  },
  v = {
    ["<C-j>"] = { "<cmd> move '>+1<CR>gv=gv", "move line down" },
    ["<C-k>"] = { "<cmd> move '<-2<CR>gv=gv", "move line up" },
  },
}

M.dap = {
  plugin = true,
  n = {
    ["<leader>db"] = { "<cmd> DapToggleBreakpoint <CR>", "Toggle breakpoint" },
    ["<leader>dcb"] = {
      "<cmd> lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
      "Set conditional breakpoint",
    },
    ["<leader>dus"] = {
      function()
        local widgets = require("dap.ui.widgets")
        local sidebar = widgets.sidebar(widgets.scopes)
        sidebar.open()
      end,

      "Open debugging sidebar",
    },
    ["<leader>dr"] = {
      "<cmd> dapcontinue <cr>",
      "Run or continue the debugger",
    },
    ["<F1>"] = { "<CMD>DapContinue <CR>", " Continue" },
    ["<F2>"] = { "<CMD>DapStepOver <CR>", " Step over" },
    ["<F3>"] = { "<CMD>DapStepInto <CR>", " Step into" },
    ["<F4>"] = { "<CMD>DapStepOut <CR>", " Step out" },
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

-- M.autosave = {
--   n = {
--     ["<leader>as"] = { "<cmd> ASToggle <CR>" },
--   },
-- }

M.todo = {
  n = {

    ["<leader>tn"] = { "<cmd> lua require'todo-comments'.jump_next()<CR>", "Jump to next TODO" },
    ["<leader>tp"] = { "<cmd> lua require'todo-comments'.jump_prev()<CR>", "Jump to prev TODO" },
    ["<leader>ts"] = { "<cmd> TodoTelescope<CR>", "Show todo list" },
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

M.copilot = {
  i = {
    ["<C-l>"] = {
      function()
        vim.fn.feedkeys(vim.fn["copilot#Accept"](), "")
      end,
      "Copilot Accept",
      { replace_keycodes = true, nowait = true, silent = true, expr = true, noremap = true },
    },
  },
}

M.lsp = {

  n = {
    ["<leader>gr"] = { "<cmd>Telescope lsp_references<CR>", "Show LSP references" },
    ["<leader>rn"] = { vim.lsp.buf.rename, "󱕾 LSP Rename" },
    ["<leader>gi"] = { "<cmd>Telescope lsp_implementations<CR>", "󱕾 LSP Implementations" },
    ["<leader>gT"] = { "<cmd>Telescope lsp_type_definitions<CR>", "󱕾 LSP Type Definitions" },
    ["<leader>D"] = { "<cmd>Telescope diagnostics bufnr=0<CR>", "󱕾 LSP Type Definitions" },
    ["<leader>sh"] = { vim.lsp.buf.signature_help,"󱕾 LSP Show signature help"},
    ["<leader>sd"] = { vim.lsp.buf.hover,"󱕾 LSP Show quickdocs"},
    ["<leader>d"] = { vim.diagnostic.open_float, "󱕾 LSP Show line diagnostics" },
    ["<leader>rs"] = {"<cmd>LspRestart<CR>", "Restart LSP"},
  },
}

return M
