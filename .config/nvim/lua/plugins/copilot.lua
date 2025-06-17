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
        system_prompt = 'COPILOT_INSTRUCTIONS', -- System prompt to use (can be specified manually in prompt via /).

        model = 'gpt-4.1', -- Default model to use, see ':CopilotChatModels' for available models (can be specified manually in prompt via $).
        agent = 'copilot', -- Default agent to use, see ':CopilotChatAgents' for available agents (can be specified manually in prompt via @).
        context = nil, -- Default context or array of contexts to use (can be specified manually in prompt via #).
        sticky = nil, -- Default sticky prompt or array of sticky prompts to use at start of every new chat.

        temperature = 0.1, -- GPT result temperature
        headless = false, -- Do not write to chat buffer and use history (useful for using custom processing)
        stream = nil, -- Function called when receiving stream updates (returned string is appended to the chat buffer)
        callback = nil, -- Function called when full response is received (retuned string is stored to history)
        remember_as_sticky = true, -- Remember model/agent/context as sticky prompts when asking questions

        -- default selection
        selection = "visual", -- Changed from select.visual to just "visual"

        -- default window options
        window = {
            layout = 'vertical', -- 'vertical', 'horizontal', 'float', 'replace', or a function that returns the layout
            width = 0.5, -- fractional width of parent, or absolute width in columns when > 1
            height = 0.5, -- fractional height of parent, or absolute height in rows when > 1
            -- Options below only apply to floating windows
            relative = 'editor', -- 'editor', 'win', 'cursor', 'mouse'
            border = 'single', -- 'none', single', 'double', 'rounded', 'solid', 'shadow'
            row = nil, -- row position of the window, default is centered
            col = nil, -- column position of the window, default is centered
            title = 'Copilot Chat', -- title of chat window
            footer = nil, -- footer of chat window
            zindex = 1, -- determines if window is on top or below other floating windows
        },

        show_help = true, -- Shows help message as virtual lines when waiting for user input
        highlight_selection = true, -- Highlight selection
        highlight_headers = true, -- Highlight headers in chat, disable if using markdown renderers (like render-markdown.nvim)
        references_display = 'virtual', -- 'virtual', 'write', Display references in chat as virtual text or write to buffer
        auto_follow_cursor = true, -- Auto-follow cursor in chat
        auto_insert_mode = false, -- Automatically enter insert mode when opening window and on new prompt
        insert_at_end = false, -- Move cursor to end of buffer when inserting text
        clear_chat_on_new_prompt = false, -- Clears chat on every new prompt

        -- Static config starts here (can be configured only via setup function)

        debug = false, -- Enable debug logging (same as 'log_level = 'debug')
        log_level = 'info', -- Log level to use, 'trace', 'debug', 'info', 'warn', 'error', 'fatal'
        proxy = nil, -- [protocol://]host[:port] Use this proxy
        allow_insecure = false, -- Allow insecure server connections

        chat_autocomplete = true, -- Enable chat autocompletion (when disabled, requires manual `mappings.complete` trigger)

        log_path = vim.fn.stdpath('state') .. '/CopilotChat.log', -- Default path to log file
        history_path = vim.fn.stdpath('data') .. '/copilotchat_history', -- Default path to stored history

        question_header = '# User ', -- Header to use for user questions
        answer_header = '# Copilot ', -- Header to use for AI answers
        error_header = '# Error ', -- Header to use for errors
        separator = '───', -- Separator to use in chat

        -- default providers
        -- see config/providers.lua for implementation
        providers = {
            copilot = {
            },
            github_models = {
            },
            copilot_embeddings = {
            },
        },

        -- default contexts
        -- see config/contexts.lua for implementation
        contexts = {
            buffer = {
            },
            buffers = {
            },
            file = {
            },
            files = {
            },
            git = {
            },
            url = {
            },
            register = {
            },
            quickfix = {
            },
            system = {
            }
        },

        -- default prompts
        -- see config/prompts.lua for implementation
        prompts = {
            Explain = {
                prompt = 'Write an explanation for the selected code as paragraphs of text.',
                system_prompt = 'COPILOT_EXPLAIN',
            },
            Review = {
                prompt = 'Review the selected code.',
                system_prompt = 'COPILOT_REVIEW',
            },
            Fix = {
                prompt = 'There is a problem in this code. Identify the issues and rewrite the code with fixes. Explain what was wrong and how your changes address the problems.',
            },
            Optimize = {
                prompt = 'Optimize the selected code to improve performance and readability. Explain your optimization strategy and the benefits of your changes.',
            },
            Docs = {
                prompt = 'Please add documentation comments to the selected code.',
            },
            Tests = {
                prompt = 'Please generate tests for my code.',
            },
            Commit = {
                prompt = 'Write commit message for the change with commitizen convention. Keep the title under 50 characters and wrap message at 72 characters. Format as a gitcommit code block.',
                context = 'git:staged',
            },
        },

        -- default mappings
        -- see config/mappings.lua for implementation
        mappings = {
            complete = {
                insert = '<Tab>',
            },
            close = {
                normal = 'q',
                insert = '<C-c>',
            },
            reset = {
                normal = '<C-l>',
                insert = '<C-l>',
            },
            submit_prompt = {
                normal = '<CR>',
                insert = '<C-s>',
            },
            toggle_sticky = {
                normal = 'grr',
            },
            clear_stickies = {
                normal = 'grx',
            },
            accept_diff = {
                normal = '<C-y>',
                insert = '<C-y>',
            },
            jump_to_diff = {
                normal = 'gj',
            },
            quickfix_answers = {
                normal = 'gqa',
            },
            quickfix_diffs = {
                normal = 'gqd',
            },
            yank_diff = {
                normal = 'gy',
                register = '"', -- Default register to use for yanking
            },
            show_diff = {
                normal = 'gd',
                full_diff = false, -- Show full diff instead of unified diff when showing diff window
            },
            show_info = {
                normal = 'gi',
            },
            show_context = {
                normal = 'gc',
            },
            show_help = {
                normal = 'gh',
            },
        },
        config = function(_, opts)
            -- Setup CopilotChat first
            local chat = require("CopilotChat")
            chat.setup(opts)

            -- Copilot.vim accept suggestion mapping
            vim.g.copilot_no_tab_map = true
            vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })

            -- Key mappings
            vim.keymap.set({ "n" }, "<leader>aa", chat.toggle, { desc = "AI Toggle" })
            vim.keymap.set({ "v" }, "<leader>aa", function()
                chat.open({ selection = require("CopilotChat.select").visual })
            end, { desc = "AI Open" })

            vim.keymap.set({ "n" }, "<leader>ax", chat.reset, { desc = "AI Reset" })
            vim.keymap.set({ "n" }, "<leader>as", chat.stop, { desc = "AI Stop" })
            vim.keymap.set({ "n" }, "<leader>am", chat.select_model, { desc = "AI Models" })
            vim.keymap.set({ "n", "v" }, "<leader>ap", chat.select_prompt, { desc = "AI Prompts" })

            vim.keymap.set({ "n", "v" }, "<leader>aq", function()
                vim.ui.input({ prompt = "AI Question> " }, function(input)
                    if input and input ~= "" then
                        chat.ask(input)
                    end
                end)
            end, { desc = "AI Question" })

            -- Additional useful mappings
            vim.keymap.set("n", "<leader>ae", function()
                chat.ask("Explain this code in detail:")
            end, { desc = "AI Explain" })

            vim.keymap.set("v", "<leader>ar", function()
                chat.ask("Review this code and suggest improvements:")
            end, { desc = "AI Review" })
        end,
        event = "VeryLazy",
    }
}
