local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Autocommand that reloads neovim whenever save the plugins.lua file
vim.cmd([[
  augroup lazy_user_config
  autocmd!
  autocmd BufWritePost lazy_plugins.lua source <afile> | Lazy sync
  augroup end
  ]])

local plugins = {
  "nvim-lua/popup.nvim",  -- An implementation of the Popup API from vim in Neovim
  "nvim-lua/plenary.nvim", -- Useful lua functions used ny lots of plugins
  "windwp/nvim-autopairs", -- Autopairs, integrates with both cmp and treesitter
  "kyazdani42/nvim-web-devicons",
  "kyazdani42/nvim-tree.lua",

  -- theme
  "musicq/adwaita.nvim",

  -- wakatime
  "wakatime/vim-wakatime",

  -- LSP & completion
  "L3MON4D3/LuaSnip",     --snippet engine
  "neovim/nvim-lspconfig", -- enable LSP
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",           -- :MasonUpdate updates registry contents
  },
  "williamboman/mason-lspconfig.nvim", -- simple to use language server installer
  "jose-elias-alvarez/null-ls.nvim",  -- LSP diagnostics and code actions

  -- cmp plugins
  "hrsh7th/nvim-cmp",        -- The completion plugin
  "hrsh7th/cmp-buffer",      -- buffer completions
  "hrsh7th/cmp-path",        -- path completions
  "hrsh7th/cmp-cmdline",     -- cmdline completions
  "saadparwaiz1/cmp_luasnip", -- snippet completions
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-nvim-lua",

  -- DAP
  "mfussenegger/nvim-dap", -- Debug Adapter Protocol
  "rcarriga/nvim-dap-ui",
  "theHamsta/nvim-dap-virtual-text",
  "simrat39/rust-tools.nvim",
  "leoluz/nvim-dap-go",
  "mxsdev/nvim-dap-vscode-js",
  {
    -- Debug Adapter
    "microsoft/vscode-js-debug",
    lazy = true,
    build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
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

  -- Git
  { "lewis6991/gitsigns.nvim" },
  "tpope/vim-fugitive",

  -- Comment
  { "numToStr/Comment.nvim" }, -- Easily comment stuff
  { "JoosepAlviste/nvim-ts-context-commentstring", lazy = true },

  -- Terminal
  { "akinsho/toggleterm.nvim" },

  -- Status Bar
  "nvim-lualine/lualine.nvim",

  "RRethy/vim-illuminate",

  "easymotion/vim-easymotion",

  "ThePrimeagen/harpoon",

  "lukas-reineke/indent-blankline.nvim",
  "mbbill/undotree",
}

require("lazy").setup(plugins)
