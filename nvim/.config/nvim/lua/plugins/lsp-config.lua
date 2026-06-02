return {
  -- {
  --   "williamboman/mason.nvim",
  --   lazy = false,
  --   config = function()
  --     require("mason").setup()
  --   end,
  -- },
  -- Cant use on nixos
  -- {
  -- 	"williamboman/mason-lspconfig.nvim",
  -- 	lazy = false,
  -- 	opts = {
  -- 		auto_install = true,
  -- 		ensure_installed = {
  -- 			"lua_ls",
  -- 			"cssls",
  -- 			"tailwindcss",
  -- 			"rust_analyzer",
  -- 			"html",
  -- 			"jdtls",
  -- 			-- "gopls",
  -- 			"lemminx",
  -- 			"kotlin_language_server",
  -- 			"buf_ls",
  -- 		},
  -- 	},
  -- },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local handlers = {
        ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
        ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
      }
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Cant use on nvim
      -- local jdtls_path = require("mason-registry").get_package("jdtls"):get_install_path()

      -- print("jdtls_path", jdtls_path)

      vim.lsp.config("html", {
        capabilities = capabilities,
        handlers = handlers,
      })

      vim.lsp.config("biome", {
        capabilities = capabilities,
        handlers = handlers,
      })

      vim.lsp.config("nixd", {
        capabilities = capabilities,
        handlers = handlers,
      })

      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        handlers = handlers,
      })

      vim.lsp.config("lemminx", {
        capabilities = capabilities,
        handlers = handlers,
      })

      vim.lsp.config("buf_ls", {
        capabilities = capabilities,
        handlers = handlers,
      })

      vim.lsp.config("svelte", {
        capabilities = capabilities,
        handlers = handlers,
      })

      vim.lsp.config("marksman", {
        capabilities = capabilities,
        handlers = handlers,
      })


      -- Using nvim-jdtls instead
      -- lspconfig.jdtls.setup({
      --   handlers = handlers,
      --   capabilities = capabilities,
      --   settings = {
      --     java = {
      --       maven = {
      --         downloadSources = true,
      --       },
      --       implementationsCodeLens = {
      --         enabled = true,
      --       },
      --       referencesCodeLens = {
      --         enabled = true,
      --       },
      --     }
      --   }
      -- })

      -- configure tailwindcss server
      vim.lsp.config("tailwindcss", {
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
      vim.lsp.config("cssls", {
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

      -- lspconfig["kotlin_language_server"].setup({
      --   capabilities = capabilities,
      --   handlers = handlers,
      -- })
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
      --
      --
      vim.lsp.config("gopls", {
        capabilities = capabilities,
        handlers = handlers,
        cmd = { "gopls" },
        filetypes = { "go", "gomod", "gowork", "gotmpl", "templ" },
        settings = {
          gopls = {
            completeUnimported = true,
            usePlaceholders = false,
            analyses = {
              unusedparams = true,
            },
          },
        },
      })
      vim.lsp.config("templ", {
        capabilities = capabilities,
        handlers = handlers,
      })

      -- Keymaps
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "󱕾 Show quickdocs" })
      vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { desc = "󱕾 Go to Definition" })
      vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help, { desc = "󱕾 Show signature help" })
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "󱕾 Code Actions" })
      vim.keymap.set("n", "<leader>ra", vim.lsp.buf.rename, { desc = "󱕾 LSP Rename" })
      vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "󱕾 Show line diagnostics" })
      vim.keymap.set("n", "<leader>rs", function()
        if vim.bo.filetype == "java" then
          vim.notify("Use <leader>rs from jdtls buffer", vim.log.levels.WARN)
          return
        end
        vim.cmd("LspRestart")
      end, { desc = "Restart LSP" })
      --
      --Set border for floating windows
      vim.cmd([[autocmd! ColorScheme * highlight NormalFloat guibg=#1f2335]])
      vim.cmd([[autocmd! ColorScheme * highlight FloatBorder guifg=white guibg=#1f2335]])

      vim.diagnostic.config({
        float = { border = "rounded" },
      })

      vim.lsp.enable({ "html", "biome", "nixd", "lua_ls", "lemminx", "buf_ls", "tailwindcss", "cssls", "gopls", "templ",
        "svelte", "marksman" })
    end,
  },
}
