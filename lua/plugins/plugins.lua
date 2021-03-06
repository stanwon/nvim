return require('packer').startup(function()
  use 'wbthomason/packer.nvim'

  use 'kyazdani42/nvim-web-devicons'

  use 'hrsh7th/cmp-vsnip'
  use 'hrsh7th/vim-vsnip'

  use "williamboman/nvim-lsp-installer"
  use "neovim/nvim-lspconfig"

  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp'

  use 'ellisonleao/gruvbox.nvim'
  use 'folke/tokyonight.nvim'
  use 'sainnhe/sonokai'
  use 'sainnhe/gruvbox-material'

  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim'

  use 'glepnir/dashboard-nvim'

  use 'simrat39/symbols-outline.nvim'
  use 'nvim-treesitter/nvim-treesitter'

  use 'kyazdani42/nvim-tree.lua'

  use { 'akinsho/bufferline.nvim', tag = "v2.*" }
  use 'nvim-lualine/lualine.nvim'

  use 'voldikss/vim-floaterm'

  use 'windwp/nvim-autopairs'

  use 'p00f/nvim-ts-rainbow'

  use 'petertriho/nvim-scrollbar'

  use 'MunifTanjim/nui.nvim'
  use 'CosmicNvim/cosmic-ui'
  --use 'humiaozuzu/fcitx-status'

  -- install without yarn or npm
  use({
      "iamcco/markdown-preview.nvim",
      run = function() vim.fn["mkdp#util#install"]() end,
  })

  use({ "iamcco/markdown-preview.nvim", run = "cd app && npm install", setup = function() vim.g.mkdp_filetypes = { "markdown" } end, ft = { "markdown" }, })

end)
