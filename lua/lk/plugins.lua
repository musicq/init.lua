local fn = vim.fn

local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
  print("Packer installed, close and reopen Neovim...")
  vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
  autocmd!
  autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
  ]])

local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

packer.init({
  display = {
    open_fn = function()
      return require("packer.util").float({ border = "rounded" })
    end,
  },
})

return packer.startup(function(use)
  use("wbthomason/packer.nvim") -- Have packer manage itself
  use("nvim-lua/popup.nvim")   -- An implementation of the Popup API from vim in Neovim
  use("nvim-lua/plenary.nvim") -- Useful lua functions used ny lots of plugins
  use("windwp/nvim-autopairs") -- Autopairs, integrates with both cmp and treesitter
  use("kyazdani42/nvim-web-devicons")
  use("kyazdani42/nvim-tree.lua")

  -- theme
  use("musicq/adwaita.nvim")

  -- wakatime
  use("wakatime/vim-wakatime")

  -- cmp plugins
  use("hrsh7th/nvim-cmp")        -- The completion plugin
  use("hrsh7th/cmp-buffer")      -- buffer completions
  use("hrsh7th/cmp-path")        -- path completions
  use("hrsh7th/cmp-cmdline")     -- cmdline completions
  use("saadparwaiz1/cmp_luasnip") -- snippet completions
  use("hrsh7th/cmp-nvim-lsp")
  use("hrsh7th/cmp-nvim-lua")

  -- snippets
  use("L3MON4D3/LuaSnip")            --snippet engine
  use("rafamadriz/friendly-snippets") -- a bunch of snippets to use

  -- LSP
  use("neovim/nvim-lspconfig") -- enable LSP
  use({
    "williamboman/mason.nvim",
    run = ":MasonUpdate",                 -- :MasonUpdate updates registry contents
  })
  use("williamboman/mason-lspconfig.nvim") -- simple to use language server installer
  use("jose-elias-alvarez/null-ls.nvim")  -- LSP diagnostics and code actions
  use("mfussenegger/nvim-dap")            -- Debug Adapter Protocol

  -- Telescope
  use("nvim-telescope/telescope.nvim")
  use("nvim-telescope/telescope-media-files.nvim")

  -- Treesitter
  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
  })
  use("p00f/nvim-ts-rainbow")
  use("nvim-treesitter/playground")
  use("nvim-treesitter/nvim-treesitter-context")

  -- Git
  use("lewis6991/gitsigns.nvim")
  use("tpope/vim-fugitive")

  -- Comment
  use("numToStr/Comment.nvim") -- Easily comment stuff
  use("JoosepAlviste/nvim-ts-context-commentstring")

  -- Terminal
  use("akinsho/toggleterm.nvim")

  -- Status Bar
  use("nvim-lualine/lualine.nvim")

  use("RRethy/vim-illuminate")

  use("easymotion/vim-easymotion")

  use("ThePrimeagen/harpoon")

  use("lukas-reineke/indent-blankline.nvim")

  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
