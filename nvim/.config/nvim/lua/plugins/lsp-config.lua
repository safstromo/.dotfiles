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
                "lemminx",
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            local jdtls_path = require("mason-registry").get_package("jdtls"):get_install_path()

            print("jdtls_path", jdtls_path)
            -- require("java").setup()
            local lspconfig = require("lspconfig")


            lspconfig.html.setup({
                capabilities = capabilities,
            })

            lspconfig.lua_ls.setup({
                capabilities = capabilities,
            })

            lspconfig.lemminx.setup({
                capabilities = capabilities,
            })

            lspconfig.jdtls.setup({
                settings = {
                    java = {
                        configuration = {
                            runtimes = {
                                {
                                    name = "JavaSE-17",
                                    path = "~/.sdkman/candidates/java/17.0.8-tem",
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
        end,
    },
}
