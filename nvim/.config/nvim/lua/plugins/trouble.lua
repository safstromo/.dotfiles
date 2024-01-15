return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
	},
	config = function()
		vim.keymap.set("n", "<leader>sw", function()
			require("trouble").toggle("workspace_diagnostics")
		end, { desc = "Show Workspace diagnostics" })
		vim.keymap.set("n", "<leader>sd", function()
			require("trouble").toggle("document_diagnostics")
		end, { desc = "Show Document diagnostics" })
vim.keymap.set("n", "<leader>gf", function()
require("trouble").next({skip_groups = true, jump = true})
		end, { desc = "Go to next Trouble" })

	end,
}
