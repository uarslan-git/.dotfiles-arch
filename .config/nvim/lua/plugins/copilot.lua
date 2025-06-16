return {
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = {
            { "github/copilot.vim" },
            { "nvim-lua/plenary.nvim", branch = "master" },
        },
        build = "make tiktoken", -- Only on MacOS or Linux
        opts = {
            -- Custom options for Copilot Chat plugin
            -- Example:
            -- debug = true,
        },
        config = function(_, opts)
            -- Custom keymap for Copilot in insert mode
            -- This maps Ctrl-J to accept Copilot suggestion (like pressing Enter)
            vim.g.copilot_no_tab_map = true
            vim.api.nvim_set_keymap('i', '<C-J>', 'copilot#Accept("<CR>")', { silent = true, expr = true })

            -- If you need to add more custom configurations, you can do so here
            -- For example, enabling debug mode, if the plugin supports it:
            -- opts.debug = true
        end,
        -- You can define lazy-load triggers for commands or events
        -- Example:
        -- event = "BufRead",
        -- commands = { "CopilotChat" },
    }
}

