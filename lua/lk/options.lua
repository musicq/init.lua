local options = {
  guicursor = "",
  number = true,
  relativenumber = true,

  tabstop = 2,
  softtabstop = 2,
  shiftwidth = 2,
  expandtab = true,

  smartindent = true,

  wrap = false,
  swapfile = false,
  backup = false,
  undodir = os.getenv("HOME") .. "/.vim/undodir",
  undofile = true,
  hlsearch = true,
  incsearch = true,
  completeopt = "menu,menuone,noselect,popup",
  termguicolors = true,
  scrolloff = 8,
  signcolumn = "yes",
  updatetime = 200,
  colorcolumn = "0",
  cursorline = true,
  foldmethod = "indent",
  foldenable = false
}

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

vim.opt.isfname:append("@-@")

for k, v in pairs(options) do
  vim.opt[k] = v
end
