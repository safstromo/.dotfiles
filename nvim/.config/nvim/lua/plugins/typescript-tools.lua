return {
	"pmizio/typescript-tools.nvim",
	ft = {
		"javascript",
		"typescript",
		"javascriptreact",
		"typescriptreact",
	},
	dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
	opts = {},
	config = function()
		require("typescript-tools").setup({})
	end,
}
