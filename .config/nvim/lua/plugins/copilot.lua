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
            debug = false, -- Set to true for debugging if needed
            log_level = 'info',

            system_prompt = 'COPILOT_INSTRUCTIONS',
            model = 'ollama/llama3', -- Set your default model to llama3
            agent = 'copilot',
            context = nil,
            sticky = nil,
            temperature = 0.1,
            headless = false,
            stream = nil,
            callback = nil,
            remember_as_sticky = true,
            -- REMOVE THIS LINE:
            -- selection = "visual", -- <--- REMOVE OR COMMENT OUT THIS LINE

            window = {
                layout = 'vertical',
                width = 0.5,
                height = 0.5,
                relative = 'editor',
                border = 'single',
                row = nil,
                col = nil,
                title = 'Copilot Chat',
                footer = nil,
                zindex = 1,
            },
            show_help = true,
            highlight_selection = true,
            highlight_headers = true,
            references_display = 'virtual',
            auto_follow_cursor = true,
            auto_insert_mode = false,
            insert_at_end = false,
            clear_chat_on_new_prompt = false,

            chat_autocomplete = true,
            log_path = vim.fn.stdpath('state') .. '/CopilotChat.log',
            history_path = vim.fn.stdpath('data') .. '/copilotchat_history',
            question_header = '# User ',
            answer_header = '# Copilot ',
            error_header = '# Error ',
            separator = '───',

            providers = {
                copilot = {},
                github_models = {},
                copilot_embeddings = {},
                ollama = {},
            },

            contexts = {
                buffer = {},
                buffers = {},
                file = {},
                files = {},
                git = {},
                url = {},
                register = {},
                quickfix = {},
                system = {}
            },

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

            -- Default mappings
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
                    register = '"',
                },
                show_diff = {
                    normal = 'gd',
                    full_diff = false,
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
        },
        config = function(_, opts)
            local chat = require("CopilotChat")
            chat.setup(opts)

            opts.providers.ollama = {
                prepare_input = require('CopilotChat.config.providers').copilot.prepare_input,
                prepare_output = require('CopilotChat.config.providers').copilot.prepare_output,

                get_models = function(headers)
                    local response, err = require('CopilotChat.utils').curl_get('http://localhost:11434/v1/models', {
                        headers = headers,
                        json_response = true,
                    })

                    if err then
                        error(err)
                    end

                    return vim.tbl_map(function(model)
                        return {
                            id = model.id,
                            name = model.id,
                        }
                    end, response.body.data)
                end,

                embed = function(inputs, headers)
                    local response, err = require('CopilotChat.utils').curl_post('http://localhost:11434/v1/embeddings', {
                        headers = headers,
                        json_request = true,
                        json_response = true,
                        body = {
                            input = inputs,
                            model = 'all-minilm',
                        },
                    })

                    if err then
                        error(err)
                    end

                    return response.body.data
                end,

                get_url = function()
                    return 'http://localhost:11434/v1/chat/completions'
                end,
            }

            chat.config.providers.ollama = opts.providers.ollama

            -- Copilot.vim accept suggestion mapping
            vim.g.copilot_no_tab_map = true
            vim.api.nvim_set_keymap('i', '<C-J>', 'copilot#Accept("<CR>")', { silent = true, expr = true })

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
