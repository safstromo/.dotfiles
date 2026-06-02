return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>fm",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Format Code",
    },
  },
  -- Everything in opts will be passed to setup()
  opts = {
    lsp_fallback = true,
    -- Define your formatters
    formatters_by_ft = {
      lua = { "stylua" },
      javascript = { "biome" },
      javascriptreact = { "biome" },
      typescript = { "biome" },
      typescriptreact = { "biome" },
      json = { "biome" },
      html = { "biome" },
      css = { "biome" },
      scss = { "biome" },
      markdown = { "prettierd", "prettier", stop_after_first = true },
      yaml = { "prettierd", "prettier", stop_after_first = true },
      sh = { "shfmt" },
      go = { "gofmt", "gofumpt" },
      templ = { "templ" },
      rust = { "leptosfmt", "rustfmt" },
      kotlin = { "ktfmt" },
      xml = { "lemminx" },
      nix = { "nixfmt" },
      java = { "google-java-format" },
      gdscript = { "gdscript-formatter" },
    },
    -- Set up format-on-save
    format_on_save = { timeout_ms = 2000, lsp_format = "fallback" },
    -- Customize formatters
    formatters = {
      shfmt = {
        prepend_args = { "-i", "2" },
      },
    },
  },
  init = function()
    -- If you want the formatexpr, here is the place to set it
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
