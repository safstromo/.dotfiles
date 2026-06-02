return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    lazy = false,
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Initialize dap-ui with its default options
      dapui.setup()

      -- Automatically open and close the DAP UI when debugging starts/stops
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      -- Keymaps for nvim-dap
      vim.keymap.set("n", "<leader>db", function()
        require("dap").toggle_breakpoint()
      end, { desc = "Debug: Toggle Breakpoint" })

      vim.keymap.set("n", "<leader>dc", function()
        require("dap").continue()
      end, { desc = "Debug: Continue / Start" })

      vim.keymap.set("n", "<leader>do", function()
        require("dap").step_over()
      end, { desc = "Debug: Step Over" })

      vim.keymap.set("n", "<leader>di", function()
        require("dap").step_into()
      end, { desc = "Debug: Step Into" })

      vim.keymap.set("n", "<leader>dx", function()
        require("dap").step_out()
      end, { desc = "Debug: Step Out" })

      -- Keymaps for nvim-dap-ui
      vim.keymap.set("n", "<leader>du", function()
        require("dapui").toggle()
      end, { desc = "Debug: Toggle DAP UI" })

      vim.keymap.set({ "n", "v" }, "<leader>de", function()
        require("dapui").eval()
      end, { desc = "Debug: Evaluate under cursor" })
    end,
  },
}
