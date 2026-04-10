return {
  "mfussenegger/nvim-jdtls",
  ft = { "java" },
  config = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      callback = function()
        local jdtls = require("jdtls")

        -- Basic project setup
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
        local workspace_dir = vim.fn.expand("~/.cache/jdtls/workspace/") .. project_name
        local root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" })

        local config = {
          -- We are back on an LTS release, so a clean command works perfectly
          cmd = { "jdtls", "-data", workspace_dir },
          root_dir = root_dir,
          capabilities = require("cmp_nvim_lsp").default_capabilities(),

          settings = {
            java = {
              maven = { downloadSources = true },
              eclipse = { downloadSources = true },
              references = { includeDecompiledSources = true },
              contentProvider = { preferred = "fernflower" },
              configuration = {
                updateBuildConfiguration = "automatic",
                -- Tell JDTLS exactly where to find your JDKs
                --echo "$(nix eval --raw nixpkgs#jdk25)/lib/openjdk"
                runtimes = {
                  {
                    name = "JavaSE-25",
                    path = "/nix/store/4w4a1pfk094g6jz3baxr8cqflyshiml1-openjdk-25.0.2+10/lib/openjdk", -- e.g., /nix/store/xxxx-openjdk-25.0.2/lib/openjdk
                    default = true,
                  },
                  {
                    name = "JavaSE-21",
                    path = "/nix/store/x2glvhmg5af3cd5vcmvn6p4l3mqq4b3k-openjdk-21.0.10+7/lib/openjdk",
                  },
                  {
                    name = "JavaSE-17",
                    path = "/nix/store/8r5yr9kkhnrx2mdhykcfwj7yzv9x1825-openjdk-17.0.18+8/lib/openjdk",
                  },
                }
              },
              inlayHints = { parameterNames = { enabled = "all" } },
            }
          },

          init_options = {
            extendedClientCapabilities = jdtls.extendedClientCapabilities,
          },

          on_attach = function(client, bufnr)
            require("jdtls.setup").add_commands()

            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })

            vim.keymap.set("n", "<leader>rs", function()
              vim.cmd("JdtRestart")
            end, { buffer = bufnr, desc = "Restart jdtls" })

            vim.keymap.set("n", "<leader>ti", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end, { buffer = bufnr, desc = "Toggle LSP Inlay Hints" })
          end,
        }

        jdtls.start_or_attach(config)
      end,
    })
  end,
}
