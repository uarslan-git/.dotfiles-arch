return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {"bash", "c", "cpp", "javascript", "typescript", "html", "css","lua", "python", "rust", "vim", "vimdoc"},
                auto_install = true,
                highlight = { enable = true, additional_vim_regex_highlighting = true, },
                indent = { enable = true },
            })
        end
    }
}
