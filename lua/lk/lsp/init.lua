local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end

require "lk.lsp.mason"
require("lk.lsp.handlers").setup()
require "lk.lsp.null-ls"

