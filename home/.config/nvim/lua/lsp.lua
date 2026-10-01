return {
  bashls = {},
  -- library/types come from lazydev.nvim (plugins/code.lua)
  lua_ls = {},
  jsonls = {
    settings = {
      json = {
        schemas = require("schemastore").json.schemas(),
        validate = { enable = true },
      },
    },
  },
  html = {},
  cssls = {},
  cssmodules_ls = {
    init_options = {
      camelCase = "dashes",
    },
  },
  css_variables = {},
  emmet_ls = {
    filetypes = {
      "html",
      "typescriptreact",
      "javascriptreact",
      "css",
      --"less",
      --"sass",
      "scss",
    },
  },
  ts_ls = {
    settings = {
      javascript = { preferences = { quotePreference = "double" } },
      typescript = { preferences = { quotePreference = "double" } },
    },
  },
  -- nvim-lspconfig default already prefers <root>/node_modules/.bin/biome
  -- biome = { cmd = { vim.fn.getcwd() .. "/node_modules/.bin/biome", "lsp-proxy" }, },
  biome = {},
  graphql = {},
}
