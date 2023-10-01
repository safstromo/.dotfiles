local M = {}

M.treesitter = {
	ensure_installed = {
		"vim",
		"lua",
		"regex",
		"bash",
		"html",
		"css",
		"javascript",
		"typescript",
		"tsx",
		"c",
		"markdown",
		"markdown_inline",
		"java",
		"rust",
		"vue",
		"go",
	},
	indent = {
		enable = true,
		-- disable = {
		--   "python"
		-- },
	},
}

M.mason = {
	ensure_installed = {
		-- lua stuff
		"lua-language-server",
		"stylua",

		-- web dev stuff
		"css-lsp",
		"html-lsp",
		"typescript-language-server",
		"prettier",
		"tailwindcss-language-server",
		"eslint-lsp",

		-- c/cpp stuff
		"clangd",
		"clang-format",

		--java
		"jdtls",
		"java-test",
		"java-debug-adapter",
		"vscode-java-decompiler",
		"google-java-format",

		--rust
		"rust-analyzer",

		-- go
		"gopls",
    "gofumpt",
    "goimports-reviser",
    "golines",
	},
}

-- git support in nvimtree
M.nvimtree = {
	git = {
		enable = true,
	},

	renderer = {
		highlight_git = true,
		icons = {
			show = {
				git = true,
			},
		},
	},
}

M.telescope = {
	extensions_list = {
		"ui-select",
	},
}
return M
