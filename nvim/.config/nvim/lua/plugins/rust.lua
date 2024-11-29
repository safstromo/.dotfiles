return {

	-- Archived
	-- {
	--   "simrat39/rust-tools.nvim",
	--   ft = "rust",
	--   dependencies = "neovim/nvim-lspconfig",
	--   config = function()
	--     local opts = {
	--       tools = {
	--         hover_actions = {
	--           border = {
	--             { "╭", "FloatBorder" },
	--             { "─", "FloatBorder" },
	--             { "╮", "FloatBorder" },
	--             { "│", "FloatBorder" },
	--             { "╯", "FloatBorder" },
	--             { "─", "FloatBorder" },
	--             { "╰", "FloatBorder" },
	--             { "│", "FloatBorder" },
	--           },
	--         },
	--       },
	--     }
	--     require("rust-tools").setup(opts)
	--   end,
	-- },

	{
		"mrcjkb/rustaceanvim",
		version = "^5", -- Recommended
		lazy = false, -- This plugin is already lazy
		dependencies = {
			"nvim-lua/plenary.nvim",
			"mfussenegger/nvim-dap",
			{
				"lvimuser/lsp-inlayhints.nvim",
				opts = {},
			},
		},
		ft = { "rust" },
		config = function()
			vim.g.rustaceanvim = {
				tools = {
					hover_actions = {
						border = {
							{ "╭", "FloatBorder" },
							{ "─", "FloatBorder" },
							{ "╮", "FloatBorder" },
							{ "│", "FloatBorder" },
							{ "╯", "FloatBorder" },
							{ "─", "FloatBorder" },
							{ "╰", "FloatBorder" },
							{ "│", "FloatBorder" },
						},
					},
				},
				server = {
					on_attach = function()
						vim.lsp.inlay_hint.enable(true)
					end,
				},
			}
		end,
	},
	{
		"saecki/crates.nvim",
		ft = { "toml" },
		event = { "BufRead Cargo.toml" },
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local crates = require("crates")
			crates.setup({})
			require("cmp").setup.buffer({
				sources = { { name = "crates" } },
			})
			crates.show()
		end,
	},
	{
		"rust-lang/rust.vim",
		ft = "rust",
		init = function()
			vim.g.rustfmt_autosave = 1
		end,
	},
}
