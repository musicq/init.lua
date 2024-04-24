require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {
    "clangd",
    -- "cspell",
    "cssls",
    -- "css-variables-language-server",
    "cssmodules_ls",
    -- "eslint_d",
    "eslint",
    "gopls",
    -- "jq",
    "lua_ls",
    -- "prettier",
    -- "prettierd",
    "rust_analyzer",
    "tailwindcss",
    "tsserver",
    "yamlls",
    "taplo"
  },

  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,
  },
})
