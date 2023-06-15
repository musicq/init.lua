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
  termguicolors = true,
  scrolloff = 8,
  signcolumn = "yes",
  updatetime = 50,
  colorcolumn = "80",
  cursorline = true,
}

vim.opt.isfname:append("@-@")

for k, v in pairs(options) do
  vim.opt[k] = v
end
