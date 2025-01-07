return {
	-- {
	-- 	"github/copilot.vim",
	-- 	event = "InsertEnter",
	-- 	config = function()
	-- 		vim.g.copilot_no_tab_map = true
	-- 		vim.g.copilot_assume_mapped = true
	-- 		vim.g.copilot_tab_fallback = ""
	--
	-- 		vim.keymap.set("i", "<C-l>", function()
	-- 			vim.fn.feedkeys(vim.fn["copilot#Accept"](), "")
	-- 		end, {
	-- 			desc = "Copilot Accept",
	-- 			replace_keycodes = true,
	-- 			nowait = true,
	-- 			silent = true,
	-- 			expr = true,
	-- 			noremap = true,
	-- 		})
	-- 	end,
	-- },
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			vim.g.copilot_no_tab_map = true
			vim.g.copilot_assume_mapped = true
			vim.g.copilot_tab_fallback = ""

			require("copilot").setup({
				suggestion = { enabled = false },
				panel = { enabled = false },
			})
		end,
	},
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "zbirenbaum/copilot.lua" }, -- or zbirenbaum/copilot.lua
			{ "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
		},
		-- build = "make tiktoken", -- Only on MacOS or Linux
		opts = {
			-- See Configuration section for options
		},
		-- See Commands section for default commands if you want to lazy load on them
	},
	-- {
	-- 	"zbirenbaum/copilot-cmp",
	-- 	config = function()
	-- 		require("copilot_cmp").setup()
	-- 	end,
	-- },
}
