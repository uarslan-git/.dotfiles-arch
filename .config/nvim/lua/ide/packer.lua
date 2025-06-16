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


	use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
	use('nvim-treesitter/playground')

	use({'VonHeikemen/lsp-zero.nvim', branch = 'v4.x'})
	use({'neovim/nvim-lspconfig'})
	use({'github/copilot.vim'})
    --use({'nvim-tree/nvim-tree.lua'})
	use({'hrsh7th/nvim-cmp'})
	use({'prettier/vim-prettier'})
	use({'hrsh7th/cmp-nvim-lsp'})
    use({'mbbill/undotree'})
    use({'tpope/vim-fugitive'})
    use {
        'CopilotC-Nvim/CopilotChat.nvim',
        config = function()
            local copilot_chat = require("CopilotChat")
            copilot_chat.setup({
                debug = true,
                show_help = "yes",
                prompts = {
                    Explain = "Explain how it works by English language.",
                    Review = "Review the following code and provide concise suggestions.",
                    Tests = "Briefly explain how the selected code works, then generate unit tests.",
                    Refactor = "Refactor the code to improve clarity and readability.",
                },
                proxy = "******",
                build = function()
                    vim.notify(
                        "Please update the remote plugins by running ':UpdateRemotePlugins', then restart Neovim.")
                end,
                event = "VeryLazy",
                dependencies = {
                    { "nvim-telescope/telescope.nvim" }, -- Use telescope for help actions
                    { "nvim-lua/plenary.nvim" }
                }
            })
        end
    }
end)
