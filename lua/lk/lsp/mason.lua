local get_servers = require("mason-lspconfig").get_installed_servers

local ensured_languages = {
  "prismals",
  "jsonls",
  "gopls",
  "tsserver",
  "lua_ls",
  "eslint",
}

local settings = {
  ui = {
    border = "none",
  },
  log_level = vim.log.levels.INFO,
  max_concurrent_installers = 4,
}

require("mason").setup(settings)
require("mason-lspconfig").setup({
  ensure_installed = ensured_languages,
  automatic_installation = true,
})

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
  return
end

local opts = {}

for _, server in pairs(get_servers()) do
  opts = {
    on_attach = require("lk.lsp.handlers").on_attach,
    capabilities = require("lk.lsp.handlers").capabilities,
  }

  server = vim.split(server, "@")[1]

  local require_ok, conf_opts = pcall(require, "lk.lsp.settings." .. server)
  if require_ok then
    opts = vim.tbl_deep_extend("force", conf_opts, opts)
  end

  lspconfig[server].setup(opts)
end
