return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		opts = {
			auto_install = true,
			ensure_installed = {
				"lua_ls",
				"cssls",
				"tailwindcss",
				"rust_analyzer",
				"html",
				"jdtls",
				-- "gopls",
				"lemminx",
				"kotlin_language_server",
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			local handlers = {
				["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
				["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
			}
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local jdtls_path = require("mason-registry").get_package("jdtls"):get_install_path()

			-- print("jdtls_path", jdtls_path)

			local lspconfig = require("lspconfig")

			lspconfig.html.setup({
				capabilities = capabilities,
				handlers = handlers,
			})

			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				handlers = handlers,
			})

			lspconfig.lemminx.setup({
				capabilities = capabilities,
				handlers = handlers,
			})

			lspconfig.jdtls.setup({
				handlers = handlers,
				capabilities = capabilities,
				settings = {
					java = {
						configuration = {
							runtimes = {
								{
									name = "JavaSE-17",
									path = "~/.sdkman/candidates/java/17.0.8-tem",
									default = false,
								},
								{
									name = "JavaSE-21",
									path = "~/.sdkman/candidates/java/21.0.5-tem",
									default = true,
								},
							},
						},
						format = {
							enabled = true,
							settings = {
								url = jdtls_path .. "/intellij-java-google-style.xml",
								profile = "GoogleStyle",
								indent_size = 4,
								tab_size = 4,
							},
						},
					},
				},
			})

			-- configure tailwindcss server
			lspconfig["tailwindcss"].setup({
				capabilities = capabilities,
				handlers = handlers,
				filetypes = {
					"css",
					"scss",
					"sass",
					"postcss",
					"html",
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
					"svelte",
					"vue",
					"rust",
				},
				init_options = {
					userLanguages = {
						rust = "html",
					},
				},
				root_dir = require("lspconfig").util.root_pattern(
					"tailwind.config.js",
					"tailwind.config.ts",
					"postcss.config.js",
					"postcss.config.ts",
					"windi.config.ts"
				),
				settings = {
					css = {
						validate = true,
						lint = {
							unknownAtRules = "ignore",
						},
					},
					scss = {
						validate = true,
						lint = {
							unknownAtRules = "ignore",
						},
					},
					less = {
						validate = true,
						lint = {
							unknownAtRules = "ignore",
						},
					},
				},
			})

			-- configure css server
			lspconfig["cssls"].setup({
				capabilities = capabilities,
				handlers = handlers,
				settings = {
					css = {
						validate = true,
						lint = {
							unknownAtRules = "ignore",
						},
					},
					scss = {
						validate = true,
						lint = {
							unknownAtRules = "ignore",
						},
					},
					less = {
						validate = true,
						lint = {
							unknownAtRules = "ignore",
						},
					},
				},
			})

			lspconfig["kotlin_language_server"].setup({
				capabilities = capabilities,
				handlers = handlers,
			})
			--
			-- lspconfig["rust_analyzer"].setup({
			--   capabilities = capabilities,
			--   handlers = handlers,
			--   settings = {
			--     ['rust-analyzer'] = {
			--       diagnostics = {
			--         enable = false,
			--       }
			--     }
			--   }
			--
			-- })
			-- lspconfig.gopls.setup({
			-- 	capabilities = capabilities,
			-- 	handlers = handlers,
			-- 	cmd = { "gopls" },
			-- 	filetypes = { "go", "gomod", "gowork", "gotmpl" },
			-- 	settings = {
			-- 		gopls = {
			-- 			completeUnimported = true,
			-- 			usePlaceholders = true,
			-- 			analyses = {
			-- 				unusedparams = true,
			-- 			},
			-- 		},
			-- 	},
			-- })

			-- Keymaps
			vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "󱕾 Show quickdocs" })
			vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { desc = "󱕾 Go to Definition" })
			vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help, { desc = "󱕾 Show signature help" })
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "󱕾 Code Actions" })
			vim.keymap.set("n", "<leader>ra", vim.lsp.buf.rename, { desc = "󱕾 LSP Rename" })
			vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "󱕾 Show line diagnostics" })
			vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", { desc = "Restart LSP" })
			vim.keymap.set("n", "<leader>gr", ":Telescope lsp_references<CR>", { desc = "󱕾 Show references" })
			vim.keymap.set(
				"n",
				"<leader>gi",
				":Telescope lsp_implementations<CR>",
				{ desc = "󱕾 Show Implementations" }
			)
			vim.keymap.set(
				"n",
				"<leader>gT",
				":Telescope lsp_type_definitions<CR>",
				{ desc = "󱕾 Show Type Definitions" }
			)
			-- ["<leader>D"] = { "<cmd>Telescope diagnostics bufnr=0<CR>", "󱕾 LSP Type Definitions" },
			--
			--Set border for floating windows
			vim.cmd([[autocmd! ColorScheme * highlight NormalFloat guibg=#1f2335]])
			vim.cmd([[autocmd! ColorScheme * highlight FloatBorder guifg=white guibg=#1f2335]])

			vim.diagnostic.config({
				float = { border = "rounded" },
			})
		end,
	},
}
