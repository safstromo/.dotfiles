return {
	{
		"simrat39/rust-tools.nvim",
		ft = "rust",
		dependencies = "neovim/nvim-lspconfig",
		config = function()
			require("rust-tools").setup({})
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
