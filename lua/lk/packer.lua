-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'

	use {
		'nvim-telescope/telescope.nvim', tag = '0.1.0',
		requires = { { 'nvim-lua/plenary.nvim' } }
	}

	use('nvim-treesitter/nvim-treesitter', { run = ":TSUpdate" })
	use('nvim-treesitter/playground')

	use('theprimeagen/harpoon')

	use('mbbill/undotree')
	use('tpope/vim-fugitive')

	use {
		'VonHeikemen/lsp-zero.nvim',
		requires = {
			-- LSP Support
			{ 'neovim/nvim-lspconfig' },
			{ 'williamboman/mason.nvim' },
			{ 'williamboman/mason-lspconfig.nvim' },

			-- Autocompletion
			{ 'hrsh7th/nvim-cmp' },
			{ 'hrsh7th/cmp-buffer' },
			{ 'hrsh7th/cmp-path' },
			{ 'saadparwaiz1/cmp_luasnip' },
			{ 'hrsh7th/cmp-nvim-lsp' },
			{ 'hrsh7th/cmp-nvim-lua' },

			-- Snippets
			{ 'L3MON4D3/LuaSnip' },
			{ 'rafamadriz/friendly-snippets' },
		}
	}

  use {
  'nvim-tree/nvim-tree.lua',
    requires = {
      'nvim-tree/nvim-web-devicons', -- optional, for file icons
    },
    tag = 'nightly', -- optional, updated every week. (see issue #1193)
  }

  use('airblade/vim-gitgutter')
  use('vim-airline/vim-airline')
  use {
    'vim-airline/vim-airline-themes',
  }
  use("petertriho/nvim-scrollbar")

  use {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("trouble").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end
  }

  use('prettier/vim-prettier')
  use('dense-analysis/ale')

  use {"akinsho/toggleterm.nvim", tag = '*', config = function()
    require("toggleterm").setup()
  end}

  use('RRethy/vim-illuminate')

  use 'Mofiqul/vscode.nvim'

  use 'zivyangll/git-blame.vim'

  use "lukas-reineke/indent-blankline.nvim"

  use "terrortylor/nvim-comment"

  use {
    'windwp/nvim-autopairs',
    config = function() require("nvim-autopairs").setup {} end
  }
end)
