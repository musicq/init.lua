local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local uv = vim.uv or vim.loop

-- Auto-install lazy.nvim if not present
if not uv.fs_stat(lazypath) then
  print('Installing lazy.nvim....')
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
  print('Done.')
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  "nvim-lua/popup.nvim",   -- An implementation of the Popup API from vim in Neovim
  "nvim-lua/plenary.nvim", -- Useful lua functions used ny lots of plugins
  "windwp/nvim-autopairs", -- Autopairs, integrates with both cmp and treesitter

  -- theme
  "Mofiqul/adwaita.nvim",

  -- lsp
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x'
  },
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim' },
  { 'neovim/nvim-lspconfig' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/nvim-cmp' },
  { 'L3MON4D3/LuaSnip' },
  "jose-elias-alvarez/null-ls.nvim", -- LSP diagnostics and code actions
  {
    'mrcjkb/rustaceanvim',
    version = '^4', -- Recommended
    ft = { 'rust' },
  },

  -- formatter
  {
    'stevearc/conform.nvim',
    event = { "BufReadPre", "BufNewFile" },
  },

  -- linter
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
  },

  -- file tree
  {
    'stevearc/oil.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- Telescope
  "nvim-telescope/telescope.nvim",
  "nvim-telescope/telescope-media-files.nvim",

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },
  "p00f/nvim-ts-rainbow",
  "nvim-treesitter/playground",
  "nvim-treesitter/nvim-treesitter-context",

  -- Comment
  { "numToStr/Comment.nvim" }, -- Easily comment stuff
  { "JoosepAlviste/nvim-ts-context-commentstring", lazy = true },

  -- Status Bar
  "nvim-lualine/lualine.nvim",

  -- Git
  { "lewis6991/gitsigns.nvim" },
  "tpope/vim-fugitive",

  -- Terminal
  { "akinsho/toggleterm.nvim" },

  "RRethy/vim-illuminate",

  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

  "mbbill/undotree",

  {
    'smoka7/hop.nvim',
    version = "*",
    opts = {},
  },

  "ThePrimeagen/harpoon",

  "easymotion/vim-easymotion"
})
