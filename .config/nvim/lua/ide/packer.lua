vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'

	use {
		'nvim-telescope/telescope.nvim', tag = '0.1.8',
		-- or                            , branch = '0.1.x',
		requires = { {'nvim-lua/plenary.nvim'} }
	}

	use ({
		'rose-pine/neovim',
		as = 'rose-pine',
		config = function()
			vim.cmd('colorscheme rose-pine')
		end
	})

    use ({
    "Bryley/neoai.nvim",
    require = { "MunifTanjim/nui.nvim" },
    cmd = {
        "NeoAI",
        "NeoAIOpen",
        "NeoAIClose",
        "NeoAIToggle",
        "NeoAIContext",
        "NeoAIContextOpen",
        "NeoAIContextClose",
        "NeoAIInject",
        "NeoAIInjectCode",
        "NeoAIInjectContext",
        "NeoAIInjectContextCode",
    },
    config = function()
        require("neoai").setup({
            -- Options go here
        })
    end,
})

	use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
	use('nvim-treesitter/playground')

	use({'VonHeikemen/lsp-zero.nvim', branch = 'v4.x'})
	use({'neovim/nvim-lspconfig'})
    use({'nvim-tree/nvim-tree.lua'})
	use({'hrsh7th/nvim-cmp'})
	use({'prettier/vim-prettier'})
	use({'hrsh7th/cmp-nvim-lsp'})
	use({'mbbill/undotree'})
	use({'tpope/vim-fugitive'})
end)
