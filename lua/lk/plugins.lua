local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local uv = vim.uv or vim.loop

-- Auto-install lazy.nvim if not present
if not uv.fs_stat(lazypath) then
  print('Installing lazy.nvim....')
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git', '--branch=stable', -- latest stable release
    lazypath,
  })
  print('Done.')
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  "nvim-lua/popup.nvim",         -- An implementation of the Popup API from vim in Neovim
  "nvim-lua/plenary.nvim",       -- Useful lua functions used ny lots of plugins
  "windwp/nvim-autopairs",       -- Autopairs, integrates with both cmp and treesitter
  'nvim-tree/nvim-web-devicons', -- optional

  -- theme
  "Mofiqul/adwaita.nvim",
  "markvincze/panda-vim",
  "arzg/vim-colors-xcode",
  {
    "2nthony/vitesse.nvim",
    dependencies = {
      "tjdevries/colorbuddy.nvim"
    }
  },

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
  'nvimdev/lspsaga.nvim',

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
  -- {
  --   'stevearc/oil.nvim',
  --   opts = {},
  -- },
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      -- 👇 in this section, choose your own keymappings!
      {
        "-",
        "<cmd>Yazi<cr>",
        desc = "Open yazi at the current file",
      },
      {
        -- Open in the current working directory
        "<leader>cw",
        "<cmd>Yazi cwd<cr>",
        desc = "Open the file manager in nvim's working directory",
      },
      {
        -- NOTE: this requires a version of yazi that includes
        -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
        '<c-up>',
        "<cmd>Yazi toggle<cr>",
        desc = "Resume the last yazi session",
      },
    },
    ---@type YaziConfig
    opts = {
      -- if you want to open yazi instead of netrw, see below for more info
      open_for_directories = false,
      keymaps = {
        show_help = '<f1>',
      },
    },
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
})
